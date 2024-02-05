library(dplyr)
library(tidyr)
library(readxl)
library(readr)

clean_data <- function(raw_path, sheet_name, clean_path, max_age = 90) {

  out_df <- read_excel(raw_path, sheet = sheet_name) %>%
    rename(any_of(c(sex = "Sex", gss_in = "inla", gss_out = "outla", year = "Year"))) %>%
    mutate(sex = recode(sex,
                        "F" = "female",
                        "M" = "male")) %>%
    pivot_longer(cols = starts_with("Age_"),
                 names_prefix = "Age_",
                 names_to = "age",
                 values_to = "value") %>%
    mutate(age = as.numeric(age)) %>%
    mutate(age = case_when(
      age > max_age ~ max_age,
      TRUE ~ age
    )) %>%
    group_by(across(-any_of(c("value")))) %>%
    summarise(value = sum(value), .groups = "drop")

  saveRDS(out_df, file = clean_path)
}
