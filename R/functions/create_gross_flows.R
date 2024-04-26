library(dplyr)
library(tidyr)

create_gross_flows <- function(od_flows, rounding = 2) {

  inflows <- od_flows %>%
    group_by(across(-any_of(c("gss_out", "value")))) %>%
    summarise(internal_in = sum(value), .groups = "drop") %>%
    rename(gss_code = gss_in) %>%
    mutate(internal_in = round(internal_in, rounding)) %>%
    complete(gss_code, age, year, sex, fill = list(internal_in = 0))

  outflows <- od_flows %>%
    group_by(across(-any_of(c("gss_in", "value")))) %>%
    summarise(internal_out = sum(value), .groups = "drop") %>%
    rename(gss_code = gss_out) %>%
    mutate(internal_out = round(internal_out, rounding)) %>%
    complete(gss_code, age, year, sex, fill = list(internal_out = 0))

  gross_flows <- full_join(inflows, outflows, by = NULL) %>%
    replace_na(list(internal_in = 0, internal_out = 0)) %>%
    mutate(internal_net = internal_in - internal_out) %>%
    pivot_longer(cols = c("internal_in", "internal_out", "internal_net"),
                 names_to = "component",
                 values_to = "value")

  return(gross_flows)
}
