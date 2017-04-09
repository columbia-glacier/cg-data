# ---- Install missing dependencies ----

packages <- c("readxl", "sp")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# ---- Load functions ----

#' Convert WGS84 Lng, Lat to UTM (Alaska, Zone 6N)
#' 
#' @param lnglat WGS84 geographic coordinates.
#' @return WGS84 Zone 6N UTM coordinates.
lnglat_to_utm <- function(lnglat) {
  lnglat <- as.data.frame(if (is.vector(lnglat)) t(lnglat) else lnglat)[, 1:2]
  sp::coordinates(lnglat) <- names(lnglat)
  sp::proj4string(lnglat) <- sp::CRS("+proj=longlat +datum=WGS84")
  return(sp::spTransform(lnglat, sp::CRS("+proj=utm +zone=6"))@coords)
}

#' Pad Objects with Leading Zeros
#' 
#' @param x Objects to pad.
#' @param width Minimum number of characters desired.
zeropad <- function(x, width = 2) {
  x <- as.character(x)
  nchars <- sapply(x, nchar)
  for (i in which(nchars < width)) {
    nzeros <- width - nchars[i]
    x[i] <- paste(c(as.character(rep(0, nzeros)), x[i]), collapse = "")
  }
  return(x)
}

# ---- Load markers ----

header_lines <- c(
  "sources/CG_160608A.xls" = 9,
  "sources/CG_170608.xlsx" = 5,
  "sources/CG_180608A.xls" = 5,
  "sources/CG_190608.xls" = 4,
  "sources/CG_190608A.xls" = 11
)

results <- lapply(names(header_lines), function(filename) {
  df <- readxl::read_excel(filename, skip = header_lines[filename])
  df <- df[!is.na(df$E), ]
  names(df)[1] <- "Target"
  data.frame(
    # Use single digit integer
    marker = floor(as.numeric(df$Target) / 1000),
    # Convert vector to ISO8601 date time
    t = as.POSIXct(paste("2008", zeropad(df$Month), zeropad(df$Day), zeropad(df$Hr), zeropad(df$Min)), format = "%Y %m %d %H %M", tz = "UTC"),
    x = df$E,
    y = df$N,
    z = df$Z
  )
})

# ---- Extrapolate missing times ----

# Choose reference marker
marker <- 1
# Marker velocity
df <- do.call("rbind", results)
mdf <- df[df$marker == marker, ]
has_time <- !is.na(mdf$t)
dt <- diff(mdf$t[has_time])
units(dt) <- "secs"
dxy <- sqrt(rowSums(diff(as.matrix(mdf[has_time, c("x", "y")]))^2))
v <- dxy / as.numeric(dt) # m / s

# Assign times to the timeless
# NOTE: Assumes constant velocity during gaps, 15 minute intervals (sources/README.doc), and 45 seconds between sightings.
for (i in 3:1) {
  temp <- results[[i]]
  if (i < 3) {
    n_marker <- sum(temp$marker == marker)
    xy_begin <- temp[temp$marker == marker, ][n_marker, c("x", "y")]
    dxy <- sqrt(sum((xy_end - xy_begin)^2))
    dt <- dxy / median(v) # s
    t_begin <- t_end - dt
    t <- round(rev(seq(t_begin, by = -15 * 60, length.out = n_marker)), "mins")
    for (m in unique(temp$marker)) {
      dm <- m - marker
      results[[i]][temp$marker == m, "t"] <- as.POSIXct(round(t + (45 * dm), "mins"))
    }
  }
  if (i > 1) {
    t_end <- results[[i]][temp$marker == marker, ][1, "t"]
    xy_end <- temp[temp$marker == marker, ][1, c("x", "y")] 
  }
}

# ---- Shift marker 2 ----

# Marker 2 has strange backward motion:
df <- do.call("rbind", results)
plot(df[df$marker == 2, c("x", "y")])

