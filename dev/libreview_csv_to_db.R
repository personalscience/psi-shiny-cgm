# librelink_csv_to_db.R  # pull everything from a CSV file and send to the database


library(tidyverse)
library(lubridate)


source("R/read_data_utils.R")



# set the active configuration globally via Renviron.site or Rprofile.site
Sys.setenv(R_CONFIG_ACTIVE = "local")  # save to local postgres
# Sys.setenv(R_CONFIG_ACTIVE = "cloud") # save to cloud
# Sys.setenv(R_CONFIG_ACTIVE = "default") # save to sqlite
# Sys.setenv(R_CONFIG_ACTIVE = "cloud")


#' Search the default database for the most recent (aka latest) timestamp
#' @title Most recent date in the database for a given user
#' @param user_id user ID
#' @return a date object representing the most recent record in the database for this user. NA if there are no records.
max_date_for_user <-
  function(conn_args = config::get("dataconnection"),
           user_id = 1234,
           fromDate = "2019-11-01") {
    con <- DBI::dbConnect(
      drv = conn_args$driver,
      user = conn_args$user,
      host = conn_args$host,
      port = conn_args$port,
      dbname = conn_args$dbname,
      password = conn_args$password
    )

    ID = user_id
    glucose_df <- tbl(con, conn_args$glucose_table) %>%
      filter(user_id %in% ID & time >= fromDate)

    # maxDate <-
    #   DBI::dbGetQuery(con, "select max(\"time\") from glucose_records;")$max

    maxDate <-
      tbl(con, conn_args$glucose_table) %>% filter(user_id == ID &
                                                     time == max(time)) %>% pull(time)


    DBI::dbDisconnect(con)

    return(if (length(maxDate > 0))
      maxDate
      else
        NA)


  }

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

demo_libreview_to_db <- function(csv_df = psiCGM:::glucose_df_from_libreview_csv(user_id=1235),
                                 user_id = 1235)
{
  message("showing only those Libreview records that are new")
  new_libreview_csv_records_for_user(csv_df, user_id)

}
