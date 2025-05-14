library(dplyr)
library(tidyr)
library(gsscoder)
library(arrow)

source("R/functions/create_gross_flows.R")
source("R/functions/create_gross_flows_from_pq.R")
source("R/functions/aggregate_od_to_region.R")
source("R/functions/aggregate_od_to_region_year_from_pq.R")

fpath <- list(lad_od_data = "data/processed/full_series_lad.rds",
              lad_gross_flows = "data/processed/lad_gross_flows.rds",
              region_od_data = "data/processed/region_od_series.rds",
              ctry_od_data = "data/processed/ctry_od_series.rds",
              inner_outer_london_od_data = "data/processed/inner_outer_london_od_data.rds",
              ctry_region_gross_flows = "data/processed/ctry_region_gross_flows.rds",
              lookup_lad_rgn_ctry = "lookups/lookup_lad_rgn_ctry.rds",
              lookup_lad_ctry = "lookups/lookup_lad_ctry.rds",
              lookup_lad_rgn = "lookups/lookup_lad_rgn.rds",
              lookup_lad_inner_outer_london = "lookups/lookup_lad_inner_outer_london.rds",
              parquet_output = "data/processed/domestic_od_flows")

lad_od_data_pq <- open_dataset(fpath$parquet_output)

lad_gross_flows <- create_gross_flows_from_pq(lad_od_data_pq, rounding = 1)

saveRDS(lad_gross_flows, fpath$lad_gross_flows)

all_yrs <- unique(lad_gross_flows$year)


region_od_data <- lapply(all_yrs, aggregate_od_to_region_year_from_pq,
                         od_flows_pq = lad_od_data_pq,
                         lookup = readRDS(fpath$lookup_lad_rgn_ctry)) %>%
  bind_rows()

ctry_od_data <- lapply(all_yrs, aggregate_od_to_region_year_from_pq,
                       od_flows_pq = lad_od_data_pq,
                       lookup = readRDS(fpath$lookup_lad_ctry)) %>%
  bind_rows()

inner_outer_london_od_data <- lapply(all_yrs, aggregate_od_to_region_year_from_pq,
                                     od_flows_pq = lad_od_data_pq,
                                     lookup = readRDS(fpath$lookup_lad_inner_outer_london)) %>%
  bind_rows()

saveRDS(inner_outer_london_od_data, fpath$lookup_lad_inner_outer_london)
saveRDS(region_od_data, fpath$region_od_data)
saveRDS(ctry_od_data, fpath$ctry_od_data)

inner_outer_london_gross_flows <- create_gross_flows(inner_outer_london_od_data, rounding = 1) %>%
  filter(gss_code != "other")
region_gross_flows <- create_gross_flows(region_od_data, rounding = 1)
ctry_gross_flows <- create_gross_flows(ctry_od_data, rounding = 1)

ctry_region_gross_flows <- bind_rows(filter(ctry_gross_flows, gss_code == "E92000001"),
                                     region_gross_flows,
                                     inner_outer_london_gross_flows)

saveRDS(ctry_region_gross_flows, fpath$ctry_region_gross_flows)
