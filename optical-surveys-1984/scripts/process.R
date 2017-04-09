# ---- Install missing dependencies ----

packages <- c("sp")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# ---- Load functions ----

#' Convert UTM to Local coordinates
#'
#' Equation 1 in Vaughn et al. 1987 (\url{https://pubs.er.usgs.gov/publication/ofr85487}):
#' x = (UTM Easting - 490000) / 0.9996
#' y = (UTM Northing - 6750000) / 0.9996
#'
#' @param xy UTM coordinates (NAD27 Zone 6N - Robert Krimmel, email: 2014-02-24; L.A. Rasmussen, email: 2014-02-24).
#' @return Local coordinates.
eq1_utm_to_local <- function(xy) {
  xy[, 1] <- (xy[, 1] - 490000) / 0.9996
  xy[, 2] <- (xy[, 2] - 6750000) / 0.9996
  return(xy)
}

#' Convert Local to UTM Coordinates
#'
#' Reverse of Equation 1 in Vaughn et al. 1987 (\url{https://pubs.er.usgs.gov/publication/ofr85487}):
#' UTM Easting = (x * 0.9996) + 490000
#' UTM Northing = (y * 0.9996) + 6750000
#'
#' @param xy Local coordinates.
#' @return UTM coordinates (NAD27 Zone 6N - Robert Krimmel, email: 2014-02-24; L.A. Rasmussen, email: 2014-02-24).
eq1_local_to_utm <- function(xy) {
  xy[, 1] <- (xy[, 1] * 0.9996) + 490000
  xy[, 2] <- (xy[, 2] * 0.9996) + 6750000
  return(xy)
}

#' Align Azimuth Angle to UTM Grid
#'
#' Equation 2 in Vaughn et al. 1987 (\url{https://pubs.er.usgs.gov/publication/ofr85487}):
#' theta_G = 8.285744 - (pi / 200) * theta_hat_G
#' theta_Q = 5.005084 - (pi / 200) * theta_hat_Q
#'
#' @param theta_hat Azimuth angle in grads to the right of Easy.
#' @param station Name of the survey station: either "New Gilbert" / "G" or "New Quickie" / "Q".
#' @return Radians counterclockwise from the UTM +x axis (east).
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

#' Triangulate Marker Positions
#'
#' Equation 4 in Vaughn et al. 1987 (\url{https://pubs.er.usgs.gov/publication/ofr85487}):
#' x_T = (1 / (tan(theta_Q) - tan(theta_G))) * ((y_G - tan(theta_G) * x_G) - (y_Q - tan(theta_Q) * x_Q))
#' y_T = (1 / (tan(theta_Q) - tan(theta_G))) * (tan(theta_Q) * (y_G - tan(theta_G) * x_G) - tan(theta_G) * (y_Q - tan(theta_Q) * x_Q))
#'
#' Finds the intersection of sighting lines from New Gilbert and New Quickie (survey stations), neglecting the Earth's curvature.
#'
#' @param xyz_G Position of New Gilbert in local coordinates.
#' @param theta_G Azimuth angle (radians counterclockwise from east) sightings from New Gilbert.
#' @param xyz_Q Position of New Quickie in local coordinates.
#' @param theta_Q Azimuth angle (radians counterclockwise from east) sighting from New Quickie
#' @return Horizontal marker positions in local coordinates.
eq4_target_xy <- function(xyz_G, theta_G, xyz_Q, theta_Q) {
  x_T <- (1 / (tan(theta_Q) - tan(theta_G))) * ((xyz_G[2] - tan(theta_G) * xyz_G[1]) - (xyz_Q[2] - tan(theta_Q) * xyz_Q[1]))
  y_T <- (1 / (tan(theta_Q) - tan(theta_G))) * (tan(theta_Q) * (xyz_G[2] - tan(theta_G) * xyz_G[1]) - tan(theta_G) * (xyz_Q[2] - tan(theta_Q) * xyz_Q[1]))
  return(data.frame(x = x_T, y = y_T))
}

