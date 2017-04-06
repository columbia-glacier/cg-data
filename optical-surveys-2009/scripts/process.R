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
names(df) <- c("day", "x", "y", "z")

# ---- Format time field ----

df$t <- julian_day_to_datetime(df$day)

# ---- Convert local to world coordinates ----

# gun: "theodolite" in 2009 GPS survey (GPS/2009/May09/coords09_v2.csv)
# Determined from from cameras AK03 and AK03b
gun <- c(-(147 + 3 / 60 + 21.55927 / 3600), 61 + 7 / 60 + 12.59914 / 3600, 145.654)
gun_utm <- c(lnglat_to_utm(gun[1:2]), gun[3])
# ref(erence): "CCFG004"
# GPS/2009/May09/coords09_v2.csv
ref <- c(-(147 + (3 / 60) + 22.57151 / 3600), 61 + 7 / 60 + 12.04316 / 3600, 145.392)
ref_utm <- c(lnglat_to_utm(ref[1:2]), ref[3])


# "Assuming the theodolite was at "theodolite", and noting that the reference has to have been ~23 m SW of the theodolite (given the survey sightings), I'm wondering if it wasn't "CCFG004". Map with 23 m circle shown below." (Ethan)
# CCFG004, BIPOD2, BIPOD3



# % Transform data
# % NOTE: Results differ from Shad O'Neel, who (incorrectly?) rotated local vectors relative to (5000, 5000) origin.
# data = readtable('data/markers.local.csv');
# utm = fliplr((R * [data.y, data.x]')') + gun;
# data.x = utm(:, 1);
# data.y = utm(:, 2);
# writetable(data, 'data/markers.utm.csv');


# ---- Write result ----

write.csv(df[, c("t", "x", "y", "z")], "data/positions.csv", row.names = FALSE, quote = FALSE, na = "")