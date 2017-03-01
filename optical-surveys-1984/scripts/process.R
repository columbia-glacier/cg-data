# ---- Load data ----

appendix_1 <- read.csv("sources/appendix-1.csv", stringsAsFactors = FALSE)
appendix_2 <- read.csv("sources/appendix-2.csv", stringsAsFactors = FALSE)
table_1 <- read.csv("sources/table-1.csv", stringsAsFactors = FALSE)

# ---- Load functions ----

# Convert local to UTM coordinates
# Equation 1
# x = (UTM Easting - 490000) / 0.9996
# y = (UTM Northing - 6750000) / 0.9996
eq1_utm_to_local <- function(xy) {
  xy[, 1] <- (xy[, 1] - 490000) / 0.9996
  xy[, 2] <- (xy[, 2] - 6750000) / 0.9996
  return(xy)
}
eq1_local_to_utm <- function(xy) {
  xy[, 1] <- (xy[, 1] * 0.9996) + 490000
  xy[, 2] <- (xy[, 2] * 0.9996) + 6750000
  return(xy)
}

# Convert azimuth angle in grads (to the right of Easy) to radians (counterclockwise from the +x axis)
# Equation 2
# theta_G = 8.285744 - (pi / 200) * theta_hat_G
# theta_Q = 5.005084 - (pi / 200) * theta_hat_Q
eq2_theta_hat_to_theta <- function(theta_hat, station) {
    theta <- mapply(theta_hat, station, FUN = function(t, s) {
      if (s %in% c("New Gilbert", "G")) {
        return(8.285744 - (pi / 200) * t)
      }
      if (s %in% c("New Quickie", "Q")) {
        return(5.005084 - (pi / 200) * t)
      }
      stop(paste("Station not found:", s))
    })
    return(theta)
}

# Intersect sighting lines from New Gilbert and New Quickie (neglecting the effect of Earth's curvature)
# Equation 4
# x_T = (1 / (tan(theta_Q) - tan(theta_G))) * ((y_G - tan(theta_G) * x_G) - (y_Q - tan(theta_Q) * x_Q))
# y_T = (1 / (tan(theta_Q) - tan(theta_G))) * (tan(theta_Q) * (y_G - tan(theta_G) * x_G) - tan(theta_G) * (y_Q - tan(theta_Q) * x_Q))
eq4_target_xy <- function(xyz_G, theta_G, xyz_Q, theta_Q) {
  x_T <- (1 / (tan(theta_Q) - tan(theta_G))) * ((xyz_G[2] - tan(theta_G) * xyz_G[1]) - (xyz_Q[2] - tan(theta_Q) * xyz_Q[1]))
  y_T <- (1 / (tan(theta_Q) - tan(theta_G))) * (tan(theta_Q) * (xyz_G[2] - tan(theta_G) * xyz_G[1]) - tan(theta_G) * (xyz_Q[2] - tan(theta_Q) * xyz_Q[1]))
  return(data.frame(x = x_T, y = y_T))
}

# Compute height of the marker (accounting for refraction and Earth's curvature)
# Equation 5
# z_T = z_S + h_S + (6.8 * 10^-8 * r_S - tan(phi_S)) * r_S
# r_S = sqrt((x_S - x_T)^2 + (y_S - y_T)^2)
# where S is either Q or G, h is instrument height above the ground, and phi is radians below the local horizontal.
# NOTE: Appendix 1 lists phi in grads, so a conversion to radians is necessary.
eq5_target_z <- function(xy_T, xyz, phi, h) {
  r <- sqrt((xyz[1] - xy_T[1])^2 + (xyz[2] - xy_T[2])^2)
  z_T <- xyz[3] + h + (6.8 * 10^-8 * r - tan(phi)) * r
  return(z_T)
}

# Convert Julian day to date time
# "Time is represented by the Julian day of 1984; it is 214.000 at 0000 hours local time on August 1, 1984 and increases by 1 each day thereafter." [pg 8]
julian_day_to_datetime <- function(julian_day) {
  origin <- strptime("1983-12-31 00:00:00", "%Y-%m-%d %H:%M:%S", tz = "UTC")
  datetime <- format(as.POSIXlt(julian_day * (60 * 60 * 24), tz = "UTC", origin = origin), "%Y-%m-%d %H:%M:%S")
  return(datetime)
}

# ---- Survey markers ----

# Convert theta_hat (grads from Easy) to theta (radians from +x axis)
appendix_1$theta <- eq2_theta_hat_to_theta(appendix_1$theta_hat, appendix_1$station)
# Convert phi from grads to radians
appendix_1$phi <- appendix_1$phi * (pi / 200)
# Convert t_hat to t (Julian day)
appendix_1$t <- appendix_1$t_hat + 200

# "Because sightings of the moving markers were not made simultaneously from the two survey stations, time interpolation in the angle data from one, or the other, or sometimes both stations was used to get synchronous values for use in equations 2-6." [pg 11]