#' Triangulate Marker Heights
#'
#' Equation 5 in Vaughn et al. 1987 (\url{https://pubs.er.usgs.gov/publication/ofr85487}):
#' z_T = z_S + h_S + (6.8 * 10^-8 * r_S - tan(phi_S)) * r_S
#' r_S = sqrt((x_S - x_T)^2 + (y_S - y_T)^2)
#' where S is either Q or G.
#'
#' Computes the height of the marker, accounting for refraction and Earth's curvature.
#'
#' @param xy_T Horizontal marker positions in local coordinates.
#' @param xyz Survey station position in local coordinates.
#' @param phi Elevation angle (grads below the local horizontal) sightings from survey station.
#' @param h Height (in meters) of survey station above the ground.
eq5_target_z <- function(xy_T, xyz, phi, h) {
  r <- sqrt((xyz[1] - xy_T[1])^2 + (xyz[2] - xy_T[2])^2)
  z_T <- xyz[3] + h + (6.8 * 10^-8 * r - tan(phi)) * r
  return(z_T)
}

#' Intersect Line (Segment) with Ray
#'
#' Generalized form of Equation 8 in Vaughn et al. 1987 (\url{https://pubs.er.usgs.gov/publication/ofr85487}).
#' Inspired by \url{http://paulbourke.net/geometry/pointlineplane/}.
#'
#' @param edge Endpoints of the line segment [x0 y0; x1 y1].
#' @param origin Origin of the ray [x y].
#' @param theta Angle of the ray (radians counterclockwise from +x).
#' @param edge_as_line Whether to interpret the edge as a line (\code{TRUE}) or line segment (\code{FALSE}, the default).
#' @return Coordinates of the intersection [x y], or empty if none.
eq8_intersect_edge_ray <- function(edge, origin, theta, edge_as_line = FALSE) {
  # Force theta to [-pi, pi] range
  theta <- ifelse(theta < pi, theta, theta - 2 * pi)
  # Compute vector directions
  d1 <- as.vector(diff(edge))
  d2 <- c(cos(theta), sin(theta))
  d3 <- edge[1, ] - origin
  # Compute times
  denominator <- d2[2] * d1[1] - d2[1] * d1[2]
  t1 <- (d2[1] * d3[2] - d2[2] * d3[1]) / denominator
  t2 <- (d1[1] * d3[2] - d1[2] * d3[1]) / denominator
  # Check result
  if (t2 > 0 && (edge_as_line || (t1 > 0 && t1 < 1))) {
    intersection <- origin + t2 * d2
  } else {
    intersection <- numeric(0)
  }
  return(matrix(intersection, ncol = 2))
}

#' Intersect Line Segment with Circle
#'
#' Generalized form of Equation 10 in Vaughn et al. 1987 (\url{https://pubs.er.usgs.gov/publication/ofr85487}).
#' Inspired by \url{http://stackoverflow.com/questions/1073336/circle-line-segment-collision-detection-algorithm}.
#'
#' @param edge Endpoints of the line segment [x0 y0; x1 y1].
#' @param center Center of the circle [x y].
#' @param radius Radius of the circle.
#' @return Coordinates of the intersection(s) [x0 y0; ...], or empty if none.
eq10_intersect_edge_circle <- function(edge, center, radius) {
  d <- as.vector(diff(edge))
  f <- edge[1, ] - center
  polycoeffs <- c(f %*% f - radius^2, 2 * f %*% d, a <- d %*% d)
  roots <- polyroot(polycoeffs)
  times <- Re(roots)[abs(Im(roots)) < 1e-10]
  times <- times[times >= 0 & times <= 1]
  intersections <- t(edge[1, ] +  d %*% t(times))
  if (ncol(intersections) == 0) {
    intersections <- matrix(numeric(0), nrow = 0, ncol = 2)
  }
  return(intersections)
}

