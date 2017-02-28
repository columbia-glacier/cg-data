# Install missing dependencies
packages <- c("rgdal", "readxl")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# ---- Short track (1) ----

## Load GPS rover positions
filename <- "sources/cg_ice2.CSV"
all_lines <- readLines(filename, encoding = "latin1")
df <- as.data.frame(matrix(unlist(strsplit(all_lines, "(, )|ø|'|\"")), nrow = length(all_lines), byrow = TRUE), stringsAsFactors = FALSE)
names(df) <- c("id", "date", "time", "x", "y", "z", "lat_deg", "lat_min", "lat_sec", "lat_dir", "lng_deg", "lng_min", "lng_sec", "lng_dir", "h")

## Format data
# Keep only ICE1 points
df <- df[grepl("ICE1", df$id), ]
# Compute lat,lng in decimal degrees
lat <- (as.numeric(df$lat_deg) + as.numeric(df$lat_min) / 60 + as.numeric(df$lat_sec) / 3600) * ifelse(df$lat_dir == "N", 1, -1)
lng <- (as.numeric(df$lng_deg) + as.numeric(df$lng_min) / 60 + as.numeric(df$lng_sec) / 3600) * ifelse(df$lng_dir == "E", 1, -1)
# Transform to UTM
xy <- rgdal::project(cbind(lng, lat), proj = "+proj=utm +zone=6 +ellps=WGS84")
# Convert date,time to ISO 8601 datetime
t <- paste(format(strptime(df$date, "%m-%d-%Y"), "%Y-%m-%d"), format(strptime(df$time, "%H:%M:%S"), "%H:%M:%S"))
# Combine into new table
df <- data.frame(id = 1, t, x = xy[, 1], y = xy[, 2], z = df$h, stringsAsFactors = FALSE)
# Sort by time
df <- df[order(df$t), ]

## Save result
short <- df
# write.csv(df, "data/short.csv", row.names = FALSE, quote = FALSE)

# ---- Long track (2) ----

## Load GPS rover positions
filename <- "sources/CG_2004_GPS_out.xls"
df <- readxl::read_excel(filename, sheet = "data", col_names = FALSE, col_types = NULL)
names(df) <- c("id", "date", "nday", "time", "dday", "x", "y", "z", "lat", "lng", "h")

## Format data
# Compute lat,lng in decimal degrees
lat_vec <- strsplit(trimws(df$lat), "ø|'|\"")
lng_vec <- strsplit(trimws(df$lng), "ø|'|\"")
lat <- sapply(lat_vec, function(x) {
  (as.numeric(x[1]) + as.numeric(x[2]) / 60 + as.numeric(x[3]) / 3600) * ifelse(x[4] == "N", 1, -1)
})
lng <- sapply(lng_vec, function(x) {
  (as.numeric(x[1]) + as.numeric(x[2]) / 60 + as.numeric(x[3]) / 3600) * ifelse(x[4] == "E", 1, -1)
})
# Transform to UTM
xy <- rgdal::project(cbind(lng, lat), proj = "+proj=utm +zone=6 +ellps=WGS84")
# Convert date,time to ISO 8601 datetime
t <- paste(format(strptime(trimws(df$date), "%m-%d-%Y"), "%Y-%m-%d"), format(strptime(trimws(df$time), "%H:%M:%S"), "%H:%M:%S"))
# Combine into new table
df <- data.frame(id = 2, t, x = xy[, 1], y = xy[, 2], z = df$h, stringsAsFactors = FALSE)
# Sort by time
df <- df[order(df$t), ]

## Save result
long <- df

# ---- Merge tracks ----

write.csv(rbind(short, long), "data/positions.csv", row.names = FALSE, quote = FALSE)
