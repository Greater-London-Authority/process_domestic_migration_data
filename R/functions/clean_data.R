library(dplyr)
library(tidyr)
library(readxl)
library(readr)
library(stringr)

clean_data <- function(raw_path, sheet_name, max_age = 90) {

  out_df <- read_excel(raw_path, sheet = sheet_name) %>%
    rename(any_of(c(sex = "Sex", gss_in = "inla", gss_out = "outla", year = "Year"))) %>%
    mutate(sex = recode(sex,
                        "F" = "female",
                        "f" = "female",
                        "m" = "male",
                        "M" = "male")) %>%
    pivot_longer(cols = starts_with("Age_"),
                 names_prefix = "Age_",
                 names_to = "age",
                 values_to = "value") %>%
    mutate(age = as.numeric(str_extract(age, "[0-9]+"))) %>%
    mutate(age = case_when(
      age > max_age ~ max_age,
      TRUE ~ age
    )) %>%
    group_by(across(-any_of(c("value")))) %>%
    summarise(value = sum(value), .groups = "drop")

  return(out_df)
}
