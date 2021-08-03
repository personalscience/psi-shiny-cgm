
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

from_date= as_datetime("2021-06-15",
                       tz = Sys.timezone())

foodname = "watermelon"

ID <- c(1234,1008,1235)
user_id = 1235

f <- glucose_for_food_df(user_id = 1235, foodname=foodname)
f$user_id
f

original_levels <- levels(f$user_id) # to prevent a conversion of id_user to char later

ID = user_id

df <- NULL
for(user in ID){
  g <- f %>% filter(user_id==user)
  for(t in g$Start){
    new_segment_df <- glucose_df_for_users_at_time(user_id =user, startTime = lubridate::as_datetime(t,tz=Sys.timezone())) %>%
      mutate(meal=paste0(user,"-",month(as_datetime(t)),"/",day(as_datetime(t))),
             user_id=factor(user_id, levels = original_levels))
    df <- bind_rows(df,make_zero_time_df(new_segment_df))
  }
}
df

