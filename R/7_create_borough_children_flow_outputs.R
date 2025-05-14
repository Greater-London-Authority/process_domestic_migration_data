library(dplyr)
library(tidyr)
library(gsscoder)
library(arrow)
library(stringr)
library(readr)

source("R/functions/create_gross_flows.R")
source("R/functions/create_gross_flows_from_pq.R")
source("R/functions/aggregate_od_to_region.R")
source("R/functions/aggregate_od_to_region_year_from_pq.R")

fpath <- list(lad_od_data = "data/processed/full_series_lad.rds",
              lookup_lad_rgn_ctry = "lookups/lookup_lad_rgn_ctry.rds",
              lookup_lad_ctry = "lookups/lookup_lad_ctry.rds",
              lookup_lad_rgn = "lookups/lookup_lad_rgn.rds",
              lookup_lad_inner_outer_london = "lookups/lookup_lad_inner_outer_london.rds",
              parquet_output = "data/processed/domestic_od_flows",
              in_out_net_flows = "data/processed/in_out_net_flows.rds",
              in_out_net_flows_csv = "data/processed/domestic_flows_children.csv")

lad_od_data_pq <- open_dataset(fpath$parquet_output)

lookup_ldn_rgn_ctry <- readRDS(fpath$lookup_lad_rgn_ctry) %>%
  mutate(RGNCD = case_when(
    RGNCD == "E12000007" ~ gss_code,
    RGNCD %in% c("E12000006", "E12000008") ~ RGNCD,
    TRUE ~ "RoUK"
  )) %>%
  mutate(RGNNM = case_when(
    RGNNM == "London" ~ gss_name,
    RGNNM %in% c("East of England", "South East") ~ RGNNM,
    TRUE ~ "Rest of UK"
  ))

lookup_ldn_rgn_names <- lookup_ldn_rgn_ctry %>%
  select(RGNCD, RGNNM) %>%
  rename(gss_code = RGNCD, gss_name = RGNNM) %>%
  distinct()

all_yrs <- list.files(fpath$parquet_output) %>%
  str_extract(pattern = "[0-9]{4}") %>%
  as.integer()

# create flows between boroughs and with regions outside London
ldn_region_od_data <- lapply(all_yrs, aggregate_od_to_region_year_from_pq,
                         od_flows_pq = lad_od_data_pq,
                         lookup = lookup_ldn_rgn_ctry) %>%
  bind_rows() %>%
  filter(age <= 15) %>%
  group_by(across(-any_of(c("value", "sex")))) %>%
  summarise(value = sum(value), .groups = "drop") %>%
  left_join(lookup_ldn_rgn_names, by = c("gss_in" = "gss_code")) %>%
  rename(name_in = gss_name) %>%
  left_join(lookup_ldn_rgn_names, by = c("gss_out" = "gss_code")) %>%
  rename(name_out = gss_name)


# create total flows

total_flows <- bind_rows(

  ldn_region_od_data %>%
  mutate(gss_in = "total",
         name_in = "total") %>%
  group_by(across(-any_of(c("value")))) %>%
  summarise(value = sum(value), .groups = "drop"),

  ldn_region_od_data %>%
    mutate(gss_out = "total",
           name_out = "total") %>%
    group_by(across(-any_of(c("value")))) %>%
    summarise(value = sum(value), .groups = "drop")
)


#create flows between inner/outer London
lookup_lad_inner_outer_london <- readRDS(fpath$lookup_lad_inner_outer_london) %>%
  select(-gss_name)

lookup_inner_outer_names <- lookup_lad_inner_outer_london %>%
  select(RGNCD, RGNNM) %>%
  rename(gss_code = RGNCD, gss_name = RGNNM) %>%
  distinct()

inner_outer_od_data <- lapply(all_yrs, aggregate_od_to_region_year_from_pq,
                             od_flows_pq = lad_od_data_pq,
                             lookup = lookup_lad_inner_outer_london) %>%
  bind_rows() %>%
  filter(age <= 15) %>%
  filter(gss_in %in% c("E13000001", "E13000002")) %>%
  filter(gss_out %in% c("E13000001", "E13000002")) %>%
  group_by(across(-any_of(c("value", "sex")))) %>%
  summarise(value = sum(value), .groups = "drop") %>%
  left_join(lookup_inner_outer_names, by = c("gss_in" = "gss_code")) %>%
  rename(name_in = gss_name) %>%
  left_join(lookup_inner_outer_names, by = c("gss_out" = "gss_code")) %>%
  rename(name_out = gss_name)


