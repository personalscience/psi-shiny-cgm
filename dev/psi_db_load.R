# Script to load database tables
# Assumes existence of `glucose_records`



# see more examples at https://rpostgres.r-dbi.org/
library(tidyverse)
library(lubridate)


# set the active configuration globally via Renviron.site or Rprofile.site
Sys.setenv(R_CONFIG_ACTIVE = "local")  # save to local postgres
# Sys.setenv(R_CONFIG_ACTIVE = "cloud") # save to cloud
# Sys.setenv(R_CONFIG_ACTIVE = "default") # save to sqlite
# Sys.setenv(R_CONFIG_ACTIVE = "cloud")

# run the following script to load these variables.
# glucose_records, notes_records, sleep_and_hr
# source("util/read_glucose_data.R")  # read raw glucose, notes, and watch data.

#' @title Write a glucose dataframe to the database
#' @description
#' WARNING: always delete the table before running this on a `user_id` that's already in the database.
#' (it's not finished yet and doesn't take into account previous entries)
#' @param new_table valid formatted glucose dataframe
psi_write_glucose <- function(conn_args = config::get("dataconnection"),
                              user_id = 1235,
                              new_table=glucose_df_from_libreview_csv(user_id = 1235)) {

    con <- DBI::dbConnect(
        drv = conn_args$driver,
        user = conn_args$user,
        host = conn_args$host,
        port = conn_args$port,
        dbname = conn_args$dbname,
        password = conn_args$password
    )

    message("write glucose records")

    DBI::dbWriteTable(con, "glucose_records", new_table, append = TRUE)

    maxDate <- psiCGM:::max_date_for_user(conn_args, user_id = user_id)
    #new_records <-
    #    new_table %>% dplyr::filter(time > if_else(is.na(maxDate), min(conn_args$glucose_table$time), maxDate))

    # uncomment the following line to do the actual write to db
    #DBI::dbWriteTable(con, name = "glucose_records", value = new_records, row.names = FALSE, append = TRUE)

    message("write notes records (not working yet)")

    # uncomment the following line
    # DBI::dbWriteTable(con, name = "notes_records", value = notes_records, row.names = FALSE, overwrite = TRUE)


    DBI::dbDisconnect(con)

}


