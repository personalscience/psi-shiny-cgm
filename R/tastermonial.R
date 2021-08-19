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