#' Convert 1984 Julian Day to UTC Date Time
#'
#' Vaughn et al. 1987 (\url{https://pubs.er.usgs.gov/publication/ofr85487}), page 8:
#' "Time is represented by the Julian day of 1984; it is 214.000 at 0000 hours local time on August 1, 1984 and increases by 1 each day thereafter."
#'
#' The offset between local Alaska time and UTC was determined from \url{https://www.timeanddate.com/time/change/usa/anchorage?year=1984}.
#'
#' @param julian_day Julian day of 1984 in AKDT (UTC - 8).
#' @return ISO 8601 date time in UTC.
#' @examples
#' julian_day_to_utc_datetime(214) == "1984-08-01T08:00:00Z"
julian_day_to_utc_datetime <- function(julian_day) {
  julian_day_utc <- julian_day + 8 / 24
  origin <- strptime("1983-12-31 00:00:00", "%Y-%m-%d %H:%M:%S", tz = "UTC")
  datetime <- format(as.POSIXlt(julian_day_utc * (60 * 60 * 24), tz = "UTC", origin = origin), "%Y-%m-%dT%H:%M:%SZ")
  return(datetime)
}

#' Convert NAD27 to WGS84 UTM (Alaska, Zone 6N)
#'
#' Custom transformation parameters from \url{http://web.archive.org/web/20130905025856/http://surveying.wb.psu.edu/sur351/DatumTrans/datum_transformations.htm}.
#'
#' @param xy NAD27 Zone 6N UTM coordinates.
#' @return WGS84 Zone 6N UTM coordinates.
nad27_to_wgs84_utm <- function(xy) {
  current_proj4 <- sp::CRS("+proj=utm +zone=6 +ellps=clrk66 +towgs84=-5,135,172 +units=m +no_defs")
  target_proj4 <- sp::CRS("+proj=utm +zone=6 +datum=WGS84")
  xy <- data.frame(x = xy[, 1], y = xy[, 2])
  sp::coordinates(xy) <- c("x", "y")
  sp::proj4string(xy) <- current_proj4
  return(sp::spTransform(xy, target_proj4)@coords)
}

# ---- Load common data ----

table1 <- read.csv("sources/vaughn-others-1985-table-1.csv", stringsAsFactors = FALSE)

# ---- Survey markers ----

## Read table

appendix1 <- read.csv("sources/vaughn-others-1985-appendix-1.csv", stringsAsFactors = FALSE)

## Pre-process table

# Remove omitted markers
# "Omitted from this analysis were marker 12, for which frequent sightings were lacking from both survey stations; marker 14, which apparently fell from the serac on which it was placed; and markers 16, 18, and 22, which were each sighted from only one survey station."
appendix1 <- appendix1[!appendix1$marker %in% c(12, 14, 16, 18, 22), ]
# Remove incorrect angle values
# "Apparently incorrect values ..." [pg 21]
appendix1$theta_hat[appendix1$incorrect_theta] <- NA
appendix1$phi[appendix1$incorrect_phi] <- NA
appendix1 <- appendix1[!(is.na(appendix1$theta_hat) & is.na(appendix1$phi)), ]
# Convert theta_hat (grads from Easy) to theta (radians from +x axis)
# "The azimuth angle theta_hat is measured in grads to the right of Easy" [pg 21]
appendix1$theta <- eq2_theta_hat_to_theta(appendix1$theta_hat, appendix1$station)
# Convert phi from grads to radians
# "The elevation angle phi is measured in grads below the horizontal." [pg 21]
appendix1$phi <- appendix1$phi * (pi / 200)
# Convert t_hat to t (Julian day)
# "The time shown t is 200 less than the 1984 Julian Day" [pg 21]
appendix1$t <- appendix1$t_hat + 200
# Convert instrument height (h) from mm to m
# "The instrument height h is in mm above the altitude of the survey station." [pg 21]
appendix1$h <- appendix1$h / 1000
# Convert quality codes to errors in radians
# "The quality codes K_theta and K_phi following the values for the angles indicate the estimated error: 0 for 0.0030 grads, 1 for 0.0060, 2 for 0.0090, and 3 for 0.0120." [pg 21]
errors <- c(0.0030, 0.0060, 0.0090, 0.0120) * (pi / 200)
appendix1$K_theta <- errors[appendix1$K_theta + 1]
appendix1$K_phi <- errors[appendix1$K_phi + 1]
# Sort by time
appendix1 <- appendix1[order(appendix1$t), ]

