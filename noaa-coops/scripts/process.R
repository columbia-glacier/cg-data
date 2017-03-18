# ---- Install missing dependencies ----

packages <- c("linbin", "httr", "xml2", "jsonlite", "data.table", "stringr")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# ---- Load functions ----

#' Get Data Inventory for CO-OPS Station
#'
#' @param station Station id.
#' @references Parsed from HTML (e.g. \url{https://tidesandcurrents.noaa.gov/inventory.html?id=9454240}).
coops_inventory <- function(station) {
  products <- c(
    "Wind" = "wind",
    "Air Temperature" = "air_temperature",
    "Water Temperature" = "water_temperature",
    "Barometric Pressure" = "air_pressure",
    "Preliminary 6-Minute Water Level" = "predictions",
    "Verified 6-Minute Water Level" = "water_level",
    "Verified Hourly Height Water Level" = "hourly_height",
    "Verified High/Low Water Level" = "high_low",
    "Verified Monthly Mean Water Level" = "monthly_mean",
    "Water Conductivity" = "conductivity",
    "Relative Humidity" = "humidity"
  )
  url <- "https://tidesandcurrents.noaa.gov/inventory.html"
  response <- httr::GET(url, query = list(id = station))
  xml <- httr::content(response)
  js <- xml2::xml_text(xml2::xml_find_all(xml, "//table/following-sibling::script[1]"))
  invalid_json <- stringr::str_match_all(js, "data\\.push\\((\\{[^\\}]*\\})\\)")[[1]][, 2]
  json <- stringr::str_replace_all(invalid_json, c("'" = "\"", ": ([^\"]+), \"" = ": \"\\1\", \""))
  dt <- data.table::rbindlist(lapply(json, jsonlite::fromJSON))
  inventory <- dt[, .(
    label = content,
    product = products[content],
    begin = as.POSIXct(popstart, "%Y-%m-%d %H:%M:%S GMT", tz = "GMT"),
    end = as.POSIXct(popend, "%Y-%m-%d %H:%M:%S GMT", tz = "GMT")
  )]
  return(inventory)
}

#' Batch Get NOAA CO-OPS Data
#'
#' @param station Station id.
#' @param begin_dates Start dates in YYYYMMDD format (numeric or character) or as date(time) objects.
#' @param end_dates End dates in YYYYMMDD format (numeric or character) or as date(time) objects.
#' @param products Data product types (see \url{https://tidesandcurrents.noaa.gov/api/#products}).
#' @param datum Datum, required for all water level products (see \url{https://tidesandcurrents.noaa.gov/api/#datum}).
#' @param interval Either "6" (6 minutes) or "h" (hourly), supported only by meteorological and prediction products.
#' @param time_zone Either "GMT" (Greenwich Mean Time), "LST" (local time), or "LST_LDT" (local time adjusted for daylight savings).
#' @param units Either "metric" (celsius, meters) or "english" (fahrenheit, feet).
#' @param bin The bin number for currents data products. If not specified, data from a predefined bin is returned.
#' @references Parsed from API results (\url{https://tidesandcurrents.noaa.gov/api/}).
batch_coops_search <- function(station, begin_dates, end_dates, products, datum = NULL, interval = c("6", "h"), time_zone = c("GMT", "LST", "LST_LDT"), units = c("metric", "english"), bin = NULL) {
  
  # Constants
  interval <- match.arg(interval)
  time_zone <- match.arg(time_zone)
  units <- match.arg(units)
  url <- "https://tidesandcurrents.noaa.gov/api/datagetter"
  base_query <- c(mget(c("station", "datum", "bin", "interval", "time_zone", "units")), list(format = "json"))
  
  # Interval limits (in days)
  # https://tidesandcurrents.noaa.gov/api/#maximum
  # NOTE: Using one less than limit to avoid leap years.
  interval_limit <- switch(interval, "6" = 31, "h" = 365, stop(paste("Interval not supported:", interval)))
  limits <- c(
    water_level = 31,
    one_minute_water_level = 31,
    hourly_height = 365,
    high_low = 365,
    daily_mean = 3650,
    monthly_mean = 3650,
    datums = Inf,
    air_temperature = interval_limit,
    water_temperature = interval_limit,
    wind = interval_limit,
    air_pressure = interval_limit,
    predictions = interval_limit,
    conductivity = interval_limit,
    humidity = interval_limit
  )
  
  # Process dates
  if (is.character(begin_dates) || is.numeric(begin_dates)) {
    begin_dates <- as.POSIXct(as.character(begin_dates), format = "%Y%m%d", tz = "UTC")
  }
  if (is.character(end_dates) || is.numeric(end_dates)) {
    end_dates <- as.POSIXct(as.character(end_dates), format = "%Y%m%d", tz = "UTC")
  }
  intervals <- linbin::events(from = as.numeric(begin_dates), to = as.numeric(end_dates), product = products)
  origin <- as.POSIXct("1970-01-01", format = "%Y-%m-%d", tz = "UTC")
  
  # For each product
  metadata <- NULL
  data_products <- lapply(unique(products), function(product) {
    limit <- limits[product]
    if (is.na(limit)) {
      stop(paste("Product not yet supported:", product))
    }
    coverage <- linbin::event_coverage(intervals[intervals$product == product, ])
    if (is.infinite(limit)) {
      bins <- linbin::event_range(coverage)
    } else {
      bins <- linbin::crop_events(linbin::seq_events(coverage, by = limit * (60 * 60 * 24)), coverage)
    }
    dates <- data.frame(
      begin = format(as.POSIXct(bins$from, tz = "UTC", origin = origin), "%Y%m%d %H:%M"),
      end = format(as.POSIXct(bins$to, tz = "UTC", origin = origin), "%Y%m%d %H:%M"),
      stringsAsFactors = FALSE
    )
    # For each date range
    results <- apply(dates, 1, function(endpoints) {
      cat(paste0("[", product, "] ", endpoints[1], "...", endpoints[2], "\n"))
      query <- c(base_query, list(product = product, begin_date = as.vector(endpoints[1]), end_date = endpoints[2]))
      response <- httr::GET(url, query = query)
      httr::stop_for_status(response)
      json <- jsonlite::fromJSON(rawToChar(response$content))
      if (!is.null(json$error)) {
        warning(paste(product, endpoints[1], endpoints[2], json$error$message))
      } else if (is.null(metadata)) {
        metadata <<- json$metadata
      }
      return(json$data)
    })
    return(if (is.null(results)) NULL else unique(data.table::rbindlist(results)))
  })
  names(data_products) <- unique(products)
  
  # Append metadata
  data_products <- c(metadata = list(metadata), data_products)
  
  # Return results
  return(data_products)
}

