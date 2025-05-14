library(dplyr)


fpath <- list(lookup_lad_itl = "lookups/lookup_lad_itl.rds",
              lookup_lad_inner_outer_london = "lookups/lookup_lad_inner_outer_london.rds")

lookup_lad_itl <- readRDS(fpath$lookup_lad_itl)

lookup_lad_inner_outer_london <- lookup_lad_itl %>%
  mutate(RGNCD = recode(RGNCD,
                        "TLI3" = "E13000001",
                        "TLI4" = "E13000001",
                        "TLI5" = "E13000002",
                        "TLI6" = "E13000002",
                        "TLI7" = "E13000002",
                        )) %>%
  mutate(RGNCD = case_when(
    RGNCD %in% c("E13000001", "E13000002") ~ RGNCD,
    TRUE ~ "other")) %>%
  mutate(RGNNM = case_when(
    RGNCD == "E13000001" ~ "Inner London",
    RGNCD == "E13000002" ~ "Outer London",
    TRUE ~ "other"
  ))

saveRDS(lookup_lad_inner_outer_london, fpath$lookup_lad_inner_outer_london)
