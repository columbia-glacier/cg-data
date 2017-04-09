# ---- Install missing dependencies ----

packages <- c("readxl", "sp")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# ---- Load functions ----

#' Convert 2009 Julian Day to Date Time
#' 
#' "In my field book, there is a note from May 9 2009 that says the gun was restarted at 8:58 local or 16:57 UTC" (Shad O'Neel, email: 2017-02-14).
#' The first measurement was made 2009-05-09 16:55 (sources/CGSurveyMay2009.xlsx, Sheet "1 CG09-D2_Part2"), so reported times are in UTC.
#' 
#' @param julian_day Julian day of 2009 in UTC.
#' @return ISO 8601 date time in UTC.
#' @examples
#' julian_day_to_datetime(129.7048611) == "2009-05-09T16:54:59Z"
julian_day_to_datetime <- function(julian_day) {
  origin <- strptime("2008-12-31 00:00:00", "%Y-%m-%d %H:%M:%S", tz = "UTC")
  datetime <- format(as.POSIXlt(julian_day * (60 * 60 * 24), tz = "UTC", origin = origin), "%Y-%m-%dT%H:%M:%SZ")
  return(datetime)
}

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

# ---- Read source data ----

filename <- "sources/CGSurvey_DataSummary.xls"
df <- readxl::read_excel(filename, sheet = "Sheet1", skip = 5)[, 1:4]
names(df) <- c("t", "x", "y", "z")

# ---- Format time field ----

df$t <- julian_day_to_datetime(df$t)

# ---- Convert local to world coordinates ----

# Gun local coordinates (sources/CGSurveyMay2009.xlsx)
gun_local <- c(5000, 5000, 1000)
# Gun world coordinates ("theodolite" in GPS/2009/May09/coords09_v2.csv as WGS84 Lng, Lat, HAE)
# NOTE: Confirmed by marking "0809 Gun" in sources/AK03b.JPG and the gun in sources/AK03b_20090507_202214.JPG.
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
# NOTE: Need rotation counterclockwise relative to +y. Adjustment (pi/2) needed since atan2 relative to +x.
theta <- atan2(ref[2] - gun[2], (ref[1] - gun[1])) - pi / 2
R <- matrix(c(cos(theta), sin(theta), -sin(theta), cos(theta)), nrow = 2, byrow = TRUE)
xy <- sweep(dxy %*% R, 2, gun[1:2], FUN = "+")
# Save result
df[c("x", "y")] <- xy

# # Reference world coordinates
# warning("Unknown reference, skipping coordinate rotation.")
# # Shift coordinates relative to gun
# dxyz <- gun - gun_local
# xyz <- sweep(as.matrix(df[c("x", "y", "z")]), 2, dxyz, FUN = "+")
# # Save result
# df[c("x", "y", "z")] <- xyz

# ---- Plot results ----

plot(df[c("x", "y")], xlim = range(c(df$x, gun[1])), ylim = range(c(df$y, gun[2])), asp = 1)
points(gun[1], gun[2], col = "red")
term <- rgdal::readOGR("/users/admin/desktop/temp/terminus", "terminus")
ind <- grepl("^2009", term@data$DATE)
sp::plot(term[ind, ], add = TRUE)

# ---- Write result ----

write.csv(df[, c("t", "x", "y", "z")], "data/markers.csv", row.names = FALSE, quote = FALSE, na = "")