# ---- Install missing dependencies ----

packages <- c("rgdal", "readxl")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# ---- Load functions ----

#' Convert Lng,Lat Degree/Minute/Second to Decimal Degrees
#'
#' @param lng_deg,lat_deg Degrees of longitude and latitude.
#' @param lng_min,lat_min Minutes of longitude and latitude.
#' @param lng_sec,lat_sec Seconds of longitude and latitude.
#' @param lng_dir,lat_dir Directions of longitude ("E": East, "W": West) and latitude ("N": North, "S", South).
#' @return Longitude and latitude as decimal degrees.
#' @examples
#' lnglat_dms_to_ddeg(140, 10, 60, "W", 61, 0, 0, "N")
lnglat_dms_to_ddeg <- function(lng_deg, lng_min, lng_sec, lng_dir = "E", lat_deg, lat_min, lat_sec, lat_dir = "N") {
  lng <- (as.numeric(lng_deg) + as.numeric(lng_min) / 60 + as.numeric(lng_sec) / 3600) * ifelse(lng_dir == "E", 1, -1)
  lat <- (as.numeric(lat_deg) + as.numeric(lat_min) / 60 + as.numeric(lat_sec) / 3600) * ifelse(lat_dir == "N", 1, -1)
  return(cbind(lng, lat))
}

#' Convert Start Time of Occupations to UTC Ranges
#' 
#' The given times (e.g. sources/cg_ice2.CSV, CG_2004_GPS_out.xls) are erroneously in UTC-6. This was determined through comparisons to the GPS times in the original Trimble data files. The GPS-UTC offset, 13 s in 2004 (\url{https://confluence.qps.nl/display/KBE/UTC+to+GPS+Time+Correction}), is already applied.
#' 
#' @param start_times Start times of occupation (as UTC-6).
#' @param minutes_occupied Length of occupation (in minutes).
#' @param format Format of \code{begin_times} (see \code{\link{strptime}}).
#' @return Begin and end times of occupation in UTC.
#' @examples
#' start_times_to_utc_range("06-21-2004 12:00:17", minutes_occupied = 59.5) == c("2004-06-21T18:00:17Z", "2004-06-21T18:59:47Z")
#' start_times_to_utc_range("06-24-2004 18:00:17", minutes_occupied = 29.5) == c("2004-06-25T00:00:17Z", "2004-06-25T00:29:47Z")
start_times_to_utc_range <- function(start_times, minutes_occupied, format = "%m-%d-%Y %H:%M:%S") {
  start_utc <- as.POSIXct(start_times, format = format, tz = "UTC") + (6 * 60 * 60)
  stop_utc <- start_utc + (minutes_occupied * 60)
  iso8601 <- "%Y-%m-%dT%H:%M:%SZ"
  return(cbind(format(start_utc, iso8601), format(stop_utc, iso8601)))
}

#' Extract Occupation Times from Trimble DAT Files
#' 
#' @param dat_files Paths to Trimble *.dat files.
#' @param teqc Path to the UNAVCO teqc binary (\url{https://www.unavco.org/software/data-processing/teqc/teqc.html}).
times_from_trimble_dat <- function(dat_files = list.files("*.dat", ignore.case = TRUE), teqc = "teqc") {
  dat_times <- t(sapply(dat_files, function(dat_file) {
    teqc <- "~/desktop/teqc"
    x <- system(paste0(teqc, " +meta '", dat_file, "'"), intern = TRUE, ignore.stderr = TRUE)
    gsub("^[^0-9]+", "", x[grepl("date & time", x)])
  }))
  return(dat_times)
}

# ---- Short track ----

## Load GPS rover positions
filename <- "sources/cg_ice2.CSV"
all_lines <- readLines(filename, encoding = "latin1")
df <- as.data.frame(matrix(unlist(strsplit(all_lines, "(, )|ø|'|\"")), nrow = length(all_lines), byrow = TRUE), stringsAsFactors = FALSE)
names(df) <- c("id", "date", "time", "x", "y", "z", "lat_deg", "lat_min", "lat_sec", "lat_dir", "lng_deg", "lng_min", "lng_sec", "lng_dir", "h")

## Format data
# Keep only ICE1 points
df <- df[grepl("ICE1", df$id), ]
# Compute lat,lng in decimal degrees
lnglat <- lnglat_dms_to_ddeg(df$lng_deg, df$lng_min, df$lng_sec, df$lng_dir, df$lat_deg, df$lat_min, df$lat_sec, df$lat_dir)
# Transform to UTM
xy <- rgdal::project(lnglat, proj = "+proj=utm +zone=6 +ellps=WGS84")
# Convert times to ISO 8601 datetime intervals
# UTC times verified against the GPS times in the Trimble files (GPS/ice/glac Folder/glac/*.dat).
# NOTE: Numbering of the .dat files is wrong. Correct order is 4, 1, 2 3, 5 ... 11 (12 is duplicate of 8)
t <- start_times_to_utc_range(paste(df$date, df$time), minutes_occupied = 59.5)
# Combine into new table
df <- data.frame(t_start = t[, 1], t_stop = t[, 2], x = xy[, 1], y = xy[, 2], z = df$h, stringsAsFactors = FALSE)
# Sort by time
df <- df[order(df$t_start), ]

## Clean data
# Second measurement is clearly wrong:
plot(df$x, df$y, pch = ""); text(df$x, df$y, as.character(1:nrow(df)))
# Discard second measurement
df <- df[-2, ]

## Save result
short <- df

# ---- Long track ----

## Load GPS rover positions
filename <- "sources/CG_2004_GPS_out.xls"
df <- readxl::read_excel(filename, sheet = "data", col_names = FALSE, col_types = NULL)
names(df) <- c("id", "date", "nday", "time", "dday", "x", "y", "z", "lat", "lng", "h")

## Format data
# Compute lat,lng in decimal degrees
lng <- strsplit(trimws(df$lng), "ø|'|\"")
lat <- strsplit(trimws(df$lat), "ø|'|\"")
lnglat <- t(sapply(seq_along(lng_vec), function(i) {
  lnglat_dms_to_ddeg(lng[[i]][1], lng[[i]][2], lng[[i]][3], lng[[i]][4], lat[[i]][1], lat[[i]][2], lat[[i]][3], lat[[i]][4])
}))
# Transform to UTM
xy <- rgdal::project(lnglat, proj = "+proj=utm +zone=6 +ellps=WGS84")
# Convert times to ISO 8601 datetime intervals
# UTC times verified against the GPS times in the Trimble files (GPS/ice/glac Folder/sess*/*.dat).
t <- start_times_to_utc_range(paste(df$date, df$time), minutes_occupied = 29.5)
# Combine into new table
df <- data.frame(t_start = t[, 1], t_stop = t[, 2], x = xy[, 1], y = xy[, 2], z = df$h, stringsAsFactors = FALSE)
# Sort by time
df <- df[order(df$t_start), ]

## Save result
long <- df

# ---- Merge tracks and write result ----

write.csv(rbind(short, long), "data/positions.csv", row.names = FALSE, quote = FALSE)
