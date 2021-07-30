
library(tidyverse)
library(lubridate)

start_date <- as.POSIXlt("2021-06-17") #as_datetime("2021-06-16", Sys.timezone())
time_length = 120
hrs = 18

begin <- start_date + lubridate::hours(hrs)
end <- start_date + lubridate::hours(hrs) + lubridate::minutes(time_length)

glucose_df_from_db(user_id = 1235)  %>% arrange(time) %>%  filter(time >= begin & time<= end )

#glucose_df_from_db(user_id = 1235) %>% filter(time >= start_date) %>% View()


glucose_df_from_db(user_id = 1235)  %>% arrange(time) %>% filter(time >= 1623888000)