#' Clean NOAA CO-OPS Data
#'
#' @param x Data as \code{data.table}.
#' @param product Data product (see \url{https://tidesandcurrents.noaa.gov/api/#products}).
#' @references Parsed from API results (\url{https://tidesandcurrents.noaa.gov/api/}).
coops_clean <- function(x, product) {
  # Format date time as ISO 8601
  if (!is.null(x$t) && grepl("[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}", x$t[1])) {
    x[, t := format(as.POSIXct(t, format = "%Y-%m-%d %H:%M", tz = "UTC"), "%Y-%m-%dT%H:%M:%SZ")]
  }
  # Strip mysterious "f" field
  if (!is.null(x$f)) {
    x[, f := NULL]
  }
  # Remove rows with empty "v" field
  if (!is.null(x$v)) {
    x <- x[!(is.na(v) | v == "")]
  }
  # Convert to SI units (conductivity: mS/cm => S/m)
  if (product == "conductivity") {
    x[, v := as.numeric(v) / 10]
  }
  # Return result
  return(x)
}

#' Get NOAA CO-OPS Station Data
#' 
#' Download all available data for the specified station and products and write them to a file.
#' 
#' @param station Station id.
#' @param products Data product types (see \url{https://tidesandcurrents.noaa.gov/api/#products}).
#' @param output_dir Directory path for output files.
#' @param merge_by_time Whether to merge products with date time fields into a single table.
#' @param ... Arguments passed to \link{\code{batch_coops_search}}
get_coops_data <- function(station, products, output_dir = "data", merge_by_time = TRUE, ...) {
  inventory <- coops_inventory(station)
  ind <- inventory$product %in% products
  raw_data <- batch_coops_search(station, inventory$begin[ind], inventory$end[ind], inventory$product[ind], ...)
  clean_data <- mapply(FUN = coops_clean, raw_data, names(raw_data))
  station_name <- tolower(gsub(" ", "-", raw_data$metadata$name))
  if (merge_by_time) {
    has_time <- sapply(clean_data, function(x) { "t" %in% names(x) })
    unique_times <- sort(unique(unlist(sapply(clean_data[has_time], "[[", "t"))))
    merged_data <- data.frame(t = unique_times, stringsAsFactors = FALSE)
    for (i in which(has_time)) {
      merged_data <- merge(merged_data, clean_data[[i]][, c("t", "v")], by = "t", all = TRUE)
      colnames(merged_data)[ncol(merged_data)] <- names(clean_data)[i]
    }
    clean_data <- clean_data[!has_time]
    write.csv(merged_data, file.path(output_dir, paste0(station_name, ".csv")), row.names = FALSE, quote = FALSE, na = "")
  }
  for (product in names(clean_data)) {
    write.csv(clean_data[[product]], file.path(output_dir, paste0(station_name, "-", product, ".csv")), row.names = FALSE, quote = FALSE, na = "")  
  }
  return(clean_data)
}

# ---- 9454460 Columbia Glacier, AK ----
# https://tidesandcurrents.noaa.gov/inventory.html?id=9454460

columbia <- get_coops_data(9454460, c("hourly_height"), interval = "h", datum = "MLLW")

# ---- 9454240 Valdez, AK ----
# https://tidesandcurrents.noaa.gov/inventory.html?id=9454240

valdez <- get_coops_data(9454240, c("hourly_height", "water_temperature", "air_temperature"), interval = "h", datum = "MLLW")

# ---- 9454050 Cordova, AK ----
# https://tidesandcurrents.noaa.gov/inventory.html?id=9454050

cordova <- get_coops_data(9454050, c("water_temperature", "air_temperature", "conductivity"), interval = "h", datum = "MLLW")

# ---- Merge metadata files ----

metadata_files <- list.files("data", "metadata", full.names = TRUE)
metadata <- data.table::rbindlist(lapply(metadata_files, read.csv))
write.csv(metadata, file.path("data", "stations.csv"), quote = FALSE, na = "", row.names = FALSE)
file.remove(metadata_files)
