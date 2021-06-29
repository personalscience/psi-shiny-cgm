# librelink_csv_to_db.R  # pull everything from a CSV file and send to the database


library(tidyverse)
library(lubridate)

#` read a valid libreview CSV file and return a dataframe and new user id`
read_libreview_csv <- function(file=file.path(Sys.getenv("ONEDRIVE"),
                                              "General","Health",
                                              "RichardSprague_glucose.csv"),
                               user_id = 1234) {


  glucose_raw <-
    readr::read_csv(file, skip = 1, col_types = "cccdddddcddddcddddd") %>%
    transmute(
      timestamp = lubridate::mdy_hm(`Device Timestamp`),
      record_type = `Record Type`,
      glucose_historic = `Historic Glucose mg/dL`,
      glucose_scan = `Scan Glucose mg/dL`,
      strip_glucose = `Strip Glucose mg/dL`,
      notes = Notes
    )

  glucose_df <- glucose_raw  %>% transmute(time = `timestamp`,
                                           scan = glucose_scan, hist = glucose_historic, strip = strip_glucose, value = glucose_historic,
                                           food = notes) #as.character(stringr::str_match(notes,"Notes=.*")))

  glucose_df %>% add_column(user_id = user_id)

}

#read_librelink()

# returns a dataframe of glucose values for user_id ID
read_glucose <- function(conn_args=config::get("dataconnection"),
                         ID=13,
                         fromDate="2019-11-01"){

  con <- DBI::dbConnect(drv = conn_args$driver,
                        user = conn_args$user,
                        host = conn_args$host,
                        port = conn_args$port,
                        dbname = conn_args$dbname,
                        password = conn_args$password)


  glucose_df <- tbl(con, conn_args$glucose_table) %>%  collect()# & top_n(record_date,2))# %>%

  glucose_raw <- glucose_df %>% transmute(time = force_tz(as_datetime(time), Sys.timezone()),
                                          scan = value, hist = value, strip = NA, value = value,
                                          food = food,
                                          user_id = user_id)

  return(glucose_raw)
}
