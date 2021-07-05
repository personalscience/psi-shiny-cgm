# create_db
# Use this script only once: to set up the initial database and scheme

library(tidyverse)


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

  dbName <- conn_args$dbname
  dbHost <- conn_args$host

  objects <- dbListObjects(con)
  tables <- dbListTables(con)

  dbDisconnect(con)
  return(list(dbName=dbName, dbHost=dbHost, objects=objects, tables=tables))

}
psi_list_objects()


psi_glucose_table <-
  function(conn_args = config::get("dataconnection")) {
    con <- DBI::dbConnect(
      drv = conn_args$driver,
      user = conn_args$user,
      host = conn_args$host,
      port = conn_args$port,
      dbname = conn_args$dbname,
      password = conn_args$password
    )

    glucose_df <- tbl(con, "glucose_records") %>% collect()

    dbDisconnect(con)

    return(glucose_df)

  }

psi_glucose_table()