## Compute marker trajectories
# "Because sightings of the moving markers were not made simultaneously from the two survey stations, time interpolation in the angle data from one, or the other, or sometimes both stations was used to get synchronous values for use in equations 2-6." [pg 11]
# "When azimuth angles to a marker were available from both survey stations, they were used (equations 3,4) to establish the marker's x, y trajectory, which was approximated by a straight line (table 2). The azimuth angles theta from the station with the more numerous sightings of a marker were then used (equation 8) to estimate the velocity along the trajectory." [pg 16]

# Station coordinates
xyz_G <- as.numeric(table1[table1$station == "New Gilbert", c("x", "y", "z")])
xyz_Q <- as.numeric(table1[table1$station == "New Quickie", c("x", "y", "z")])

# Set maximum time interval for pairing measurements from each station (in days)
t_tol <- 0.2

# Set spline smoothing parameter
spar <- 0.5

# For each marker...
results <- list()
for (marker in unique(appendix1$marker)) {

  ## Filter measurements
  # Filter by marker
  ind_marker <- appendix1$marker == marker
  # Filter by station
  ind_G <- ind_marker & appendix1$station == "New Gilbert"
  ind_Q <- ind_marker & appendix1$station == "New Quickie"
  # Skip if measurements from only one station
  if (sum(ind_G) == 0 || sum(ind_Q) == 0) {
    next
  }

  ## Match measurements
  # Measure time seperation between measurements
  dt <- do.call(rbind, (lapply(appendix1$t[ind_G], function(t_G) {
    t_G - appendix1$t[ind_Q]
  })))
  # Select equal time pairs
  t_equal_ind <- which(dt == 0, arr.ind = TRUE)
  # Select nearby time pairs
  t_nearby_ind <- which(abs(dt) > 0 & abs(dt) < t_tol, arr.ind = TRUE)
  if (nrow(t_nearby_ind) > 0) {
    t_nearby_min <- mapply(t_nearby_ind[, 1], t_nearby_ind[, 2], FUN = function(r, c) {abs(dt)[r, c]})
    # (reduce to nearest pairing for each measurement, with no duplicates)
    temp <- as.data.frame(cbind(t_nearby_ind, min = t_nearby_min))
    temp <- do.call(rbind, by(temp, list(temp$col), function(x) {
      x[x$min == min(x$min), ]
    }))
    temp <- do.call(rbind, by(temp, list(temp$row), function(x) {
      x[x$min == min(x$min), ]
    }))
    t_nearby_ind <- as.matrix(temp[, c("row", "col")])
  }

  ## If fewer than 4 points from either station...
  if (sum(ind_G) < 4 || sum(ind_Q) < 4) {
    # Process equal time pairs (exact)
    if (nrow(t_equal_ind) > 0) {
      equal_ind_G <- which(ind_G)[t_equal_ind[, 1]]
      equal_ind_Q <- which(ind_Q)[t_equal_ind[, 2]]
      t <- appendix1$t[equal_ind_G]
      xy_T <- eq4_target_xy(xyz_G, appendix1$theta[equal_ind_G], xyz_Q, appendix1$theta[equal_ind_Q])
      z_T_G <- as.numeric(eq5_target_z(xy_T, xyz_G, appendix1$phi[equal_ind_G], appendix1$h[equal_ind_G]))
      z_T_Q <- as.numeric(eq5_target_z(xy_T, xyz_Q, appendix1$phi[equal_ind_Q], appendix1$h[equal_ind_Q]))
      X <- data.frame(marker = marker, t = t, x = xy_T[, 1], y = xy_T[, 2], z_G = z_T_G, z_Q = z_T_Q)
      results <- c(results, list(X))
    }
    next
  }

  ## If at least 4 points from each station...
  t_ind <- rbind(t_equal_ind, t_nearby_ind)

  # Build models (cubic spline)
  t <- appendix1$t[ind_G]
  has_theta <- !is.na(appendix1$theta[ind_G])
  model_G_theta <- smooth.spline(t[has_theta], appendix1$theta[ind_G][has_theta], w = 1 / appendix1$K_theta[ind_G][has_theta], spar = spar)
  has_phi <- !is.na(appendix1$phi[ind_G])
  model_G_phi <- smooth.spline(t[has_phi], appendix1$phi[ind_G][has_phi], w = 1 / appendix1$K_phi[ind_G][has_phi], spar = spar)
  model_G_h <- smooth.spline(t, appendix1$h[ind_G], spar = spar)
  t <- appendix1$t[ind_Q]
  has_theta <- !is.na(appendix1$theta[ind_Q])
  model_Q_theta <- smooth.spline(t[has_theta], appendix1$theta[ind_Q][has_theta], w = 1 / appendix1$K_theta[ind_Q][has_theta], spar = spar)
  has_phi <- !is.na(appendix1$phi[ind_Q])
  model_Q_phi <- smooth.spline(t[has_phi], appendix1$phi[ind_Q][has_phi], w = 1 / appendix1$K_phi[ind_Q][has_phi], spar = spar)
  model_Q_h <- smooth.spline(t, appendix1$h[ind_Q], spar = spar)

  # Snap each point pair to time with furthest value
  # (so interpolation performed on sequence with denser samples)
  dt_G <- diff(appendix1$t[ind_G])
  min_dt_G <- pmin(c(Inf, dt_G), c(dt_G, Inf))
  dt_Q <- diff(appendix1$t[ind_Q])
  min_dt_Q <- pmin(c(Inf, dt_Q), c(dt_Q, Inf))
  use_Q <- min_dt_G[t_ind[, 1]] < min_dt_Q[t_ind[, 2]]
  # Build time vector
  nearby_ind_G <- which(ind_G)[t_ind[, 1]]
  nearby_ind_Q <- which(ind_Q)[t_ind[, 2]]
  t <- appendix1$t[nearby_ind_G]
  t[use_Q] <- appendix1$t[nearby_ind_Q][use_Q]

  # Evaluate models
  theta_G <- predict(model_G_theta, t)$y
  phi_G <- predict(model_G_phi, t)$y
  h_G <- predict(model_G_h, t)$y
  theta_Q <- predict(model_Q_theta, t)$y
  phi_Q <- predict(model_Q_phi, t)$y
  h_Q <- predict(model_Q_h, t)$y

  # Compute point trajectory
  xy_T <- eq4_target_xy(xyz_G, theta_G, xyz_Q, theta_Q)
  z_T_G <- as.numeric(eq5_target_z(xy_T, xyz_G, phi_G, h_G))
  z_T_Q <- as.numeric(eq5_target_z(xy_T, xyz_Q, phi_Q, h_Q))
  X <- data.frame(marker = marker, t = t, x = xy_T[, 1], y = xy_T[, 2], z_G = z_T_G, z_Q = z_T_Q)
  X <- X[order(X$t), ]
  XX <- X

  # Intersect trajectory with single measurements
  # New Gilbert
  single_ind_G <- setdiff(which(ind_G), nearby_ind_G)
  if (sum(single_ind_G) > 0) {
    t <- appendix1$t[single_ind_G]
    theta_G <- predict(model_G_theta, t)$y
    phi_G <- predict(model_G_phi, t)$y
    h_G <- predict(model_G_h, t)$y
    X_G <- data.frame(marker = marker, t = t, x = NA, y = NA, z_G = NA, z_Q = NA)
    for (i in seq_len(nrow(X_G))) {
      j <- findInterval(t[i], X$t)
      edge_as_line <- j < 1 || j >= nrow(X)
      if (edge_as_line) {
        j <- ifelse(j < 1, 1, nrow(X) - 1)
      }
      xy_T <- eq8_intersect_edge_ray(as.matrix(X[c(j, j + 1), c("x", "y")]), xyz_G[1:2], theta_G[i], edge_as_line = edge_as_line)
      if (nrow(xy_T) > 0) {
        z_T_G <- eq5_target_z(xy_T, xyz_G, phi_G[i], h_G[i])
        X_G[i, c("x", "y", "z_G")] <- c(xy_T, z_T_G)
      }
    }
    XX <- rbind(X, X_G)
  }
  # New Quickie
  single_ind_Q <- setdiff(which(ind_Q), nearby_ind_Q)
  if (sum(single_ind_Q) > 0) {
    t <- appendix1$t[single_ind_Q]
    theta_Q <- predict(model_Q_theta, t)$y
    phi_Q <- predict(model_Q_phi, t)$y
    h_Q <- predict(model_Q_h, t)$y
    X_Q <- data.frame(marker = marker, t = t, x = NA, y = NA, z_G = NA, z_Q = NA)
    for (i in seq_len(nrow(X_Q))) {
      j <- findInterval(t[i], X$t)
      edge_as_line <- j < 1 || j >= nrow(X)
      if (edge_as_line) {
        j <- ifelse(j < 1, 1, nrow(X) - 1)
      }
      xy_T <- eq8_intersect_edge_ray(as.matrix(X[c(j, j + 1), c("x", "y")]), xyz_Q[1:2], theta_Q[i], edge_as_line = edge_as_line)
      if (nrow(xy_T) > 0) {
        z_T_Q <- eq5_target_z(xy_T, xyz_Q, phi_Q[i], h_Q[i])
        X_Q[i, c("x", "y", "z_Q")] <- c(xy_T, z_T_Q)
      }
    }
    XX <- rbind(X, X_Q)
  }

  # Save result
  results <- c(results, list(XX[order(XX$t), ]))
}