# create flows between boroughs and rest of London and between London and other regions
london_od_data <- bind_rows(
  ldn_region_od_data %>%
    filter(grepl("E09", gss_in)) %>%
    mutate(gss_in = "E12000007",
           name_in = "London") %>%
    group_by(across(-any_of(c("value")))) %>%
    summarise(value = sum(value), .groups = "drop"),

  ldn_region_od_data %>%
    filter(grepl("E09", gss_out)) %>%
    mutate(gss_out = "E12000007",
           name_out = "London") %>%
    group_by(across(-any_of(c("value")))) %>%
    summarise(value = sum(value), .groups = "drop")
)

# create inner/outer London flows with individual LAs and regions outside London

ldn_inner_outer <- bind_rows(

  ldn_region_od_data %>%
    filter(grepl("E09", gss_in)) %>%
    left_join(lookup_lad_inner_outer_london, by = c("gss_in" = "gss_code")) %>%
    select(-c(gss_in, name_in)) %>%
    rename(gss_in = RGNCD, name_in = RGNNM) %>%
    group_by(across(-any_of(c("value")))) %>%
    summarise(value = sum(value), .groups = "drop"),

  ldn_region_od_data %>%
    filter(grepl("E09", gss_out)) %>%
    left_join(lookup_lad_inner_outer_london, by = c("gss_out" = "gss_code")) %>%
    select(-c(gss_out, name_out)) %>%
    rename(gss_out = RGNCD, name_out = RGNNM) %>%
    group_by(across(-any_of(c("value")))) %>%
    summarise(value = sum(value), .groups = "drop")
)

all_od_flows <- bind_rows(
  ldn_region_od_data,
  inner_outer_od_data,
  london_od_data,
  ldn_inner_outer,
  total_flows
) %>%
  arrange(age, gss_in, gss_out, year)

in_out_net_flows <- all_od_flows %>%
  rename(gss_code = gss_in,
         gss_name = name_in,
         origin_destination_code = gss_out,
         origin_destination_name = name_out,
         inflow = value) %>%
  full_join(all_od_flows, by = c("gss_code" = "gss_out",
                                 "gss_name" = "name_out",
                                 "origin_destination_code" = "gss_in",
                                 "origin_destination_name" = "name_in",
                                 "age", "year")) %>%
  rename(outflow = value) %>%
  replace_na(list(inflow = 0, outflow = 0)) %>%
  mutate(netflow = inflow - outflow) %>%
  select(gss_code, gss_name, origin_destination_code, origin_destination_name, age, year, inflow, outflow, netflow) %>%
  arrange(gss_code, gss_name, origin_destination_code, origin_destination_name, age, year)

in_out_net_flows_wide <- in_out_net_flows %>%
  pivot_longer(cols = c("inflow", "outflow", "netflow"),
               names_to = "direction", values_to = "value") %>%
  mutate(value = round(value, 0)) %>%
  pivot_wider(names_from = "age", values_fill = 0) %>%
  arrange(gss_code, gss_name, origin_destination_code, origin_destination_name, direction, year) %>%
  filter(grepl("E09|E13|E12000007", gss_code)) %>%
  mutate(`age 0 to 4` = rowSums(across(as.character(c(0:4)))),
         `age 5 to 10` = rowSums(across(as.character(c(5:10)))),
         `age 11 to 15` = rowSums(across(as.character(c(11:15)))),
         `age 0 to 15` = rowSums(across(as.character(c(0:15)))))

saveRDS(in_out_net_flows, fpath$in_out_net_flows)
write_csv(in_out_net_flows_wide, fpath$in_out_net_flows_csv)

#
# all_od_flows_wide <- all_od_flows %>%
#   mutate(value = round(value, 0)) %>%
#   pivot_wider(values_from = "value", names_from = "age",
#               values_fill = 0)




# saveRDS(inner_outer_london_od_data, fpath$lookup_lad_inner_outer_london)
# saveRDS(region_od_data, fpath$region_od_data)
# saveRDS(ctry_od_data, fpath$ctry_od_data)
#
# inner_outer_london_gross_flows <- create_gross_flows(inner_outer_london_od_data, rounding = 1) %>%
#   filter(gss_code != "other")
# region_gross_flows <- create_gross_flows(region_od_data, rounding = 1)
# ctry_gross_flows <- create_gross_flows(ctry_od_data, rounding = 1)
#
# ctry_region_gross_flows <- bind_rows(filter(ctry_gross_flows, gss_code == "E92000001"),
#                                      region_gross_flows,
#                                      inner_outer_london_gross_flows)
#
# saveRDS(ctry_region_gross_flows, fpath$ctry_region_gross_flows)
