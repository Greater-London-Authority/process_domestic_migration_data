
source("R/additional_outputs/aggregate_to_age_bands.R")
source("R/additional_outputs/add_persons.R")

library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(gglaplot)

fpath <- list(lad_od_data = "data/processed/full_series.rds",
              region_od_data = "data/processed/region_od_series.rds",
              lookup_lad_itl = "lookups/lookup_lad_itl.rds",
              lookup_lad_rgn_ctry = "lookups/lookup_lad_rgn_ctry.rds",
              region_od_age_band_csv = "data/processed/region_od_age_band.csv",
              london_lad_od_age_band_csv = "data/processed/london_lad_od_age_band.csv")

lookup_rgn_names <- readRDS(fpath$lookup_lad_rgn_ctry) %>%
  select(RGNCD, RGNNM) %>%
  distinct()

lookup_lad_names <- readRDS(fpath$lookup_lad_rgn_ctry) %>%
  select(gss_code, gss_name) %>%
  distinct()

region_od_sya <- readRDS(fpath$region_od_data)

region_od_age_band <- region_od_sya %>%
  add_persons() %>%
  filter(sex == "persons") %>%
  aggregate_to_age_bands(c_breaks = c(-Inf, 15, 64, Inf),
                         c_labels = c("0 to 15", "16 to 64", "65+")) %>%
  left_join(lookup_rgn_names, by = c("gss_in" = "RGNCD")) %>%
  rename(to = RGNNM) %>%
  left_join(lookup_rgn_names, by = c("gss_out" = "RGNCD")) %>%
  rename(from = RGNNM)

region_od_age_band_csv <- region_od_age_band %>%
  mutate(value = round(value, 0)) %>%
  select(year, from, to, age_band, gss_out, gss_in, value) %>%
  pivot_wider(names_from = "age_band", values_from = "value", values_fill = 0)

write_csv(region_od_age_band_csv, fpath$region_od_age_band_csv)

london_lad_sya <- readRDS(fpath$lad_od_data) %>%
  filter(grepl("E09", gss_in), grepl("E09", gss_out))

london_age_band <- london_lad_sya %>%
  add_persons() %>%
  filter(sex == "persons") %>%
  aggregate_to_age_bands(c_breaks = c(-Inf, 15, 64, Inf),
                         c_labels = c("0 to 15", "16 to 64", "65+")) %>%
  left_join(lookup_lad_names, by = c("gss_in" = "gss_code")) %>%
  rename(gss_name_in = gss_name) %>%
  left_join(lookup_lad_names, by = c("gss_out" = "gss_code")) %>%
  rename(gss_name_out = gss_name)

london_lad_od_age_band_csv <- london_age_band %>%
  mutate(value = round(value, 1)) %>%
  select(year, from = gss_name_out, to = gss_name_in, age_band, gss_out, gss_in, value) %>%
  pivot_wider(names_from = "age_band", values_from = "value", values_fill = 0)

write_csv(london_lad_od_age_band_csv, fpath$london_lad_od_age_band_csv)