# Compile all trajectories
df <- do.call("rbind", results)
# Sort by marker, then by time
df <- df[order(df$marker, df$t), ]
# HACK: Remove duplicates
df <- df[!duplicated(df), ]

## Plot results

# Figure 2
# Map of all trajectories
plot(df$x, df$y, col = df$marker, asp = 1)

# Figure 6
# Horizontal velocity plot for each marker
plot(0, 0, xlim = c(220, 250), ylim = c(0, 20))
for (marker in unique(df$marker)) {
  ind <- df$marker == marker
  if (sum(ind) > 1) {
    t <- df$t[ind][-1] - diff(df$t[ind]) / 2
    v <- sqrt(apply(diff(as.matrix(df[ind, c("x", "y")]))^2, 1, sum)) / diff(df$t[ind])
    if (any(v > 20)) {
      warning(paste("Problem with marker", marker))
    }
    smf <- smooth.spline(t, v)
    smt <- seq(min(t), max(t), 0.1)
    smv <- predict(smf, smt)$y
    points(t, v, col = "gray")
    lines(smt, smv, col = marker)
  }
}

## Convert to modern reference frames

mdf <- df

# Convert decimal day (local time) to ISO 8601 (UTC)
mdf$t <- julian_day_to_utc_datetime(mdf$t)

