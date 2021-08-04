# read_data_utils.R
# generalized functions to read data, either from disk or from databases
#

# Note: only works with p4mi database (or any db that includes a user_id)
# Sys.setenv(R_CONFIG_ACTIVE = "p4mi")

# library(tidyverse)
# library(lubridate)

# Initial constants ----

#' Default Librelink CSV file.
DEFAULT_LIBRELINK_FILE_PATH <- file.path(Sys.getenv("ONEDRIVE"),"General", "Health",
                                         "RichardSprague_glucose.csv")

#' @title Possible values for `Activity` column in Notes.
NOTES_COLUMNS <- c("Sleep", "Event", "Food","Exercise")

# Read CSV ----

#' Read a valid libreview CSV file and return a dataframe and new user id
#' Since Libreview files don't already include a user ID, append one to the dataframe that is returned.
#' Importantly, datetimes are assumed to be `Sys.timezone()`.
#' @title Read a standard format Libreview CSV file
#' @return a canonical glucose value dataframe
#' @param file path to a valid Libreview CSV file
#' @param user_id new user ID to be appended to the dataframe
#' @export
#' @import readr magrittr tibble
#' @import lubridate
glucose_df_from_libreview_csv <- function(file=file.path(Sys.getenv("ONEDRIVE"),
                                              "General","Health",
                                              "RichardSprague_glucose.csv"),
                               user_id = 1234) {


  firstline <- readLines(con = file, 1) %>%
    str_split(pattern = ",", simplify = TRUE)

  skip_lines <- if_else(firstline[1] == "Glucose Data", 1, 2)

  glucose_raw <-
    readr::read_csv(file, skip = skip_lines, col_types = "cccdddddcddddcddddd") %>%
    transmute(
      timestamp = lubridate::mdy_hm(`Device Timestamp`, tz = Sys.timezone()),
      record_type = `Record Type`,
      glucose_historic = `Historic Glucose mg/dL`,
      glucose_scan = `Scan Glucose mg/dL`,
      strip_glucose = `Strip Glucose mg/dL`,
      notes = if_else(!is.na(Notes), paste0("Notes=",Notes),
                      Notes)
    )

  glucose_df <- glucose_raw  %>%
    #dplyr::filter(record_type != 6) %>% # Record type 6 does nothing
    transmute(time = `timestamp`,
              scan = glucose_scan,
              hist = glucose_historic,
              strip = strip_glucose,
              value = dplyr::if_else(is.na(scan),hist,scan),
              food = notes) # dplyr::if_else(is.na(notes),notes, paste0("Notes=",notes))) #dplyr::if_else(is.na(notes),"no", "yes"))#paste0("Notes=",notes)))


  glucose_df %>% add_column(user_id = user_id)

}

#' @title Notes dataframe from a CSV
#' @description Return a canonical notes dataframe from a properly-constructed Notes CSV file.
#' @param file path to a valid notes CSV file
#' @param user_id user ID to associate with this dataframe
#' @return dataframe for a valid notes CSV file
#' @export
notes_df_from_csv <- function(file = file.path("inst/extdata/FirstName1Lastname1_notes.csv"),
                              user_id = 1235) {

  notes <- read_csv(file,
                    col_types = cols(Start = col_datetime(format = "%m/%d/%y %H:%M"),
                                     End = col_datetime(format = "%m/%d/%y %H:%M"),
                                     Activity = col_factor(levels = NOTES_COLUMNS)))

  notes$Start <- lubridate::force_tz(notes$Start, tzone=Sys.timezone())
  notes$End <- lubridate::force_tz(notes$End, tzone=Sys.timezone())
  return(bind_cols(notes,user_id = user_id))
}

#' @title Return all `glucose_records` that have something in the notes field
#' @param conn_args valid database connection with a `glucose_records` table
#' @param user_id User ID
#' @return dataframe of
#' @export
#'
notes_df_from_glucose_table <- function(conn_args = config::get("dataconnection"),
                             user_id = 1234) {
  con <- DBI::dbConnect(
    drv = conn_args$driver,
    user = conn_args$user,
    host = conn_args$host,
    port = conn_args$port,
    dbname = conn_args$dbname,
    password = conn_args$password
  )

  ID = user_id

  food_records <- tbl(con, conn_args$glucose_table) %>%
    filter(user_id == ID) %>%
    filter(!is.na(food)) %>% collect() %>%
    transmute(Start = time,
              End = lubridate::as_datetime(NA),
              Activity = factor("Food", levels = NOTES_COLUMNS),
              Comment = as.character(stringr::str_replace(food,"Notes=","")),
              Z = as.numeric(NA),
              user_id = user_id)


  DBI::dbDisconnect(con)
  return(food_records)

}


# Read DB ----

#' @title Load all rows from a database table and return as a dataframe
#' @description Connects to the default database and looks up a table.
#' Slightly more convenient than setting up the database connection first.
#' @param conn_args valid database connection
#' @param table_name character string
#' @return dataframe representation of the table
#' @export
table_df_from_db <- function(conn_args = config::get("dataconnection"),
                             table_name = "glucose_records") {
  con <- DBI::dbConnect(
    drv = conn_args$driver,
    user = conn_args$user,
    host = conn_args$host,
    port = conn_args$port,
    dbname = conn_args$dbname,
    password = conn_args$password
  )

  df <- tbl(con, table_name) %>% collect()

  DBI::dbDisconnect(con)
  return(df)

}


