# ---- Install missing dependencies ----

packages <- c("httr", "jsonlite")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# ---- Load functions ----

#' Get CWMS Metadata for Locations
#'
#' @param db_office_id Office id.
#' @param unit_system Locations usually has two database representations, one for each unit system ('SI': International System of Units, 'EN': English units).
#' @references Parsed from API calls (\url{http://www.gadom.ski/cwms-jsonapi/}) mimicking those made by \url{http://glacierresearch.com/}.
get_cwms_locations <- function(db_office_id = "NAE", unit_system = c("SI", "EN")) {
  url <- "https://reservoircontrol.usace.army.mil/NE/pls/cwmsweb/cwms_web.jsonapi.locations"
  query <- list(db_office_id = match.arg(db_office_id), unit_system = match.arg(unit_system))
  response <- httr::GET(url, query = query)
  json <- jsonlite::fromJSON(rawToChar(response$content))
}

#' Get CWMS Metadata for Timeseries at Location
#'
#' @param location_id Location id.
#' @references Parsed from API calls (\url{http://www.gadom.ski/cwms-jsonapi/}) mimicking those made by \url{http://glacierresearch.com/}.
get_cwms_timeseries <- function(location_id) {
  url <- "https://reservoircontrol.usace.army.mil/NE/pls/cwmsweb/cwms_web.jsonapi.timeseries"
  query <- list(location_id = location_id)
  response <- httr::GET(url, query = query)
  json <- jsonlite::fromJSON(rawToChar(response$content))
}

#' Get CWMS Timeseries Data
#'
#' @param ts_codes Timeseries codes. If multiple are specified, the values for each are averaged together by timestamp.
#' @param summary_interval Time interval over which the data are resampled through averaging. If \code{"none"} or \code{NULL}, the raw data is returned.
#' @param floor Minimum value below which values are dropped. Useful in combination with \code{summary_interval}, since timeseries are averaged before resampling.
#' @references Parsed from API calls (\url{http://www.gadom.ski/cwms-jsonapi/}) mimicking those made by \url{http://glacierresearch.com/}.
get_cwms_timeseries_data <- function(ts_codes, summary_interval = c("none", "hourly", "daily", "weekly", "monthly"), floor = NULL) {
  url <- "https://reservoircontrol.usace.army.mil/NE/pls/cwmsweb/cwms_web.jsonapi.timeseriesdata"
  query <- list(ts_codes = paste(ts_codes, sep = ","), summary_interval = match.arg(summary_interval), floor = floor)
  response <- httr::GET(url, query = query)
  # Valid format for negative numbers
  char <- gsub(":([\\-]*)\\.", ":\\10.", rawToChar(response$content))
  json <- jsonlite::fromJSON(char)
}

# ---- Get data ----

location_id <- "COL"

# Location metadata
locations <- get_cwms_locations(db_office_id = "NAE", unit_system = "SI")
location <- locations[locations$location_id == location_id, ]

# Timeseries metadata
timeseries <- get_cwms_timeseries(location_id)

# Timeseries data
data_1 <- get_cwms_timeseries_data(timeseries$ts_code[1], summary_interval = "hourly")

for (ts_code in timeseries)
ts_data <- lapply(timeseries$ts_code, get_cwms_timeseries_data, summary_interval = NULL, floor = NULL)

# url <- "http://glacierresearch.com/locations/columbia/data/timeseries.json"
# response <- httr::GET(url)
# inventory <- jsonlite::fromJSON(rawToChar(response$content))
# ts_codes <- na.omit(unlist(c(inventory$ts_codes, sapply(inventory$series, "[[", "ts_codes"))))


# ts_codes: [string, required] a comma-delimited list of ts codes to fetch. If more than one ts code is provided, the values for each ts code will be averaged together by timestamp. The timestamp interval can be controlled by summary_interval.
# summary_interval: [string, default = ''] a time interval over which the data will be averaged. Valid values include:
#   hourly
# daily
# weekly
# monthly
# If no value is specified, or an invalid value is passed, the data are not summarized.
# floor: [number, default = NULL] if specified, will drop all timeseries values less than the floor value. Useful mostly in combination with summary_interval, since these values are dropped before data aggregation.
#

# [{
#   "name": "Relative humidity",
#   "ts_codes": 15110021,
#   "units": "%",
#   "visible": false,
#   "color": "#535860",
#   "min": 0,
#   "max": 100
# }, {
#   "name": "Wind speed",
#   "series": [{
#     "name": "Sensor 1",
#     "ts_codes": 15111021,
#     "color": "#FA40FF"
#   }, {
#     "name": "Sensor 2",
#     "ts_codes": 15113021,
#     "color": "#9D369B"
#   }],
#   "units": "kph",
#   "visible": false,
#   "min": 0
# }, {
#   "name": "Wind direction",
#   "series": [{
#     "name": "Sensor 1",
#     "ts_codes": 15112021,
#     "color": "#FA40FF",
#     "circular": true
#   }, {
#     "name": "Sensor 2",
#     "ts_codes": 15114021,
#     "color": "#942191",
#     "circular": true
#   }],
#   "units": "deg",
#   "visible": false,
#   "min": 0,
#   "max": 360
# }, {
#   "name": "Pressure",
#   "ts_codes": 15115021,
#   "units": "kPa",
#   "visible": false,
#   "color": "#AA7A41",
#   "min": 0,
#   "max": 105
# }, {
#   "name": "Voltage",
#   "ts_codes": 15116021,
#   "units": "volt",
#   "visible": false,
#   "color": "#FA2908",
#   "min": 0
# }, {
#   "name": "Air temperature",
#   "series": [{
#     "name": "Sensor 1",
#     "ts_codes": 15108021,
#     "color": "#51A7F9"
#   }, {
#     "name": "Sensor 2",
#     "ts_codes": 15109021,
#     "color": "#0432FC"
#   }],
#   "visible": true,
#   "units": "°C",
#   "max": 30
# }]