# Convert local coordinates to WGS84 UTM Zone 6N
xy_nad27 <- eq1_local_to_utm(mdf[, c("x", "y")])
xy_wgs84 <- nad27_to_wgs84_utm(xy_nad27)
mdf[, c("x", "y")] <- xy_wgs84

## Save results

write.csv(mdf, "data/markers.csv", row.names = FALSE, quote = FALSE, na = "")

# ---- EDM measurements ----

appendix2 <- read.csv("sources/vaughn-others-1985-appendix-2.csv", stringsAsFactors = FALSE)

# Convert t_hat to t (Julian day)
# "The time shown t_hat is 200 less than the 1984 Julian Day" [pg 26]
appendix2$t <- appendix2$t_hat + 200
# Convert r in mm to m, add 3 km
# "The actual measured distance r_hat and the distance r adjusted for variation in atmospheric density are both 3 km more than the value that is given here in mm." [pg 26]
appendix2$r <- (appendix2$r / 1000) + 3000
# Discard rows with missing r
# "Adjusted values for the first four readings are absent because of the unavailability of meteorological data then." [pg 26]
appendix2 <- appendix2[!is.na(appendix2$r), ]
# Smooth r
# "A cubic spline (Reinsch, 1967) was used to smooth the n = 1,621 distance values r_i obtained from the EDM." [pg 16]
smf <- smooth.spline(appendix2$t, appendix2$r)
smr <- predict(smf, appendix2$t)$y
# "Where sigma = 10 mm includes the standard error of the instrument 5 mm plus 1 mm for each km of distance (Adams, 1978), and 1 mm error due to recording the time to the nearest minute." [pg 18]
# sd(smr - appendix2$r) < 10 / 1000
appendix2$r <- smr

