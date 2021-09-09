
library(psiCGM)
library(tidyverse)
library(lubridate)


#Sys.setenv(R_CONFIG_ACTIVE = "tastercloud")
#Sys.setenv(R_CONFIG_ACTIVE = "localtest")
#Sys.setenv(R_CONFIG_ACTIVE = "local")
conn_args=config::get("dataconnection")
con <- DBI::dbConnect(drv = conn_args$driver,
                      user = conn_args$user,
                      host = conn_args$host,
                      port = conn_args$port,
                      dbname = conn_args$dbname,
                      password = conn_args$password)


prods <-
  tbl(con, "notes_records") %>% filter(Activity == "Food") %>%
  filter(Start > "2021-06-01") %>% filter(user_id %in% c(1234)) %>% distinct(Comment) %>%
  collect() %>% pull(Comment)

cow <- food_times_df(foodname = "Cream of Wheat")
cow20 <- food_times_df(prefixLength = 20, foodname = "Cream of Wheat")
food_times_df(foodname = "Cream of Wheat", prefixLength = 20 )

cow %>% group_by(meal) %>% slice(1)
