# write_P4MI.R  write appropriate data to P4MI database

# read up-to-date glucose_records from p4mi database
# read activity data from local disk
# combine activity data with sleep_and_hr as well as any notes fields from glucose data
# make notes_records
# write it to P4MI


library(tidyverse)
library(dplyr)
library(DBI)

library(lubridate)


Sys.setenv(R_CONFIG_ACTIVE = "p4mi")
USER_ID = 13


conn_args <- config::get("dataconnection")
con <- DBI::dbConnect(drv = conn_args$driver,
                      user = conn_args$user,
                      host = conn_args$host,
                      port = conn_args$port,
                      dbname = conn_args$dbname,
                      password = conn_args$password)



message("write notes records")
# DBI::dbWriteTable(con, name = "notes_records", value = notes_records, row.names = FALSE, overwrite = TRUE)
DBI::dbDisconnect(con)
