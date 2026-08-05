library(dplyr)
library(tidyr)
library(gsscoder)
library(arrow)

source("R/functions/create_gross_flows_from_pq.R")
source("R/functions/aggregate_od_to_region_year_from_pq.R")

fpath <- list(
  lookup_lad_rgn_ctry = "lookups/lookup_lad_rgn_ctry.rds",
  lookup_lad_ctry = "lookups/lookup_lad_ctry.rds",
  lookup_lad_rgn = "lookups/lookup_lad_rgn.rds",
  lookup_lad_itl2 = "lookups/lookup_lad_itl.rds",
  lookup_lad_inner_outer_london = "lookups/lookup_lad_inner_outer_london.rds",
  domestic_od_flows_pq = "data/processed/domestic_od_flows_pq",
  domestic_gross_flows_pq = "data/processed/domestic_gross_flows_pq"
)

geog_name <- "lad23"

domestic_od_flows_pq <- open_dataset(fpath$domestic_od_flows_pq)

all_yrs <- domestic_od_flows_pq |>
  select(year) |>
  distinct() |>
  collect() |>
  arrange(year) |>
  pull(year)

message("Aggregating origin-destination flows to higher geographies")
# create aggregate OD flows
for(sel_yr in all_yrs) {

  # region
  aggregate_od_to_region_year_from_pq(sel_year = sel_yr,
                                      od_flows_pq = domestic_od_flows_pq,
                                      in_geog_name = geog_name,
                                      out_geog_name = "region",
                                      lookup = readRDS(fpath$lookup_lad_rgn_ctry)
                                      ) |>
    write_dataset(path = fpath$domestic_od_flows_pq,
                  format = "parquet",
                  partitioning = c("geography", "year"))

  # country
  aggregate_od_to_region_year_from_pq(sel_year = sel_yr,
                                      od_flows_pq = domestic_od_flows_pq,
                                      in_geog_name = geog_name,
                                      out_geog_name = "country",
                                      lookup = readRDS(fpath$lookup_lad_ctry)
  ) |>
    write_dataset(path = fpath$domestic_od_flows_pq,
                  format = "parquet",
                  partitioning = c("geography", "year"))

  # inner outer london
  aggregate_od_to_region_year_from_pq(sel_year = sel_yr,
                                      od_flows_pq = domestic_od_flows_pq,
                                      in_geog_name = geog_name,
                                      out_geog_name = "itl1",
                                      lookup = readRDS(fpath$lookup_lad_inner_outer_london)
  ) |>
    write_dataset(path = fpath$domestic_od_flows_pq,
                  format = "parquet",
                  partitioning = c("geography", "year"))

  # itl2
  aggregate_od_to_region_year_from_pq(sel_year = sel_yr,
                                      od_flows_pq = domestic_od_flows_pq,
                                      in_geog_name = geog_name,
                                      out_geog_name = "itl2",
                                      lookup = readRDS(fpath$lookup_lad_itl)
  ) |>
    write_dataset(path = fpath$domestic_od_flows_pq,
                  format = "parquet",
                  partitioning = c("geography", "year"))
}

message("Creating gross flows")

domestic_od_flows_pq <- open_dataset(fpath$domestic_od_flows_pq)

gross_flows <- create_gross_flows_from_pq(od_flows_pq = domestic_od_flows_pq,
                                          rounding = 1) |>
  write_dataset(path = fpath$domestic_gross_flows_pq,
                format = "parquet",
                partitioning = c("geography", "component", "year"))



# tst <- domestic_od_flows_pq %>%
#   filter(year == 2016) |>
#   filter(geography == "region") |>
#   collect()

