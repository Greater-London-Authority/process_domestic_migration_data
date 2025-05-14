library(dplyr)
library(tidyr)


fpath <- list(
  clean_data = "data/intermediate/",
  processed_data = "data/processed/",
  lad_series = "data/processed/new_series_lad.rds"
)

if(!dir.exists(fpath$processed_data)) dir.create(fpath$processed_data, recursive = TRUE)

individual_yr_paths <- list.files(fpath$clean_data, full.names = TRUE)

lad_series <- lapply(individual_yr_paths, readRDS) %>%
  bind_rows()

saveRDS(lad_series, fpath$lad_series)
