library(tidyverse)

fpath <- list(raw_lookup_lad_ctry = "lookups/LAD21_CTRY21_UK_LU.csv",
              lookup_lad_ctry = "lookups/lookup_lad_ctry.rds")

# https://geoportal.statistics.gov.uk/datasets/ons::local-authority-district-to-country-april-2021-lookup-in-the-united-kingdom/explore

lookup_scot_ni <- data.frame(gss_code = c("N92000002", "S92000003"),
                             gss_name = c("Northern Ireland", "Scotland"),
                             RGNCD = c("N92000002", "S92000003"),
                             RGNNM = c("Northern Ireland", "Scotland")
)


read_csv(fpath$raw_lookup_lad_ctry) %>%
    select(gss_code = LAD21CD, gss_name = LAD21NM, RGNCD = CTRY21CD, RGNNM = CTRY21NM) %>%
    distinct() %>%
  bind_rows(lookup_scot_ni) %>%
  saveRDS(fpath$lookup_lad_ctry)
