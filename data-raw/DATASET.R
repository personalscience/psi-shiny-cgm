## code to prepare `DATASET` dataset goes here

sample_libreview_df <- read_libreview_csv(system.file("extdata", "Firstname1Lastname1_glucose.csv"))
usethis::use_data(sample_libreview_df, overwrite = TRUE)
