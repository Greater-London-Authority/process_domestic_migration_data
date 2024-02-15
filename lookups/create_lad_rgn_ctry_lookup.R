library(dplyr)

fpath <- list(lookup_rgn = "lookups/lookup_lad_rgn.rds",
              lookup_ctry = "lookups/lookup_lad_ctry.rds",
              lookup_rgn_ctry = "lookups/lookup_lad_rgn_ctry.rds")

lookup_scot_ni <- data.frame(gss_code = c("N92000002", "S92000003"),
                             gss_name = c("Northern Ireland", "Scotland"),
                             RGNCD = c("N92000002", "S92000003"),
                             RGNNM = c("Northern Ireland", "Scotland")
)

lookup_rgn_ctry <- bind_rows(
  readRDS(fpath$lookup_rgn),
  filter(readRDS(fpath$lookup_ctry), RGNNM == "Wales"),
  lookup_scot_ni)

saveRDS(lookup_rgn_ctry, fpath$lookup_rgn_ctry)