#' @title Read from database a dataframe of glucose values for user_id ID
#' @param from_date a string representing the date from which you want to read the glucose values
#' @param user_id ID for a specific user in the database.
#' @param db_filter A function for filtering the database. Use instead of `from_date` or `user_id`
#' @return a dataframe (tibble) with the full Libreview results since fromDate for user_id
#' @description Reads from the current default database the glucose values for user_id ID.
#' @export
glucose_df_from_db <- function(conn_args=config::get("dataconnection"),
                         user_id = 1234,
                         from_date= as_datetime("2000-01-01",
                                                tz = Sys.timezone()),
                         db_filter = NULL){

  con <- DBI::dbConnect(drv = conn_args$driver,
                        user = conn_args$user,
                        host = conn_args$host,
                        port = conn_args$port,
                        dbname = conn_args$dbname,
                        password = conn_args$password)


  ID <- user_id # needed for SQL conversion.

  ## TODO this section can be optimized with a direct SQL call instead of
  ## dealing with dataframes.

  if(!is.null(db_filter)){
    glucose_df <- tbl(con, conn_args$glucose_table)  %>%
      db_filter() %>% collect()
  } else {
    glucose_df <-tbl(con, conn_args$glucose_table) %>%
    dplyr::filter(user_id %in% ID & time >= from_date) %>% collect() # & top_n(record_date,2))# %>%
  }

  glucose_raw <- glucose_df %>% transmute(time = force_tz(as_datetime(time), Sys.timezone()),
                                          scan = value, hist = value, strip = NA, value = value,
                                          food = food,
                                          user_id = user_id)

  DBI::dbDisconnect(con)
  return(glucose_raw)
}

#' @title Glucose values for ID after startDate
#' @description
#' For example `read_glucose_for_user_at_time(ID=22,startTime = as_datetime("2020-02-16 00:50:00", tz=Sys.timezone()))`
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


#' @title Read notes dataframe from database
#' @description If notes exist for ID, return all notes in a dataframe
#' @param user_id user id
#' @param db_filter A function for filtering the database. Use instead of `from_date` or `user_id`
#' @param fromDate (optional) earliest date from which to return notes
#' @return dataframe representation of all notes for that user
#' @export
notes_df_from_notes_table <- function(conn_args=config::get("dataconnection"),
                    user_id=1235,
                    fromDate="2019-11-01",
                    db_filter = NULL){

  ID = user_id

  con <- DBI::dbConnect(drv = conn_args$driver,
                        user = conn_args$user,
                        host = conn_args$host,
                        port = conn_args$port,
                        dbname = conn_args$dbname,
                        password = conn_args$password)

  if(!is.null(db_filter)){
    notes_df <- tbl(con, "notes_records")  %>%
      db_filter() %>% collect()
  } else {
  notes_df <- tbl(con, "notes_records") %>%   filter(user_id %in% ID ) %>%
    collect()
  }

  DBI::dbDisconnect(con)
  return(notes_df)


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

  nf <- notes_df_from_notes_table(conn_args, user_id = ID, db_filter = function(x) {x}) %>%
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
food_times_df <- function(user_id = 1235, timeLength=120, foodname="watermelon"){


  f <- glucose_for_food_df(user_id = user_id, foodname=foodname)


 # original_levels <- factor(f$user_id) # to prevent a conversion of id_user to char later

  ID = user_id

  df <- NULL
  for(user in ID){
    g <- f %>% filter(user_id==user)
    for(t in g$Start){
      new_segment_df <- glucose_df_for_users_at_time(user_id =user, startTime = lubridate::as_datetime(t,tz=Sys.timezone())) %>%
        mutate(meal=paste0(user,"-",month(as_datetime(t)),"/",day(as_datetime(t))),
               user_id = factor(user_id)) #user_id=factor(user_id, levels = original_levels))

      df <- bind_rows(df,make_zero_time_df(new_segment_df))
    }
  }
  return(df)
}


# DB queries ----

#' @description
#' Search the default database for the most recent (aka latest) timestamp
#' Note: doesn't currently work for tables other than `glucose_records`
#' @title Most recent date in the database for a given user
#' @param user_id user ID
#' @param table_name the table in which to find the latest record (currently fixed at `glucose-records`)
#' @return a date object representing the most recent record in the database for this user. NA if there are no records.
#' @import DBI
#' @export
max_date_for_user <-
  function(conn_args = config::get("dataconnection"),
           user_id = 1234,
           fromDate = "2019-11-01",
           table_name = conn_args$glucose_table) {
    con <- DBI::dbConnect(
      drv = conn_args$driver,
      user = conn_args$user,
      host = conn_args$host,
      port = conn_args$port,
      dbname = conn_args$dbname,
      password = conn_args$password
    )

    ID = user_id

    # maxDate <-
    #   DBI::dbGetQuery(con, "select max(\"time\") from glucose_records;")$max

    maxDate <-
      tbl(con, table_name) %>%
      filter(user_id == ID) %>%
      filter(time == max(time, na.rm = TRUE)) %>%
      pull(time)


    DBI::dbDisconnect(con)

    return(if (length(maxDate > 0))
      maxDate
      else
        NA)


  }

