library(tidyverse)

fpath <- list(raw_lookup_lad_ctry = "data/lookups/Local_Authority_District_to_Country_(April_2023)_Lookup_in_the_UK.csv",
              lookup_lad_ctry = "lookups/lookup_lad_ctry.rds")

if(file.exists(fpath$raw_lookup_lad_ctry)) {

  lookup_scot_ni <- data.frame(
    gss_code = c("N92000002", "S92000003"),
    gss_name = c("Northern Ireland", "Scotland"),
    RGNCD = c("N92000002", "S92000003"),
    RGNNM = c("Northern Ireland", "Scotland")
  )

  lookup_lad_ctry <- read_csv(fpath$raw_lookup_lad_ctry) %>%
    select(gss_code = LAD23CD, gss_name = LAD23NM, RGNCD = CTRY23CD, RGNNM = CTRY23NM) %>%
    distinct() |>
    bind_rows(
      lookup_scot_ni
    )

  saveRDS(lookup_lad_ctry, fpath$lookup_lad_ctry)

} else {

  warning(fpath$raw_lookup_lad_ctry, " not found. Local Authority to country lookup not created.")

}
