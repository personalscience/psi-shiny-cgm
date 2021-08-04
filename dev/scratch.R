
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


tbl(con,"notes_records") %>% filter(user_id == 1235 & !is.na(Comment)) %>% collect() %>% group_by(Comment) %>% add_count() %>% filter(n>1)



taster_data_path <- config::get("tastermonial")$datadir
datafiles <- list.files(taster_data_path)
datafiles <- datafiles[datafiles %>% str_detect("glucose")]


name_from_libreview_file(file.path(taster_data_path,datafiles[1]))

lookup_id_from_name(name_from_libreview_file(file.path(taster_data_path,datafiles[1])))


df %>% group_by(user_id) %>%
  summarize(max = max(value, na.rm = TRUE), min = min(value, na.rm = TRUE), n()) %>%
  mutate(username = user_id) %>% pull(username) %>% sapply(psiCGM:::username_for_id)

