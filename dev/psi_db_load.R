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


psi_write_glucose <- function(newtable=glucose_df_from_libreview_csv()) {
    message("write glucose records")
    maxDate <-
        DBI::dbGetQuery(con, "select max(\"time\") from glucose_records;")$max
    new_records <-
        newtable %>% dplyr::filter(time > if_else(is.na(maxDate), min(glucose_records$time), maxDate))

    # uncomment the following line to do the actual write to db
    # dbWriteTable(con, name = "glucose_records", value = new_records, row.names = FALSE, append = TRUE)

    message("write notes records")

    # uncomment the following line
    # DBI::dbWriteTable(con, name = "notes_records", value = notes_records, row.names = FALSE, overwrite = TRUE)


    DBI::dbDisconnect(con)

}


