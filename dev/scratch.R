
library(tidyverse)
library(lubridate)

start_date <- "2021-06-16" %>% as_datetime() %>% force_tz(tz=Sys.timezone())
time_length = 10
hrs = 12

mins <- start_date + lubridate::hours(hrs) + lubridate::minutes(time_length)

glucose_df_from_db(user_id = 1235, from_date = start_date) # %>%
  filter(time<= mins )
