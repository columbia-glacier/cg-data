# ---- Install missing dependencies ----

packages <- c("httr")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# ---- Load functions ----

#' Get NWIS Site Data
#' 
#' A map of all USGS National Water Information System (NWIS) sites, with links to pages with site and parameter codes, is available at \url{https://maps.waterdata.usgs.gov/mapper/}.
#' 
#' @param site Site code.
#' @param parameters Parameter codes (as strings). Labels can be supplied as object names.
#' @param begin_date Begin date (YYYY-MM-DD).
#' @param end_date End date (YYYY-MM-DD). If \code{""}, the current date is used. 
#' @param summary_interval Time interval over which the data are averaged. If not \code{"daily"}, the raw observations are returned.
get_nwis <- function(site, parameters, begin_date, end_date = "", summary_interval = "daily") {
  if (summary_interval == "daily") {
    url <- "https://nwis.waterdata.usgs.gov/nwis/dv" 
  } else {
    url <- "https://nwis.waterdata.usgs.gov/nwis/uv"
  }
  temp <- rep("on", length(parameters))
  names(temp) <- paste0("cb_", parameters)
  query <- c(list(site_no = site, begin_date = begin_date, end_date = end_date), temp)
  response <- httr::GET(url, query = query)
  txt_block <- rawToChar(response$content)
  txt_lines <- unlist(strsplit(txt_block, "\n"))
  is_comment <- grepl("^#", txt_lines)
  df <- read.table(textConnection(txt_lines[!is_comment][3:sum(!is_comment)]), sep = "\t", stringsAsFactors = FALSE)
  names(df) <- unlist(strsplit(txt_lines[!is_comment][1], "\t"))
  discard_cols <- c("agency_cd", "site_no", names(df)[grepl("[0-9]_cd", names(df))])
  df <- df[, !(names(df) %in% discard_cols)]
  if (!is.null(names(parameters))) {
    for (i in seq_along(parameters)) {
      ind <- which(grepl(paste0("_", parameters[i], "_"), names(df)))
      if (length(ind) == 1) {
        names(df)[ind] <- names(parameters)[i]
      }
    }
  }
  return(df)
}

# ---- 15281000 Knik River, AK ----

# https://nwis.waterdata.usgs.gov/nwis/dv?site_no=15281000
df <- get_nwis(15281000, c(discharge = "00060"), begin_date = "1959-01-01", summary_interval = "daily")
write.csv(df, file.path("data/knik-river.csv"), na = "", row.names = FALSE, quote = FALSE)
