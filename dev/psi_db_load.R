# Script to load database tables
# Assumes existence of `glucose_records`
# To erase the current glucose_records table from the database and start over:
# psi_fill_database_from_scratch(drop=TRUE)


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

    ID <- user_id

    psi_make_table_if_necessary(conn_args = conn_args, table = new_table)

    maxDate <- psiCGM:::max_date_for_user(conn_args, user_id = ID)
    new_records <-
       new_table %>% dplyr::filter(time > {if(is.na(maxDate)) min(time) else maxDate}) %>%
        dplyr::filter(user_id == ID)



    message("write glucose records")

    # uncomment the following line to do the actual write to db
   DBI::dbWriteTable(con, name = "glucose_records", value = new_records, row.names = FALSE, append = TRUE)

    message("write notes records (not working yet)")

    # uncomment the following line
    # DBI::dbWriteTable(con, name = "notes_records", value = notes_records, row.names = FALSE, overwrite = TRUE)


    DBI::dbDisconnect(con)

}

#' @title Write a Notes CSV to the notes table in the database
#' @description
#' WARNING: Only run this on a fresh clean notes_records table.
#' psi_write_notes(user_id = 1234, new_table = notes_df_from_glucose_table(user_id = 1234))
#' @param user_id user ID
#' @param new_table valid formatted notes dataframe
#' @param dry_run (default = TRUE). Run without actually writing to the database
psi_write_notes <- function(conn_args = config::get("dataconnection"),
                               user_id = 1235,
                               new_table=notes_df_from_csv(user_id = 1235),
                            dry_run = TRUE) {

    con <- DBI::dbConnect(
        drv = conn_args$driver,
        user = conn_args$user,
        host = conn_args$host,
        port = conn_args$port,
        dbname = conn_args$dbname,
        password = conn_args$password
    )

    ID <- user_id
    message("write notes records")

    if(dry_run){
        message("not going to actually write this")
    } else {
    # uncomment the following line to do the actual write to db
    DBI::dbWriteTable(con, name = "notes_records", value = new_table, row.names = FALSE, append = TRUE)
    }
    return(new_table)


    DBI::dbDisconnect(con)
}


#' @description
#'  For debugging and dev purposes only. Loads the database tables from scratch.
psi_fill_database_from_scratch <- function(conn_args = config::get("dataconnection"),
                                       drop = TRUE) {

    con <- DBI::dbConnect(
        drv = conn_args$driver,
        user = conn_args$user,
        host = conn_args$host,
        port = conn_args$port,
        dbname = conn_args$dbname,
        password = conn_args$password
    )

    if(drop) {
        message("removing glucose records table")
        DBI::dbRemoveTable(con, "glucose_records")
    }
    martha_glucose <- file.path("/Users/sprague/dev/psi/psiCGM/inst/extdata/Firstname1Lastname1_glucose.csv")
    richard_glucose <- file.path("/Users/sprague/dev/psi/psiCGM/inst/extdata/Firstname2Lastname2_glucose.csv")
    message("write Martha glucose records")
    psi_write_glucose(conn_args = conn_args,
                      user_id = 1235,
                      new_table=glucose_df_from_libreview_csv(file = martha_glucose, user_id = 1235))
    message("write Richard glucose records")
    psi_write_glucose(conn_args = conn_args,
                      user_id = 1234,
                      new_table=glucose_df_from_libreview_csv(file = richard_glucose, user_id = 1234))

    message("finished writing")

}


# uncomment this section to add an arbitrary new CSV file
# be sure to set both user_ids
# Write Andreos:
psi_write_glucose(user_id = 1004,
                  new_table = psiCGM:::glucose_df_from_libreview_csv(rstudioapi::selectFile(), user_id = 1004)
)

# write Bude:
psi_write_glucose(user_id = 1008,
                  new_table = psiCGM:::glucose_df_from_libreview_csv(rstudioapi::selectFile(), user_id = 1008)
)

