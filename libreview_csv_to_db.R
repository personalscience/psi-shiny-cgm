# librelink_csv_to_db.R  # pull everything from a CSV file and send to the database


library(tidyverse)
library(lubridate)


source("R/read_data_utils.R")



# set the active configuration globally via Renviron.site or Rprofile.site
Sys.setenv(R_CONFIG_ACTIVE = "local")  # save to local postgres
# Sys.setenv(R_CONFIG_ACTIVE = "cloud") # save to cloud
# Sys.setenv(R_CONFIG_ACTIVE = "default") # save to sqlite
# Sys.setenv(R_CONFIG_ACTIVE = "cloud")


#' Most recent date in the database for a given user
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
#' @return dataframe of only those Libreview records that are new for this user_id
new_libreview_csv_records_for_user <- function(libreview_df = read_libreview_csv(), user_id = 1234) {

  md <- max_date_for_user(user_id =user_id)

  new_records <-
    libreview_df %>% dplyr::filter(time > if_else(is.na(md),
                                                  min(libreview_df$time),
                                                  max(libreview_df$time)))
  return(new_records)
}

demo_libreview_to_db <- function()
{
  message("showing only those Libreview records that are new")
  new_libreview_csv_records_for_user(user_id=1235)

}
