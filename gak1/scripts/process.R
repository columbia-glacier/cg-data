# ---- Install missing dependencies ----

packages <- c()
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# ---- Load functions ----

# GLOBEC? http://www.ims.uaf.edu/GLOBEC/results/index.html

# http://www.ims.uaf.edu/gak1/
# http://www.ims.uaf.edu/gak1/data/TimeSeries/gak1.dat
# http://www.ims.uaf.edu/gak1/data/FreshwaterDischarge/Discharge.dat

url <- "http://www.ims.uaf.edu/gak1/data/Mooring/"
response <- httr::GET(url)
xml <- xml2::read_html(rawToChar(response$content))
hrefs <- sapply(xml2::xml_find_all(xml, "//a/@href"), xml2::xml_text)
is_file <- grepl(".zip$", hrefs)
lapply(hrefs[is_file], function(filename) {
  temp <- tempfile()
  download.file(paste0(url, filename), temp)
  data <- read.table(unz(temp))
  unlink(temp)
})


