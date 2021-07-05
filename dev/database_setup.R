# set up and load all databases
# assumes existence of:
#
# notes_records
# glucose_records

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

conn_args <- config::get("dataconnection")
conn_args

# first time only. Connect to the server, but not to a specific database


psi_list_objects <-
    function(conn_args = config::get("dataconnection")) {
        con <- DBI::dbConnect(
            drv = conn_args$driver,
            user = conn_args$user,
            host = conn_args$host,
            port = conn_args$port,
            dbname = conn_args$dbname,
            password = conn_args$password
        )


        # how to list all objects on the Postgres database server, including database objects
        # dbGetQuery(con, "SELECT datname FROM pg_database
        #WHERE datistemplate = false;" )$datname

        newdb_sqlstring <- paste0(
            "
CREATE DATABASE ",
            conn_args$dbname,
            "
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;"
        )

        ## Add a new database "qsdb" if none exists on this server
        if (conn_args$dbname %in% dbGetQuery(con,
                                             "SELECT datname FROM pg_database
WHERE datistemplate = false;")$datname) {
            NULL
        } else
            dbSendQuery(con, newdb_sqlstring)

        # Now that qsdb is available, use that as the database for everything
        dbDisconnect(con)
    }



con <- DBI::dbConnect(drv = conn_args$driver,
                      user = conn_args$user,
                      host = conn_args$host,
                      dbname = conn_args$dbname,
                      port = conn_args$port,
                      password = conn_args$password)


if(length(DBI::dbListTables(con)) == 0){
    DBI::dbCreateTable(con, "glucose_records", glucose_records)
    DBI::dbCreateTable(con, "notes_records", notes_records)
    DBI::dbCreateTable(con, "watch_records", sleep_and_hr )
} else message(paste("Database fields exist:",DBI::dbListTables(con)))


DBI::dbListObjects(con)
#dbRemoveTable(con,"glucose_records")

write_glucose <- function() {
    message("write glucose records")
    maxDate <-
        DBI::dbGetQuery(con, "select max(\"time\") from glucose_records;")$max
    new_records <-
        glucose_records %>% dplyr::filter(time > if_else(is.na(maxDate), min(glucose_records$time), maxDate))

    # uncomment the following line to do the actual write to db
    # dbWriteTable(con, name = "glucose_records", value = new_records, row.names = FALSE, append = TRUE)

    message("write notes records")

    # uncomment the following line
    # DBI::dbWriteTable(con, name = "notes_records", value = notes_records, row.names = FALSE, overwrite = TRUE)


    DBI::dbDisconnect(con)

}


