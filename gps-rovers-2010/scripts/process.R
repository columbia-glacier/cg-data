# ---- NETRS ----

# List of source files
# NOTE: Manually pulled from columbia_netrs_2010.m (get_data).
filenames <- c(
  "sources/columbia_netrs_2010_n1.csv",
  "sources/columbia_netrs_2010_n2.csv",
  "sources/columbia_netrs_2010_n3.csv"
)

# Process source files
results <- lapply(filenames, function(filename) {
  # Read source file
  df <- read.csv(filename)
  # Insert rover id field as first column
  df$id <- unlist(regmatches(filename, regexec("n[0-9]+", filename)))
  df <- df[, c("id", "t", "x", "y", "z")]
  # Split tracks at dig-out on day 137 (Ian Howat, email: 2010-10-29)
  after_move <- df$t > 137
  df$id[!after_move] <- paste0(df$id[!after_move], ".1")
  df$id[after_move] <- paste0(df$id[after_move], ".2")
  # Return tracks
  return(df)
})
df <- do.call("rbind", results)

# Convert day number (2010) to ISO 8601 date
# NOTE: Checked against columbia_edgee_2010.m (dayofyear).
df$t <- as.character(as.Date(df$t, origin = "2009-12-31"))

# Save result
write.csv(df, "data/netrs.csv", row.names = FALSE, quote = FALSE)


# ---- EDGEE ----

# List of source files (GRAFNAV)
filenames <- c(
  "sources/S1R1 new.txt",
  "sources/S1R2 new.txt",
  "sources/S1R3 new.txt",
  "sources/S2R1 new.txt",
  "sources/S2R2 new.txt",
  "sources/S2R3 new.txt"
)

# Original (GRAFNAV) field names and their replacements
fields <- data.frame(
  old = c("GPSTime", "Date", "Easting", "Northing", "H-Ell", "SDHoriz", "SDHeigh", "Q"),
  new = c("time", "date", "x", "y", "z", "xy_sd", "z_sd", "quality"),
  stringsAsFactors = FALSE
)

# Track breaks for rovers that were relocated (indice ranges, till end of file if not specified)
# NOTE: Indice ranges from columbia_edgee_2010.m (columbia_edgee_2010). Expects rows sorted and unique in time.
breaks <- list(
  s2r1 = list(1:2215, 2216),
  s2r2 = list(1:3439, 3441:3755, 3756),
  s2r3 = list(1:1918, 1919:2190, 2195)
)

# Process source files
results <- lapply(filenames, function(filename) {
  # Extract data
  df <- read.table(filename, skip = 22, stringsAsFactors = FALSE)
  header_line <- readLines(filename, n = 21)[21]
  names(df) <- unlist(strsplit(header_line, split = "[ ]+"))
  # Update column names
  for (name in names(df)) {
    is_new_name <- fields$old == name
    if (sum(is_new_name) > 0) {
      names(df)[names(df) == name] <- fields$new[is_new_name]
    } else {
      df[name] <- NULL
      warning(paste("Dropped column", name, "in", filename))
    }
  }
  # Convert date and time to ISO 8601 datetime
  new_date <- format(strptime(df$date, "%m/%d/%Y"), "%Y-%m-%d")
  new_time <- format(strptime(df$time, "%H:%M:%S"), "%H:%M:%S")
  df$t <- paste0(new_date, "T", new_time, "Z")
  df$date <- NULL
  df$time <- NULL
  # Sort rows (by time)
  df <- df[order(df$t), ]
  # Delete duplicate rows (by time)
  df <- df[!duplicated(df$t), ]
  # Assign rover id by break
  id <- tolower(unlist(regmatches(filename, regexec("S[0-9]+R[0-9]+", filename))))
  if (id %in% names(breaks)) {
    for (i_break in seq_along(breaks[[id]])) {
      range <- breaks[[id]][[i_break]]
      range <- ifelse(length(range) > 1, range, range:nrow(df))
      df$id[range] <- paste0(id, ".", i_break)
    }
  } else {
    df$id <- paste0(id, ".1")
  }
  # Return results
  return(df)
})
df <- do.call("rbind", results)

# Order columns
df <- df[, intersect(c("id", "t", fields$new), names(df))]

# Save result
write.csv(df, "data/edgee.csv", row.names = FALSE, quote = FALSE)
