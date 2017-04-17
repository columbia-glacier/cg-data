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
#' @references Parsed from API calls (\url{http://www.gadom.ski/cwms-jsonapi/}) mimicking those made by \url{http://glacierresearch.org/}.
get_cwms_locations <- function(db_office_id = "NAE", unit_system = c("SI", "EN")) {
  url <- "https://reservoircontrol.usace.army.mil/NE/pls/cwmsweb/cwms_web.jsonapi.locations"
  query <- list(db_office_id = match.arg(db_office_id), unit_system = match.arg(unit_system))
  response <- httr::GET(url, query = query)
  json <- jsonlite::fromJSON(rawToChar(response$content))
}

#' Get CWMS Metadata for Timeseries at Location
#'
#' @param location_id Location id.
#' @references Parsed from API calls (\url{http://www.gadom.ski/cwms-jsonapi/}) mimicking those made by \url{http://glacierresearch.org/}.
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
#' @param circular Whether to use circular (rather than regular) averaging (e.g. for wind direction).
#' @references Parsed from API calls (\url{http://www.gadom.ski/cwms-jsonapi/}) mimicking those made by \url{http://glacierresearch.org/}.
get_cwms_timeseries_data <- function(ts_codes, summary_interval = c("none", "hourly", "daily", "weekly", "monthly"), floor = NULL, circular = FALSE) {
  url <- "https://reservoircontrol.usace.army.mil/NE/pls/cwmsweb/cwms_web.jsonapi.timeseriesdata"
  query <- list(ts_codes = paste(ts_codes, sep = ","), summary_interval = match.arg(summary_interval), floor = floor, circular = tolower(as.character(circular)))
  response <- httr::GET(url, query = query)
  # Valid format for negative numbers
  char <- gsub(":([\\-]*)\\.", ":\\10.", rawToChar(response$content))
  json <- jsonlite::fromJSON(char)
  # Valid ISO 8601 date time
  json$date_time <- paste0(json$date_time, "Z")
  return(json)
}

# ---- Get CWMS data ----

location_id <- "COL"

# Get location metadata
locations <- get_cwms_locations(db_office_id = "NAE", unit_system = "SI")
location <- locations[locations$location_id == location_id, ]

# Get timeseries metadata
timeseries <- get_cwms_timeseries(location_id)

# Get timeseries data (slow)
timeseries_data <- lapply(timeseries$ts_code, get_cwms_timeseries_data, summary_interval = NULL, floor = NULL)
names(timeseries_data) <- timeseries$ts_code
# Tabulate values by timestamp (discarding count and quality_code)
unique_timestamps <- sort(unique(unlist(sapply(timeseries_data, "[[", "date_time"))))
merged_timeseries <- data.frame(date_time = unique_timestamps)
for (i in seq_along(timeseries_data)) {
  merged_timeseries <- merge(merged_timeseries, timeseries_data[[i]][, c("date_time", "value")], by = "date_time", all = TRUE)
  colnames(merged_timeseries)[ncol(merged_timeseries)] <- names(timeseries_data)[i]
}
# Rename columns
ts_labels <- c(
  "Temp-AIR1" = "air_temperature_1",
  "Temp-AIR2" = "air_temperature_2",
  "%-RELHUM" = "relative_humidity",
  "Speed-WIND1" = "wind_speed_1",
  "Speed-WIND2" = "wind_speed_2",
  "Dir-WIND1" = "wind_direction_1",
  "Dir-WIND2" = "wind_direction_2",
  "Pres" = "pressure",
  "Volt" = "voltage"
)
ind <- 2:ncol(merged_timeseries)
ts_codes <- as.numeric(colnames(merged_timeseries)[ind])
parameter_ids <- timeseries$parameter_id[match(ts_codes, timeseries$ts_code)]
colnames(merged_timeseries)[ind] <- ts_labels[parameter_ids]

# ---- Write data to files ----

# location
write.csv(location, "data/location.csv", na = "", quote = FALSE, row.names = FALSE)
# timeseries
write.csv(timeseries, "data/timeseries.csv", na = "", quote = FALSE, row.names = FALSE)
# timeseries data
write.csv(merged_timeseries, "data/data.csv", na = "", quote = FALSE, row.names = FALSE)
