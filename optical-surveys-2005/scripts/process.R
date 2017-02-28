# http://web.archive.org/web/20130905025856/http://surveying.wb.psu.edu/sur351/DatumTrans/datum_transformations.htm

# Install missing dependencies
packages <- c("readxl")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# ---- Markers 1, 3, 4 (June 2005) ----

# Load files
filenames <- c(
  "sources/coord_trans/mk111.txt",
  "sources/coord_trans/mk333.txt",
  "sources/coord_trans/mk444.txt"
)

results <- lapply(filenames, function(filename) {
  df <- read.table(filename)
  # Assign columns (sources/coord_trans/survey_coord_trans.m)
  names(df) <- c("id", "day", "x", "y", "z")
  return(df)
})

# ---- Marker 2 (June 2005) ----

filename <- "sources/data_reduction/surveys_reduced_6_05.xls"
temp <- readxl::read_excel(filename, sheet = "Sheet1", skip = 7)
names(temp) <- make.names(names(temp), unique = TRUE)
df <- temp[!is.na(temp$Marker) & temp$Marker == 222, c("Marker", "Tavg.1", "Ereduced", "Nreduced", "Z")]
names(df) <- c("id", "day", "x", "y", "z")
results <- c(results, list(df))

# ---- Marker 5 (September 2005) ----

filename <- "sources/CG_2005SurveyData_Shad/SeptSurveyMatlabIn.xls"
temp <- readxl::read_excel(filename, sheet = "ExportMatlab")
df <- temp[, c("Tavg", "Ereduced", "Nreduced", "Z")]
df <- cbind(555, df)
names(df) <- c("id", "day", "x", "y", "z")
results <- c(results, list(df))

# ---- Merge results ----

df <- do.call("rbind", results)

# ---- Simplify marker identifers ----

# Use single digit integer
df$id <- floor(df$id / 100)

# ---- Convert decimal day to datetime ----

# Convert day to date time (matches sources/data_reduction/surveys_reduced_6_05.xls)
origin <- strptime("2004-12-31 00:00:00", "%Y-%m-%d %H:%M:%S", tz = "UTC")
df$t <- format(as.POSIXlt(df$day * (60 * 60 * 24), tz = "UTC", origin = origin), "%Y-%m-%d %H:%M:%S")

# Calving events
# sources/coord_trans/marker_tracklines.m => sources/coord_trans/big_calves_lines.txt
days <- unique(read.table("sources/coord_trans/big_calves_lines.txt")[, 1])
origin <- strptime("2004-12-31 00:00:00", "%Y-%m-%d %H:%M:%S", tz = "UTC")
format(as.POSIXlt(days * (60 * 60 * 24), tz = "UTC", origin = origin), "%Y-%m-%d %H:%M:%S")
# sources/coord_trans/biggest_events.txt
events <- read.table("sources/coord_trans/biggest_events.txt")
events$time <- format(as.POSIXlt(events$V4 * (60 * 60 * 24), tz = "UTC", origin = origin), "%Y-%m-%d %H:%M:%S")
# times are in ADT (UTC-8) if calving catalog (Astrom et al.) is in UTC!

# ---- Convert local to world coordinates ----

# Terminus
# CONCLUSION: NAD27
# Terminus (sources/coord_trans/terminus_178_04.txt) used (sources/coord_trans/marker_tracklines.m) may be average of two 2004 terminus positions, given date suggested by filename:
origin <- strptime("2003-12-31 00:00:00", "%Y-%m-%d %H:%M:%S", tz = "UTC")
format(as.POSIXlt(178 * (60 * 60 * 24), tz = "UTC", origin = origin), "%Y-%m-%d %H:%M:%S")
mean(c(as.Date('2004-06-18'), as.Date('2004-07-07')))
# Best matches those terminus traces if converted to NAD27
term <- rgdal::readOGR(dsn = path.expand("~/desktop/terminus"), layer = "terminus")
term <- sp::spTransform(term, sp::CRS("+proj=utm +zone=6 +ellps=clrk66 +towgs84=-5,135,172 +units=m +no_defs"))
ind <- term@data$DATE == 20040618 | term@data$DATE == 20040707
plot(term[ind, ])
term <- read.table("sources/coord_trans/terminus_178_04.txt")
lines(term, col = 'red')

# Gun local coordinates (sources/data_reduction/surveys_reduced_6_05.xls)
gun_local <- c(5000, 5000, 1000)
# Gun and reference coordinates (sources/coord_trans/survey_coord_trans.m)
gun <- c(497126.859, 6775852.739, 0) # -147.0554716 61.11859955 : GPS/2005/ROVER/03011570.dat, (03011610.dat)
ref <- c(497126.388, 6775984.429, 0) # -147.0554824 61.11978182 : GPS/2005/ROVER/03011571.dat

xy <- data.frame(x = gun[1], y = gun[2])
sp::coordinates(xy) <- c("x", "y")
sp::proj4string(xy) <- sp::CRS("+proj=utm +zone=6 +ellps=clrk66 +towgs84=-5,135,172 +units=m +no_defs")
sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +datum=WGS84"))

xy <- data.frame(x = ref[1], y = ref[2])
sp::coordinates(xy) <- c("x", "y")
sp::proj4string(xy) <- sp::CRS("+proj=utm +zone=6 +ellps=clrk66 +towgs84=-5,135,172 +units=m +no_defs")
sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +datum=WGS84"))

