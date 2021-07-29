
library(tidyverse)
library(lubridate)

start_date <- as_datetime("2021-06-23", Sys.timezone())
time_length = 10
hrs = 0

mins <- start_date + lubridate::hours(hrs) + lubridate::minutes(time_length)

glucose_df_from_db(user_id = 1235, from_date = start_date) # %>%
 # filter(time<= mins )
