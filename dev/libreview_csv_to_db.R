# librelink_csv_to_db.R  # pull everything from a CSV file and send to the database


library(tidyverse)
library(lubridate)


source("R/read_data_utils.R")



# set the active configuration globally via Renviron.site or Rprofile.site
Sys.setenv(R_CONFIG_ACTIVE = "local")  # save to local postgres
# Sys.setenv(R_CONFIG_ACTIVE = "cloud") # save to cloud
# Sys.setenv(R_CONFIG_ACTIVE = "default") # save to sqlite
# Sys.setenv(R_CONFIG_ACTIVE = "cloud")




#' New Libreview records
#' @param libreview_df a valid Libreview dataframe as read directly from CSV
#' @param user_id user id
#' @return dataframe of only those Libreview records that are not already in the database for this user_id
new_libreview_csv_records_for_user <- function(libreview_df = psiCGM:::glucose_df_from_libreview_csv(), user_id = 1234) {

  md <- max_date_for_user(user_id =user_id)  # note that this makes a call to a database

  new_records <-
    libreview_df  %>%
    dplyr::filter(user_id == user_id) %>%
    dplyr::filter(time > {if(is.na(md)) min(libreview_df$time) else md })

  return(new_records)
}

#' @title Demo: which records will be written to db
#' @description Won't actually write anything though.
#' @return dataframe of which records would be written if you decide to write.
demo_libreview_to_db <- function(csv_df = psiCGM:::glucose_df_from_libreview_csv(user_id=1235),
                                 user_id = 1235)
{
  message("showing only those Libreview records that are new")
  new_libreview_csv_records_for_user(csv_df, user_id)

}
