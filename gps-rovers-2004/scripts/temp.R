## BASE

# GPS/2004/CG227-end/Reports/recompute/recompute.html
lat <- 61 + 7 / 60 + 17.80430 / 3600
lng <- -(147 + 2 / 60 + 53.15913 / 3600)

## ICE1_0194

# GPS/2004/200-212/Reports/recompute/recompute.html
lat <- 61 + 10 / 60 + 27.60630 / 3600
lng <- -(146 + 57 / 60 + 42.60075 / 3600)
h <- 338.994
nad27 <- c(502168.522, 6782061.250, 339.617)
dat <- "10002001.dat"

# CG_2004_GPS_out.xls
lat <- 61 + 10 / 60 + 27.63746 / 3600
lng <- -(146 + 57 / 60 + 42.62143 / 3600)
h <- 343.771
nad27 <- c(502168.522, 6782061.25, 339.617)
t <- "2004-07-18	18:00:17"

# GPS/2004/200-212/Data Files/Trimble Files/10002001.dat

# start date & time:       2004-07-19 00:00:30.000
# final date & time:       2004-07-19 00:30:00.000

## ICE1_0297

# GPS/2004/213-227/Reports/recompute/recompute.html
lat <- 61 + 10 / 60 + 26.70594 / 3600
lng <- -(146 + 57 / 60 + 45.35879 / 3600)
h <- 343.139
nad27 <- c(502128.969, 6782034.402, 337.827)
dat <- "10002131.dat"

# CG_2004_GPS_out.xls
lat <- 61 + 10 / 60 + 26.77048 / 3600
lng <- -(146 + 57 / 60 + 45.26968 / 3600)
h <- 341.982
nad27 <- c(502128.969, 6782034.402, 337.827)
t <- "2004-07-31	18:00:17"

# GPS/2004/213-227/Data Files/Trimble Files/10002131.dat

# start date & time:       2004-08-01 00:00:30.000
# final date & time:       2004-08-01 00:30:00.000

## ICE1_0410

# GPS/2004/CG227-end/Reports/recompute/recompute.html
lat <- 61 + 10 / 60 + 25.93085 / 3600
lng <- -(146 + 57 / 60 + 48.00672 / 3600)
h <- 339.7
nad27 <- c(502089.060, 6782007.382, 335.729)
dat <- "10002285.dat"

# CG_2004_GPS_out.xls
lat <- 61 + 10/60 + 25.89795/3600
lng <- -(146 + 57 / 60 + 47.94166/3600)
h <- 339.885
nad27 <- c(502089.060, 6782007.382, 335.729)
t <- "08-14-2004	21:00:17" # (227)

# GPS/2004/CG227-end/Data Files/Trimble Files/10002285.dat

# start date & time:       2004-08-15 03:00:30.000
# final date & time:       2004-08-15 03:30:00.000

## ICE1_1

# cg_ice2.CSV
lat <- 61 + 10 / 60 + 29.64308 / 3600
lng <- -(146 + 57 / 60 + 36.62762 / 3600)
h <- 347.687
nad27 <- c(502279.791, 6782112.669, 346.004)
t <- "2004-06-21 12:00:17"

# glac0001.DAT
# start date & time: 2004-06-22 00:00:30.000
# final date & time: 2004-06-22 01:00:00.000

## Coordinate transformation

xy <- data.frame(x = lng, y = lat)
sp::coordinates(xy) <- c("x", "y")
sp::proj4string(xy) <- sp::CRS("+proj=longlat +datum=WGS84")
sp::spTransform(xy, sp::CRS("+proj=utm +zone=6"))
sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +ellps=clrk66 +datum=NAD27"))
temp <- sp::spTransform(xy, sp::CRS("+proj=utm +zone=6 +ellps=clrk66 +towgs84=-5,135,172 +units=m +no_defs"))
print(temp@coords, digits = 12)

# http://web.archive.org/web/20130905025856/http://surveying.wb.psu.edu/sur351/DatumTrans/datum_transformations.htm


