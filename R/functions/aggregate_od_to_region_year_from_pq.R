library(dplyr)
library(arrow)

aggregate_od_to_region_year_from_pq <- function(sel_year,
                                                od_flows_pq,
                                                in_geog_name,
                                                out_geog_name = NULL,
                                                lookup) {

  query <- od_flows_pq %>%
    filter(year == sel_year,
           geography == in_geog_name)

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

  if(!is.null(out_geog_name)) {out_df <- mutate(out_df, geography = out_geog_name)}

  return(out_df)
}