xy <- data.frame(x = gun[1], y = gun[2])
sp::coordinates(xy) <- c("x", "y")
sp::proj4string(xy) <- sp::CRS("+proj=utm +zone=6 +datum=WGS84")
sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +datum=WGS84"))

xy <- data.frame(x = ref[1], y = ref[2])
sp::coordinates(xy) <- c("x", "y")
sp::proj4string(xy) <- sp::CRS("+proj=utm +zone=6 +datum=WGS84")
sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +datum=WGS84"))

# BASE (GPS/2004/coords_out_sept13.xls)
base_lat <- 61 + 7 / 60 + 17.80430 / 3600
base_lng <- -(147 + 2 / 60 + 53.15913 / 3600)
base_h <- 269.467
xy <- data.frame(x = base_lng, y = base_lat)
sp::coordinates(xy) <- c("x", "y")
sp::proj4string(xy) <- sp::CRS("+proj=longlat +datum=WGS84")
temp <- sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +datum=WGS84"))
print(temp@coords, digits = 10)

# BBB ()
lat <- 61 + 7 / 60 + 14.07942 / 3600
lng <- -(147 + 3 / 60 + 2.75583 / 3600)
xy <- data.frame(x = lng, y = lat)
sp::coordinates(xy) <- c("x", "y")
sp::proj4string(xy) <- sp::CRS("+proj=longlat +datum=WGS84")
temp <- sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +datum=WGS84"))
print(temp@coords, digits = 10)

# 03011570.dat
xy <- data.frame(x = -147.055482, y = 61.118632)
# 03011571.dat
xy <- data.frame(x = -147.055510, y = 61.119802)
# 03011610.dat
xy <- data.frame(x = -147.055470, y = 61.118565)

xy <- data.frame(x = gun[1], y = gun[2])
sp::coordinates(xy) <- c("x", "y")
sp::proj4string(xy) <- sp::CRS("+proj=utm +zone=6 +ellps=clrk66 +towgs84=-5,135,172 +units=m +no_defs")
sp::proj4string(xy) <- sp::CRS("+proj=utm +zone=6 +datum=WGS84")

temp <- sp::spTransform(xy, sp::CRS("+proj=longlat +datum=WGS84"))
temp <- sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +datum=WGS84"))
temp <- sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +datum=NAD83"))
temp <- sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +datum=NAD27"))
temp <- sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +ellps=clrk66 +towgs84=-5,135,172 +units=m +no_defs"))
temp <- sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +ellps=GRS80 +towgs84=0,0,0 +units=m +no_defs"))
print(temp@coords, digits = 10)

# GPS/2009/May09/coords09_v2.CSV
base_latlng <- c(-(147 + 2 / 60 + 53.15913 / 3600), 61 + 7 / 60 + 17.80430 / 3600, 269.598)
base_nad27 <- c(497524.325, 6776188.004, 265.306)
gun_latlng <- c(-(147 + 3 / 60 + 21.55927 / 3600), 61 + 7 / 60 + 12.59914 / 3600, 145.654)
gun_nad27 <- c(497099.142, 6776027.292, 141.354)
# GPS/2009/CG09/Reports/recompute/recompute.html
# (base same above, for gun UTM and latlng don't quite match up)
# gun_latlng <- c(-147.056022649, 61.120154123, 141.742)
# gun_nad27 <- c(497099.142, 6776027.292, 141.354)
# base_latlng <- c(-147.048099758, 61.121612306, 269.598)
# base_nad27 <- c(497524.325, 6776188.004, 265.306)

xy <- data.frame(x = gun_latlng[1], y = gun_latlng[2])
sp::coordinates(xy) <- c("x", "y")
sp::proj4string(xy) <- sp::CRS("+proj=longlat +datum=WGS84")
sp::spTransform(xy, sp::CRS("+proj=utm +zone=6"))
# sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +ellps=clrk66 +datum=NAD27"))
sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +ellps=clrk66 +towgs84=-5,135,172 +units=m +no_defs"))



# sp::spTransform(xy, sp::CRS("+proj=utm +zone=6"))
# sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +ellps=clrk66 +datum=NAD27"))
temp <- sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +ellps=clrk66 +towgs84=-5,135,172 +units=m +no_defs"))
print(temp@coords, digits = 12)


theta <- atan((ref[1] - gun[1]) / (ref[2] - gun[2]));
R <- matrix(c(cos(theta), sin(theta), -sin(theta), cos(theta)), nrow = 2, byrow = TRUE)


# %% Convert local to WGS84 UTM coordinates
#
# % Gun and reference coordinates (NAD27?)


#
# % Transform data
# % NOTE: Results differ from Shad O'Neel, who (incorrectly?) rotated local vectors relative to (5000, 5000) origin.
# data = readtable('data/markers.local.csv');
# utm = fliplr((R * [data.y, data.x]')') + gun;
# data.x = utm(:, 1);
# data.y = utm(:, 2);
# writetable(data, 'data/markers.utm.csv');
#
# %% Plot data
# data = readtable('data/markers.utm.csv');
# [Z, ~, bbox] = geotiffread('/Volumes/Science/data/columbia/_new/ArcticDEM/tiles/merged_projected_clipped.tif');
# dem = DEM(Z, bbox(:, 1), flip(bbox(:, 2)));
# figure
# dem.plot(2); hold on
# for i = unique(data.id)'
# ind = data.id == i;
# plot(data.x(ind), data.y(ind), '.')
# end
