library(dplyr)
library(arrow)

aggregate_od_to_region_year_from_pq <- function(sel_year, od_flows_pq, lookup) {

  query <- od_flows_pq %>%
    filter(year == sel_year)

  out_df <- query %>%
    collect() %>%
    left_join(lookup, by = c("gss_in" = "gss_code")) %>%
    select(-any_of(c("RGNNM", "gss_name", "gss_in"))) %>%
    rename(gss_in = RGNCD) %>%
    left_join(lookup, by = c("gss_out" = "gss_code")) %>%
    select(-any_of(c("RGNNM", "gss_name", "gss_out"))) %>%
    rename(gss_out = RGNCD) %>%
    group_by(across(-any_of(c("value")))) %>%
    summarise(value = sum(value), .groups = "drop") %>%
    filter(gss_in != gss_out)

  return(out_df)
}
