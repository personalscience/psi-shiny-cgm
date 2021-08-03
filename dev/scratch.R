
library(psiCGM)
library(tidyverse)
library(lubridate)

conn_args=config::get("dataconnection")
con <- DBI::dbConnect(drv = conn_args$driver,
                      user = conn_args$user,
                      host = conn_args$host,
                      port = conn_args$port,
                      dbname = conn_args$dbname,
                      password = conn_args$password)


from_date= as_datetime("2021-06-15",
                       tz = Sys.timezone())

ID <- c(1234,1008)

tbl(con, "notes_records") %>% filter(user_id == 1234) %>%
  filter(Start == max(Start, na.rm = TRUE)) %>%
  pull(Start)

#' @description
#' Given a dataframe, returns a logical
my_filter <- function(x, ID = 1235){
  filter(filter(x, user_id %in% c(1234,1008)),
         time >= lubridate::as_datetime("2021-06-15",
                             tz = Sys.timezone()))
}

max_date_filter <- function(x, ID = 1234) {
  filter(filter(x, user_id %in% ID),
         time == max(time))
}

file=file.path(Sys.getenv("ONEDRIVE"),
              "General","Health",
              "RichardSprague_glucose.csv")


readr::read_csv(file, skip = 2, col_types = "cccdddddcddddcddddd") %>%
  transmute(
    timestamp = lubridate::mdy_hm(`Device Timestamp`, tz = Sys.timezone()),
    record_type = `Record Type`,
    glucose_historic = `Historic Glucose mg/dL`,
    glucose_scan = `Scan Glucose mg/dL`,
    strip_glucose = `Strip Glucose mg/dL`,
    notes = if_else(!is.na(Notes), paste0("Notes=",Notes),
                    Notes)
  ) %>% filter(!is.na(notes))


glucose_df_from_db(db_filter = max_date_filter) %>% pull(time) %>% head(1)

tbl(con, conn_args$glucose_table) %>%
  filter(user_id == 1234) %>%
  filter(time == max(time, na.rm = TRUE)) %>% show_query()
  pull(time) %>% show_query()

glucose_df_from_db() %>% filter(user_id == 1235)

tbl(con, conn_args$glucose_table) %>% filter(user_id == 1235) %>% filter(time >= "2021-06-15") #%>% show_query()

tbl(con, conn_args$glucose_table) %>% my_filter() %>% show_query()

tbl(con, conn_args$glucose_table) %>% filter(is.na(value)) %>% show_query()

tbl(con, conn_args$glucose_table) %>% filter(time > (today() - weeks(6))) # %>% show_query()
tbl(con, conn_args$glucose_table) %>% filter(time > as_datetime("2021-06-01"))  %>% show_query()
tbl(con, conn_args$glucose_table) %>% filter(time > "2021-06-01" & time < "2021-06-02") %>% head(3) %>% show_query()



as_datetime("2021-06-01", tz = "America/Los_Angeles")

q <- sprintf('SELECT * FROM "glucose_records" WHERE ("time" > \'2021-06-01\' ) LIMIT 10')

DBI::dbGetQuery(con, q)

x <- tbl(con, conn_args$glucose_table) %>% dplyr::filter(user_id %in% ID & time >= from_date)
tbl(con, conn_args$glucose_table) %>% filter(.data[["user_id"]] == 1008)

tbl(con, conn_args$glucose_table) %>% transmute(time = time,
                                                scan = value, hist = value, strip = NA, value = value,
                                                food = food,
                                                user_id = user_id)
q
