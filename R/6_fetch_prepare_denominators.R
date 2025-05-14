library(dplyr)
library(gsscoder)
library(arrow)

fpath <- list(population_coc = "data/processed/population_coc.rds")

url_population_coc <- "https://data.london.gov.uk/download/modelled-population-backseries/2b07a39b-ba63-403a-a3fc-5456518ca785/full_modelled_estimates_series_EW%282023_geog%29.rds"


if(!file.exists(fpath$population_coc)) {
  download.file(url_population_coc, destfile = fpath$population_coc, mode = "wb")
}

