library(dplyr)
library(tidyr)
library(gsscoder)


source("R/functions/create_gross_flows.R")
source("R/functions/aggregate_od_to_region.R")

fpath <- list(lad_od_data = "data/processed/full_series_lad.rds",
              lad_gross_flows = "data/processed/lad_gross_flows.rds",
              region_od_data = "data/processed/region_od_series.rds",
              ctry_od_data = "data/processed/ctry_od_series.rds",
              region_gross_flows = "data/processed/region_gross_flows.rds",
              ctry_gross_flows = "data/processed/ctry_gross_flows.rds",
              ctry_region_gross_flows = "data/processed/ctry_region_gross_flows.rds",
              lookup_lad_rgn_ctry = "lookups/lookup_lad_rgn_ctry.rds",
              lookup_lad_ctry = "lookups/lookup_lad_ctry.rds",
              lookup_lad_rgn = "lookups/lookup_lad_rgn.rds")

lad_od_data <- readRDS(fpath$lad_od_data)

lad_gross_flows <- create_gross_flows(lad_od_data, rounding = 1)

saveRDS(lad_gross_flows, fpath$lad_gross_flows)

region_od_data <- aggregate_od_to_region(lad_od_data, readRDS(fpath$lookup_lad_rgn_ctry))

saveRDS(region_od_data, fpath$region_od_data)

region_gross_flows <- create_gross_flows(region_od_data, rounding = 1)

saveRDS(region_gross_flows, fpath$region_gross_flows)

ctry_od_data <- aggregate_od_to_region(lad_od_data, readRDS(fpath$lookup_lad_ctry))

saveRDS(ctry_od_data, fpath$ctry_od_data)

ctry_gross_flows <- create_gross_flows(ctry_od_data, rounding = 1)

saveRDS(ctry_gross_flows, fpath$ctry_gross_flows)

ctry_region_gross_flows <- bind_rows(filter(ctry_gross_flows, gss_code == "E92000001"),
                                     region_gross_flows)

saveRDS(ctry_region_gross_flows, fpath$ctry_region_gross_flows)
