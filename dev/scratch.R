
library(psiCGM)
library(tidyverse)
library(lubridate)

# conn_args=config::get("dataconnection")
# con <- DBI::dbConnect(drv = conn_args$driver,
#                       user = conn_args$user,
#                       host = conn_args$host,
#                       port = conn_args$port,
#                       dbname = conn_args$dbname,
#                       password = conn_args$password)
#


#Sys.setenv(R_CONFIG_ACTIVE = "tastercloud")




#' @title Glucose values after eating a specific food
#' @description
#' return a dataframe of the Glucose values for a `timeLength`
#' following `foodname` appearing in `notes_records`
#' @param user_id user ID
#' @param foodname character string representing the food item of interest
#' @param timeLength number of minutes for the glucose record to show after the food was eaten.
#' @return dataframe
#' @export
food_times_df <- function(user_id = 1235, timeLength=120, foodname="watermelon"){


  f <- glucose_for_food_df(user_id = user_id, foodname=foodname)


  # original_levels <- factor(f$user_id) # to prevent a conversion of id_user to char later

  ID = user_id

  df <- NULL
  for(user in ID){
    g <- f %>% filter(user_id==user)
    for(t in g$Start){
      new_segment_df <- glucose_df_for_users_at_time(user_id =user, startTime = lubridate::as_datetime(t,tz=Sys.timezone())) %>%
        mutate(meal=sprintf("%s%s-%i/%i",
                            substring(username_for_id(user),1,1),
                            str_split(username_for_id(user),
                                      " ")[[1]][2],
                            month(as_datetime(t)),
                            day(as_datetime(t))),
               foodname = sprintf("%s-%i/%i",
                                  foodname,
                                  month(as_datetime(t)),
                                  day(as_datetime(t))),
               user_id = factor(user_id)) #user_id=factor(user_id, levels = original_levels))

      df <- bind_rows(df, transmute(new_segment_df,
                                    t=zero_time(time),
                                    value=value,
                                    meal=meal,
                                    foodname = foodname,
                                    user_id=user_id)
                      #make_zero_time_df(new_segment_df)
                      )
    }
  }
  return(df)
}


bind_rows(
  food_times_df(lookup_id_from_name("Ayumi"),foodname = "kind,"),
  food_times_df(lookup_id_from_name("Ayumi"),foodname = "Real food")
) %>% filter(!is.na(value)) %>% ggplot(aes(t,value, color = foodname)) + geom_line(size = 2)



