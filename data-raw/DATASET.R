## code to prepare `sample_libreview_df` dataset goes here


USER_LIST_FILEPATH <- file.path("~/dev/psi/psiCGM","inst","extdata","Tastermonial_all Patients_dashboard.csv")


sample_libreview_df <- glucose_df_from_libreview_csv(system.file("extdata", package = "psiCGM", "Firstname1Lastname1_glucose.csv"))
usethis::use_data(sample_libreview_df, overwrite = TRUE)

#' @title Return user list from Tastermonial Libreview download
user_list_from_csv <- function(file = system.file("extdata", package = "psiCGM", "Tastermonial_all Patients_dashboard.csv")){
  user_df <- readr::read_csv(file = file,
                             skip =1,
                             col_types = cols()) %>%
    transmute(first_name = `First Name`,
              last_name = `Last Name`,
              birthdate = lubridate::mdy(`Date of Birth`),
              latest_data = `Last Available Data`,
              libreview_status = `LibreView User Status`
    )

  return(user_df)
}

user_list_from_libreview <- user_list_from_csv() %>% mutate(user_id = row_number() + 1000)
usethis::use_data(user_list_from_libreview, overwrite = TRUE)
