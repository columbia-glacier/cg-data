install.packages(c("sp", "rgdal"))

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
lat <- (as.numeric(df$lat_deg) + as.numeric(df$lat_min) / 60 + as.numeric(df$lat_sec) / 3600) * ifelse(df$lat_dir == "N", 1, -1)
lng <- (as.numeric(df$lng_deg) + as.numeric(df$lng_min) / 60 + as.numeric(df$lng_sec) / 3600) * ifelse(df$lng_dir == "E", 1, -1)
xy <- data.frame(x = lng, y = lat)
sp::coordinates(xy) <- c("x", "y")
sp::proj4string(xy) <- sp::CRS("+proj=longlat +datum=WGS84")
sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +datum=NAD27"))

# Convert to utm

rgdal::project(cbind(lng, lat), proj = "+proj=utm +zone=6 +ellps=WGS84")

# Sort by time
df <- df[order(df$id), ]

data.table::rbindlist()
df <- read.table(filename, header = FALSE, fileEncoding = "latin1", stringsAsFactors = FALSE, sep = ",")

# ---- Long track ----