# Distance - trajectory intersection
center <- as.numeric(table1[table1$station == "EDM-site", c("x", "y")])
df11 <- df[df$marker == 11, ]
df11 <- df11[order(df11$t), ]
appendix2$x <- NA
appendix2$y <- NA
for (i in seq_len(nrow(appendix2))) {
  t <- appendix2$t[i]
  j <- findInterval(appendix2$t[i], df11$t)
  # HACK: Try intersecting with two previous trajectory segments.
  j <- max(1, j - 2)
  while (j > 0 && j < nrow(df11)) {
    intersections <- eq10_intersect_edge_circle(as.matrix(df11[c(j, j + 1), c("x", "y")]), center, appendix2$r[i])
    if (nrow(intersections) == 1) {
      # Single intersection
      appendix2[i, c("x", "y")] <- intersections
      break
    } else if (nrow(intersections) > 1) {
      # Multiple intersections
      stop(paste("Multiple intersections at row", i))
    } else {
      # No intersection
      # HACK: Try intersecting with next trajectory segment.
      j <- j + 1
    }
  }
}
# HACK: Discard rows with no intersection
# TODO: Intersect with extended edges at ends of trajectory?
appendix2 <- appendix2[!(is.na(appendix2$x) | is.na(appendix2$y)), ]

## Plot results

# Figure 7
# Velocities from EDM
t <- appendix2$t[-1] - diff(appendix2$t) / 2
v <- sqrt(apply(diff(as.matrix(appendix2[, c("x", "y")]))^2, 1, sum)) / diff(appendix2$t)
plot(t, v, type = 'p', ylim = c(6, 16), col = "gray")
smf <- smooth.spline(t[!is.na(v)], v[!is.na(v)])
lines(t, predict(smf, t)$y, col = "red")
# Velocities from sightings
marker <- 11
ind <- df$marker == marker
t <- df$t[ind][-1] - diff(df$t[ind]) / 2
v <- sqrt(apply(diff(as.matrix(df[ind, c("x", "y")]))^2, 1, sum)) / diff(df$t[ind])
smf <- smooth.spline(t, v)
smt <- seq(min(t), max(t), 0.1)
smv <- predict(smf, smt)$y
points(t, v, pch = 20)
lines(smt, smv)

## Convert to modern reference frames

mdf <- appendix2

# Convert decimal day (local time) to ISO 8601 (UTC)
mdf$t <- julian_day_to_utc_datetime(mdf$t)

# Convert local coordinates to WGS84 UTM Zone 6N
xy_nad27 <- eq1_local_to_utm(mdf[, c("x", "y")])
xy_wgs84 <- nad27_to_wgs84_utm(xy_nad27)
mdf[, c("x", "y")] <- xy_wgs84

# Add marker field
mdf$marker <- 11

## Save results

write.csv(mdf[, c("marker", "t", "x", "y")], "data/marker-11.csv", row.names = FALSE, quote = FALSE, na = "")
