library(stringr)


source("R/functions/clean_published_data.R")
source("R/functions/get_sheet_name.R")

fpath <- list(
  raw_data = "data/raw/",
  clean_data = "data/intermediate/"
)

geog_yr <- 2021

if(!dir.exists(fpath$clean_data)) dir.create(fpath$clean_data, recursive = TRUE)

fpaths <- list.files(fpath$raw_data, pattern = "detailedestimates", full.names = TRUE)
fpaths <- fpaths[!grepl("~", fpaths)]

for(fp in fpaths) {

  data_year = str_extract(fp, pattern = "[0-9]+")
  clean_fp = paste0(fpath$clean_data, data_year, "(", geog_yr, " geography).rds")

  clean_data(raw_path = fp,
             sheet_name = get_sheet_name(data_year, geog_yr),
             clean_path = clean_fp)

}


