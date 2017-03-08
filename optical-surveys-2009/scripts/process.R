# ---- Install missing dependencies ----

packages <- c("readxl")
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
#' @param xy NAD27 Zone 6N UTM coordinates.
#' @return WGS84 Zone 6N UTM coordinates.
lnglat_to_utm <- function(lnglat) {
  current_proj4 <- sp::CRS("+proj=longlat +datum=WGS84")
  target_proj4 <- sp::CRS("+proj=utm +zone=6 +datum=WGS84")
  lnglat <- if (is.vector(lnglat)) t(lnglat) else lnglat
  xy <- data.frame(x = lnglat[, 1], y = lnglat[, 2])
  sp::coordinates(xy) <- c("x", "y")
  sp::proj4string(xy) <- current_proj4
  return(sp::spTransform(xy, target_proj4)@coords)
}

# ---- Read source data ----

filename <- "sources/CGSurvey_DataSummary.xls"
df <- readxl::read_excel(filename, sheet = "Sheet1", skip = 5)[, 1:4]
names(df) <- c("day", "x", "y", "z")

# ---- Format time field ----

df$t <- julian_day_to_datetime(df$day)

# ---- Write result ----

write.csv(df[, c("t", "x", "y", "z")], "data/positions.csv", row.names = FALSE, quote = FALSE, na = "")