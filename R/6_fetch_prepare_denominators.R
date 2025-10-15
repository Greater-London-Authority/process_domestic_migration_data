library(dplyr)
library(gsscoder)
library(arrow)

fpath <- list(population_coc = "data/processed/population_coc.rds")

url_population_coc <- "https://data.london.gov.uk/download/fb203828-bde5-4a50-96d9-8adfb4960631/ba752f34-0b54-4184-9251-8e2e94ae97ee/full_modelled_estimates_series_EW(2023_geog).rds"


if(!file.exists(fpath$population_coc)) {
  download.file(url_population_coc, destfile = fpath$population_coc, mode = "wb")
}

