
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




user_df_from_libreview$user_id

selectInput("user_id", label = "User Name",
            choices = with(user_df_from_libreview, paste(first_name,last_name)),
            selected = "Richard Sprague")


with(user_df_from_libreview, paste(first_name,last_name))


my_filter <- function(x) {
  return(x)
}

testers <- c(1234,1235,1001)
glucose_df_for_users_at_time(user_id = user_df_from_libreview$user_id, startTime = (now() - weeks(7)))

food_times_df(user_id = user_df_from_libreview$user_id , foodname = "Real food") %>% arrange(user_id)

tbl(con, "glucose_records") %>% collect()  %>% group_by(user_id) %>% summarize(n())

tbl(con, "notes_records") %>% collect()  %>% group_by(user_id) %>% summarize(n()) #add_count() # %>%

tbl(con, "notes_records") %>%  filter(Activity == "Food") %>% collect()  %>% filter(stringr::str_detect(Comment, "Real")) # filter(stringr::str_detect(stringr::str_to_lower(Comment) ==  stringr::str_to_lower("Real Food")))

tbl(con, "notes_records") %>% filter(Activity == "Food") %>% group_by(Comment, user_id) %>%
  summarize(n = n()) %>% filter(n>1) %>%
  group_by(user_id) %>% summarize(n())