# Shift sightings before break (using marker 1 as reference)
temp <- results[[3]]
xy_end <- results[[3]][which(temp$marker == 2)[1], c("x", "y")]
xy_end_ref <- results[[3]][which(temp$marker == 1)[1], c("x", "y")]
temp <- results[[2]]
xy_begin <- results[[2]][rev(which(temp$marker == 2))[1], c("x", "y")]
xy_begin_ref <- results[[2]][rev(which(temp$marker == 1))[1], c("x", "y")]
dxy <- as.numeric(xy_end - xy_begin) - as.numeric(xy_end_ref - xy_begin_ref)
for (i in 2:1) {
  temp <- results[[i]]
  results[[i]][temp$marker == 2, c("x", "y")] <- sweep(temp[temp$marker == 2, c("x", "y")], 2, dxy, FUN = "+")
}

# Plot results
df <- do.call("rbind", results)
plot(df[df$marker == 2, c("x", "y")])

# ---- Merge results ----

df <- do.call("rbind", results)

# ---- Sort by marker, then time ----

df <- df[order(df$marker, df$t), ]

# ---- Format time as ISO8601 date time ----

# NOTE: Time zone is unknown.
df$t <- format(df$t, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC")

# ---- Convert local to world coordinates (xy) ----

# Gun local coordinates (sources/CG_*.xls)
gun_local <- c(5000, 5000, 1000)
# Gun world coordinates ("theodolite" in GPS/2009/May09/coords09_v2.csv as WGS84 Lng, Lat, HAE)
# NOTE: Confirmed by marking "0809 Gun" in sources/AK03b.JPG and the gun in sources/AK03b_20080621_171611.JPG.
gun <- c(-(147 + 3 / 60 + 21.55927 / 3600), 61 + 7 / 60 + 12.59914 / 3600, 145.654)
gun[1:2] <- lnglat_to_utm(gun[1:2])
# Reference world coordinates ("CCFG004" in GPS/2009/May09/coords09_v2.csv as WGS84 Lng, Lat, HAE)
# NOTE: Educated guess based on distance and angle readings. Possibly supported by disturbance at CCFG004 (see marking "CCFG004" in sources/AK03.JPG) between sources/AK03_20080617_011901.JPG and sources/AK03_20080617_021901.JPG.
# CCFG004
ref <- c(-(147 + (3 / 60) + 22.57151 / 3600), 61 + 7 / 60 + 12.04316 / 3600, 145.392)
ref[1:2] <- lnglat_to_utm(ref[1:2])
# Local coordinates relative to gun
dxy <- sweep(as.matrix(df[c("x", "y")]), 2, gun_local[1:2], FUN = "-")
# Align with UTM axes
# NOTE: Need rotation counterclockwise relative to -y (see sources/CG_*.xls). Adjustment (+pi/2) needed since atan2 relative to +x.
theta <- atan2(ref[2] - gun[2], ref[1] - gun[1]) + pi / 2
R <- matrix(c(cos(theta), sin(theta), -sin(theta), cos(theta)), nrow = 2, byrow = TRUE)
xy <- sweep(dxy %*% R, 2, gun[1:2], FUN = "+")
# Save result
df[c("x", "y")] <- xy

# ---- Plot results ----

plot(df[df$marker == 1, c("x", "y")], xlim = range(c(df$x, gun[1])), ylim = range(c(df$y, gun[2])), asp = 1)
points(df[df$marker == 2, c("x", "y")], col = "red")
points(df[df$marker == 3, c("x", "y")], col = "green")
points(gun[1], gun[2], col = "red")
term <- rgdal::readOGR("/users/admin/desktop/temp/terminus", "terminus")
ind <- grepl("^2007|^2008", term@data$DATE)
sp::plot(term[ind, ], add = TRUE)

# ---- Convert local to world coordinates (z) ----

df$z <- gun[3] - (gun_local[3] - df$z)

# ---- Save results ----

write.csv(df, "data/markers.csv", na = "", quote = FALSE, row.names = FALSE)
