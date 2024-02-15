library(dplyr)

aggregate_od_to_region <- function(in_df, lookup) {

  out_df <- in_df %>%
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
