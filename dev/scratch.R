
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


new_food_times_df <-
  function(conn_args = config::get("dataconnection"),
           timeLength = 120,
           foodname = "watermelon",
           db_filter = function(x) {
             x
           }) {
    con <- DBI::dbConnect(
      drv = conn_args$driver,
      user = conn_args$user,
      host = conn_args$host,
      port = conn_args$port,
      dbname = conn_args$dbname,
      password = conn_args$password
    )

    notes_df <-
      tbl(con, "notes_records") %>% collect() %>%  db_filter() %>%
      filter(stringr::str_detect(
        stringr::str_to_lower(Comment),
        stringr::str_to_lower(foodname)
      ))

    df <- NULL

    users <- unique(notes_df$user_id)

    for (user in users) {
      f <- tbl(con, "glucose_records") %>% filter(user_id == user) %>% filter(!is.na(value))
      times <- notes_df %>% filter(user_id == user)  %>% pull(Start)
      for (atime in times) {

        t0 <- as_datetime(atime)
        tl <- as_datetime(t0 + minutes(timeLength))

        new_df <- f %>%
          filter(time >= t0 & time <= tl) %>% collect() %>%
          transmute(t = as.numeric(time - min(time))/60,
                    value = value,
                    meal=sprintf("%s%s-%i/%i",
                            substring(username_for_id(user),1,1),
                            str_split(username_for_id(user),
                                      " ")[[1]][2],
                            month(as_datetime(atime)),
                            day(as_datetime(atime))),
               foodname = foodname,
               user_id = factor(user_id)) #user_id=factor(user_id, levels = original_levels))
       df <- bind_rows(df,new_df)

      }
    }

  return(df)

}


# new_food_times_df(foodname = "blueberries") %>% distinct(user_id)
# food_times_df(foodname="blueberries") %>% distinct(user_id)

notes_df <-
  tbl(con, "notes_records") %>% collect()  %>%
  filter(stringr::str_detect(
    stringr::str_to_lower(Comment),
    stringr::str_to_lower("blueberries")
  ))


system.time(new_food_times_df(foodname = "blueberries"))
system.time(food_times_df(foodname="blueberries"))


new_food_times_df(foodname = "blueberries") %>% distinct(user_id)
new_food_times_df(foodname = "blueberries", db_filter = function(x) {x[["user_id"]]==1234})
n <- new_food_times_df(foodname = "blueberries") #%>% group_by(meal) %>% arrange(t) %>% summarize(t, value)
  # group_by(meal) %>% arrange(time) %>%
  # transmute(t=time - first(time),
  #           value=value,
  #           meal=meal,
  #           foodname = foodname,
  #           user_id=user_id) %>% ungroup()


x <- food_times_df(foodname="blueberries")
food_times_df(foodname="Real Food Bar")

food_times_df(user_id = c(1234), foodname="Real") %>%
  ggplot(aes(x=t,y=value,color=meal)) + geom_line()


food_times_df(user_id = 1002, foodname="Real Food") %>%
  group_by(meal) %>% arrange(t) %>% summarize(t,meal,value, user_id) #%>%
  ggplot(aes(x=t,y=value,color=meal)) + geom_line()

  #ggplot(aes(x=t,y=value, color = user_id)) + geom_line()

#new_food_times_df(foodname = "blueberries") %>% arrange(time)# %>% group_by(meal) %>% arrange(time)


name_from_libreview_file(file.path(config::get("tastermonial")$datadir, "Robert Lewis_glucose_8-31-2021.csv"))

exceptions <- read_csv(file.path(file.path(config::get("tastermonial")$datadir,
                                           "Tastermonial_Exceptions.csv"))) %>%
  mutate(fullname=paste(first_name, last_name))

