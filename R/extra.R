# Extra functions, most of which are doomed to deprecation and/or to be factored into other packages


#' @title Glucose values for ID after startDate
#' @description
#' For example `read_glucose_for_user_at_time(ID=22,startTime = as_datetime("2020-02-16 00:50:00", tz=Sys.timezone()))`
#' @param conn_args valid database connection
#' @param user_id user ID
#' @param startTime datetime object for start time
#' @param timelength minutes of glucose values to return
#' @return A valid glucose dataframe
#' @export
glucose_df_for_users_at_time <- function(conn_args=config::get("dataconnection"),
                                         user_id=1234,
                                         startTime=now()-hours(36),
                                         timelength=120){


  con <- DBI::dbConnect(drv = conn_args$driver,
                        user = conn_args$user,
                        host = conn_args$host,
                        port = conn_args$port,
                        dbname = conn_args$dbname,
                        password = conn_args$password)

  ID = user_id

  cutoff_1 <- as_datetime(startTime)
  cutoff_2 <- as_datetime(startTime + minutes(timelength))

  glucose_df <- tbl(con, conn_args$glucose_table)  %>%
    filter(user_id %in% ID & time >= cutoff_1 &
             time <= cutoff_2) %>% collect()

  #  filter(user_id == ID & (record_date+record_time) >= startTime & (record_date+record_time) <= (startTime + timelength)) %>% collect()# & top_n(record_date,2))# %>%

  glucose_raw <- glucose_df %>% transmute(  time = force_tz(as_datetime(time), Sys.timezone()),
                                            scan = value, hist = value, strip = NA, value = value,
                                            food = as.character(stringr::str_match(food,"Notes=.*")),
                                            user_id = user_id)



  DBI::dbDisconnect(con)
  glucose_raw
}

#' @title return a dataframe of rows in the database where food matches food
#' @description
#' Search the notes database for records indicating `foodname` and
#' return just those rows that contain that food.
#' @param conn_args database connection
#' @param user_id user ID
#' @param foodname a string indicating a specific food
#' @import DBI stringr
#' @return a valid glucose dataframe containing records matching `food`
#' @export
glucose_for_food_df <- function(conn_args=config::get("dataconnection"),
                                user_id = 1235,
                                foodname = "blueberries"){


  con <- DBI::dbConnect(drv = conn_args$driver,
                        user = conn_args$user,
                        host = conn_args$host,
                        port = conn_args$port,
                        dbname = conn_args$dbname,
                        password = conn_args$password)


  ID <-  user_id

  nf <- notes_df_from_notes_table(conn_args,
                                  user_id = ID,
                                  db_filter = function(x) {x}) %>%
    filter(stringr::str_detect(stringr::str_to_lower(Comment), stringr::str_to_lower(foodname)))

  return(nf)
}


#' @title Convert the timestamp into time objects
#' @param times_vector vector of start times.
#' @return a vector normalized to the beginning of the sequence
#' @export
zero_time <- function(times_vector){
  start <- min(times_vector)

  return(as.numeric((times_vector-start)/60))

}

#' @title Normalize time dataframe to zero
#' @param df valid glucose dataframe
#' @return dataframe
#' @export
make_zero_time_df <- function(df){
  return(arrange(df,time) %>% transmute(t=zero_time(time),
                                        value=value,
                                        meal=meal,
                                        user_id=user_id))
}

#' @title return a new df where value are normalized to start from zero.
#' @param df dataframe
#' @return dataframe
#' @export
normalize_value <- function(df){
  return(df %>% mutate(value=value-first(value)))


}


#' @title Glucose values after eating a specific food
#' @description
#' return a dataframe of the Glucose values for a `timeLength`
#' following `foodname` appearing in `notes_records`
#' @param user_id user ID
#' @param foodname character string representing the food item of interest
#' @param timeLength number of minutes for the glucose record to show after the food was eaten.
#' @return dataframe
#' @export
old_food_times_df <- function(user_id = 1235, timeLength=120, foodname="watermelon"){


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