# 
xyz_G <- as.numeric(table_1[table_1$station == "New Gilbert", c("x", "y", "z")])
xyz_Q <- as.numeric(table_1[table_1$station == "New Quickie", c("x", "y", "z")])

X <- list()
for (marker in unique(appendix_1$marker)) {
  ind_marker <- appendix_1$marker == marker
  ind_G <- ind_marker & appendix_1$station == "New Gilbert"
  ind_Q <- ind_marker & appendix_1$station == "New Quickie"
  if (any(sum(ind_Q) < 4, sum(ind_G) < 4)) {
    next
  }
  range_G <- range(appendix_1$t[ind_G])
  range_Q <- range(appendix_1$t[ind_Q])
  range_t <- c(max(c(range_G[1], range_Q[1])), min(c(range_G[2], range_Q[2])))
  in_range_G <- ind_G & appendix_1$t >= range_t[1] & appendix_1$t <= range_t[2]
  in_range_Q <- ind_Q & appendix_1$t >= range_t[1] & appendix_1$t <= range_t[2]
  t <- sort(unique(appendix_1$t[in_range_G | in_range_Q]))
  
  model_G_theta <- lm(theta ~ poly(t, 3), data = appendix_1[ind_G, ])
  model_G_phi <- lm(phi ~ poly(t, 3), data = appendix_1[ind_G, ])
  model_G_h <- lm(h ~ poly(t, 3), data = appendix_1[ind_G, ])
  theta_G <- predict(model_G_theta, data.frame(t = t))
  phi_G <- predict(model_G_phi, data.frame(t = t))
  h_G <- predict(model_G_h, data.frame(t = t))
  
  model_Q_theta <- lm(theta ~ poly(t, 3), data = appendix_1[ind_Q, ])
  model_Q_phi <- lm(phi ~ poly(t, 3), data = appendix_1[ind_Q, ])
  model_Q_h <- lm(h ~ poly(t, 3), data = appendix_1[ind_Q, ])
  theta_Q <- predict(model_Q_theta, data.frame(t = t))
  phi_Q <- predict(model_Q_phi, data.frame(t = t))
  h_Q <- predict(model_Q_h, data.frame(t = t))
  
  xy_T <- eq4_target_xy(xyz_G, theta_G, xyz_Q, theta_Q)
  z_T_G <- eq5_target_z(xy_T, xyz_G, phi_G, h_G)
  z_T_Q <- eq5_target_z(xy_T, xyz_Q, phi_Q, h_Q)
  z_T <- rowMeans(cbind(z_T_G, z_T_Q))
  X[[length(X) + 1]] <- data.frame(marker = marker, t = t, x = xy_T[, 1], y = xy_T[, 2], z = z_T)
}
df <- do.call("rbind", X)
plot(df$x, df$y, col = df$marker, asp = 1)

marker <- 6
t <- df$t[df$marker == marker][-sum(df$marker == marker)] + diff(df$t[df$marker == marker]) / 2
v <- sqrt(apply(diff(as.matrix(df[df$marker == marker, c("x", "y")]))^2, 1, sum))
plot(t, v, type = 'b')

t <- unique(appendix_1$t[ind_G | ind_Q])

model_G <- lm(theta ~ poly(t, 3), data = appendix_1[ind_G, ])
plot(appendix_1$t[ind_G], appendix_1$theta[ind_G])
points(t, predict(model_G, data.frame(t = t)), col = 'red')

model_Q <- lm(appendix_1$theta[ind_Q] ~ poly(appendix_1$t[ind_Q], 3))
plot(appendix_1$t[ind_Q], appendix_1$theta[ind_Q])
points(t, predict(model_Q, data.frame(x = t)), col = 'red')
# plot(fitted(model_Q),residuals(model_Q))

appendix_1[ind_Q, ]

# Find overlapping time range
# Interpolate dense series at times from sparse sequence
# (Interpolate at all times?)
# Triangulate horizontal positions
# (Triangulate straight line with single sighting)
# 


plot(appendix_1$t[ind], appendix_1$theta[ind], type = 'p', col = 'black')
ind <- appendix_1$marker == 1 & appendix_1$station == "New Quickie"
points(appendix_1$t[ind], appendix_1$theta[ind], col = 'red')



# "Can be estimated from either station independently from observations at the other station, a linear combination of the two estimates may be used for the altitude of the marker." [pg 10]

# Errors
# "0 for 0.0030 grads, 1 for 0.0060, 2 for 0.0090, and 3 for 0.0120" [pg 11]


# ---- EDM measurements ----

# Adjust for variations in atmospheric density
# Equation 9
# r = (279.42 - (105.885 * p) / (273.2 + T_bar)) * 10^-6 * r_hat
# where p is pressure (mm mercury), T_bar is the air temperature (C), and r_hat is the original distance reading.

# Convert to coordinates
# x = my - f
# y = y_H + 

current_proj4 <- "+proj=utm +zone=6 +ellps=clrk66 +towgs84=-5,135,172 +units=m +no_defs" # NAD27 Alaska (excluding Aleutian Islands)
target_proj4 <- "+proj=utm +zone=6 +datum=WGS84"