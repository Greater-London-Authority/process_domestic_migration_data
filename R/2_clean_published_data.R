library(stringr)
library(readxl)
library(readr)
library(arrow)

source("R/functions/clean_data.R")

fpath <- list(
  raw_data = "data/raw/",
  clean_data = "data/intermediate/",
  domestic_od_flows_pq = "data/processed/domestic_od_flows_pq"
)

geog_yr <- 2023
geog_name <- "lad23"

if(!dir.exists(fpath$clean_data)) dir.create(fpath$clean_data, recursive = TRUE)

fpaths <- list.files(fpath$raw_data, pattern = "detailedestimates", full.names = TRUE)
fpaths <- fpaths[!grepl("~", fpaths)]


get_sheet_name <- function(wb_path, data_yr, geog_yr) {

  wsheets <- excel_sheets(wb_path)

  sheet_name <- wsheets[grepl(paste0(data_yr, " on ", geog_yr, " LAs"), wsheets)]

  return(sheet_name)
}

for(fp in fpaths) {

  data_year = str_extract(fp, pattern = "[0-9]+")
  # clean_fp = paste0(fpath$clean_data, data_year, "(", geog_yr, " geography).rds")

  clean_data(raw_path = fp,
             sheet_name = get_sheet_name(fp, data_year, geog_yr)
  ) |>
    mutate(geography = geog_name) |>
    write_dataset(path = fpath$domestic_od_flows_pq,
                  format = "parquet",
                  partitioning = c("geography", "year"))
}
