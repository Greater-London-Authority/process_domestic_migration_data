source("R/functions/create_gross_flows.R")
source("R/functions/aggregate_od_to_region.R")

fpath <- list(lad_od_data = "data/processed/full_series_lad.rds",
              lad_gross_flows = "data/processed/lad_gross_flows.rds",
              region_od_data = "data/processed/region_od_series.rds",
              region_gross_flows = "data/processed/region_gross_flows.rds",
              lookup_lad_rgn_ctry = "lookups/lookup_lad_rgn_ctry.rds")

lad_od_data <- readRDS(fpath$lad_od_data)

lad_gross_flows <- create_gross_flows(lad_od_data, rounding = 1)

saveRDS(lad_gross_flows, fpath$lad_gross_flows)

region_od_data <- aggregate_od_to_region(lad_od_data, readRDS(fpath$lookup_lad_rgn_ctry))

saveRDS(region_od_data, fpath$region_od_data)

region_gross_flows <- create_gross_flows(region_od_data, rounding = 1)

saveRDS(region_gross_flows, fpath$region_gross_flows)
