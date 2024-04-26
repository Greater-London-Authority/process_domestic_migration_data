
fpath <- list(old_series = "data/processed/old_series.rds",
              new_series = "data/processed/new_series_lad.rds",
              full_series = "data/processed/full_series_lad.rds")

url_old_series <- "https://data.london.gov.uk/download/modelled-population-backseries/6b9d6296-db41-4b7f-901c-2a5e5c5b44d5/origin_destination_2002_to_2020_%282021_geog%29.rds"

download.file(url_old_series, destfile = fpath$old_series, mode = "wb")

new_series <- readRDS(fpath$new_series)

start_yr_new_series <- min(new_series$year)

old_series <- readRDS(fpath$old_series) %>%
  filter(year < start_yr_new_series)

full_series <- bind_rows(old_series, new_series)

saveRDS(full_series, fpath$full_series)
