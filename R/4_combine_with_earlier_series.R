library(dplyr)
library(gsscoder)
library(arrow)

fpath <- list(old_series = "data/processed/old_series.rds",
              new_series = "data/processed/new_series_lad.rds",
              full_series = "data/processed/full_series_lad.rds",
              parquet_output = "data/processed/domestic_od_flows")

url_old_series <- "https://data.london.gov.uk/download/modelled-population-backseries/6b9d6296-db41-4b7f-901c-2a5e5c5b44d5/origin_destination_2002_to_2020_%282021_geog%29.rds"

geog_yr_old_series <- 2021
geog_yr_new_series <- 2023
start_yr_new_series <- 2012

if(!file.exists(fpath$old_series)) {
  download.file(url_old_series, destfile = fpath$old_series, mode = "wb")
}

old_series <- readRDS(fpath$old_series) %>%
  filter(year < start_yr_new_series)


old_series_chg_gss_in <- bind_rows(
  old_series %>%
    filter(grepl("E0|W0", gss_in)) %>%
    recode_gss(col_code = "gss_in",
               col_data = "value",
               recode_from_year = geog_yr_old_series,
               recode_to_year = geog_yr_new_series),
  old_series %>%
    filter(!grepl("E0|W0", gss_in))
)

old_series_chg_gss_both <- bind_rows(
  old_series_chg_gss_in %>%
    filter(grepl("E0|W0", gss_out)) %>%
    recode_gss(col_code = "gss_out",
               col_data = "value",
               recode_from_year = geog_yr_old_series,
               recode_to_year = geog_yr_new_series),
  old_series_chg_gss_in %>%
    filter(!grepl("E0|W0", gss_out))
)

rm(old_series, old_series_chg_gss_in)

gc()

new_series <- readRDS(fpath$new_series)


full_series <- bind_rows(old_series_chg_gss_both, new_series) %>%
  filter(gss_in != gss_out)

saveRDS(full_series, fpath$full_series)


full_series %>%
  group_by(year) %>%
  write_dataset(path = fpath$parquet_output,
                format = "parquet")
