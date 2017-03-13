# ---- Install missing dependencies ----

packages <- c("httr")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# ---- Load functions ----

response <- httr::GET("http://glacierresearch.com/locations/columbia/data/timeseries.json")
json <- jsonlite::fromJSON(rawToChar(response$content))
ts_codes <- na.omit(unlist(c(json$ts_codes, sapply(json$series, "[[", "ts_codes"))))

# http://www.gadom.ski/cwms-jsonapi/
url <- "https://reservoircontrol.usace.army.mil/NE/pls/cwmsweb/cwms_web.jsonapi.timeseriesdata"
query <- list(ts_codes = 15110021, summary_interval = "monthly")
response <- httr::GET(url, query = query)
json <- jsonlite::fromJSON(rawToChar(response$content))

url <- "https://reservoircontrol.usace.army.mil/NE/pls/cwmsweb/cwms_web.jsonapi.loations"
query <- list(ts_codes = 15110021, summary_interval = "monthly")
response <- httr::GET(url, query = query)
json <- jsonlite::fromJSON(rawToChar(response$content))


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