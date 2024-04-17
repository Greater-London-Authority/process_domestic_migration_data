library(dplyr)

aggregate_to_age_bands <- function(in_df,
                                   c_breaks = c(-Inf,
                                                17, 29, 39,
                                                49, 64, Inf),
                                   c_labels = c("0 to 17", "18 to 29", "30 to 39",
                                                "40 to 49", "50 to 64", "65+")){

  out_df <- in_df %>%
    mutate(age_band = cut(age,
                          breaks = c_breaks,
                          labels = c_labels)) %>%
    group_by(across(-any_of(c("value", "age")))) %>%
    summarise(value = sum(value, na.rm = TRUE),
              .groups = "drop")

  return(out_df)
}
