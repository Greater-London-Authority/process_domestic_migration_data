library(dplyr)
library(tidyr)
library(arrow)

create_gross_flows_from_pq <- function(od_flows_pq, rounding = 2) {

  inflow_query <- od_flows_pq %>%
    group_by(year, gss_in, sex, age) %>%
    summarise(internal_in = sum(value), .groups = "drop") %>%
    rename(gss_code = gss_in) %>%
    mutate(internal_in = round(internal_in, rounding))

  outflow_query <- od_flows_pq %>%
    group_by(year, gss_out, sex, age) %>%
    summarise(internal_out = sum(value), .groups = "drop") %>%
    rename(gss_code = gss_out) %>%
    mutate(internal_out = round(internal_out, rounding))

  inflows <- inflow_query %>%
    collect() %>%
    complete(gss_code, age, year, sex, fill = list(internal_in = 0))

  outflows <- outflow_query %>%
    collect() %>%
    complete(gss_code, age, year, sex, fill = list(internal_out = 0))

  gross_flows <- full_join(inflows, outflows, by = NULL) %>%
    replace_na(list(internal_in = 0, internal_out = 0)) %>%
    mutate(internal_net = internal_in - internal_out) %>%
    pivot_longer(cols = c("internal_in", "internal_out", "internal_net"),
                 names_to = "component",
                 values_to = "value")

  return(gross_flows)
}
