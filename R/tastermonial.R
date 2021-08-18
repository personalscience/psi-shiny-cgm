# Tastermonial Read Functions


#' @title Read a Tastermonial Airtable file from CSV
#' @description Turn a Tastermonial Airtable file into a canonical dataframe.
#' @param file path to a CSV file
#' @return canonical dataframe of Tastermonial information
#' @export
taster_df <- function(file = file.path(config::get("tastermonial")$datadir, "TastermonialNotes.csv")){

  taster_raw <-
    readr::read_csv(file, col_types=cols()) %>%
    transmute(email = Email,
              pid = ProductID,
              timestamp = lubridate::mdy_hm(`AUTO: Created At`),
              hasCGM = if_else(`is CGM?`=="checked", TRUE, FALSE),
              productName = ProductName,
              priorEating = stringr::str_split(`Prior to eating, I had or did`, pattern = ","),
              twoHours = stringr::str_split(`Within two hours of eating, I had or did`,pattern = ",")
    )

  return(taster_raw)

}

#' @title Return user list from Tastermonial Libreview download
#' @description A Libreview "practice" stores all its user information in a single
#' CSV file, which this function will convert into a canonical dataframe.
#' @param file the main file downloaded from a Libreview practice ID
user_df_from_csv <- function(file = system.file("extdata", package = "psiCGM", "Tastermonial_allPatients_dashboard.csv")){
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

extra_user_df <- read_csv(file = system.file("extdata",
                                             package = "psiCGM",
                                             "Tastermonial_Extra_Users.csv"),
                          col_types = "cccccd") %>% mutate(birthdate = lubridate::mdy(birthdate))

#' @title Users known to Libreview Practice Portal
#' @description
#' A dataframe of all users and their ids, taken from the Libreview practice portal
#' @export
user_df_from_libreview <-
  user_df_from_csv() %>% mutate(user_id = row_number() + 1000) %>%
  dplyr::anti_join(extra_user_df,
                   by = c("first_name", "last_name")) %>% bind_rows(extra_user_df)

