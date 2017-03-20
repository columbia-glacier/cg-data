# ---- Install missing dependencies ----

packages <- c()
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# ---- Load functions ----

# https://www.ncdc.noaa.gov/cdo-web/token
# Email:	ethan.welty@gmail.com
# Token:	xhdqpttPpqmQpgGRkrEbzbggFBPEENMV
options(noaakey = "xhdqpttPpqmQpgGRkrEbzbggFBPEENMV")
stations <- rnoaa::ncdc_stations()
stations <- rnoaa::ncdc_stations()

# https://www.ncdc.noaa.gov/cdo-web/api/v2/stations
