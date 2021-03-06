# psi User Management Functions

#' @title All user records in the database
#' @param conn_args database connection
#' @return dataframe of all user records
#' @export
user_df_from_db <- function(conn_args = config::get("dataconnection")){
  con <- DBI::dbConnect(
    drv = conn_args$driver,
    user = conn_args$user,
    host = conn_args$host,
    port = conn_args$port,
    dbname = conn_args$dbname,
    password = conn_args$password
  )

  users_df <- tbl(con, "user_list" ) %>% collect()

  DBI::dbDisconnect(con)
  return(users_df)

}

#'@title Find username associated with an ID
#'@param user_id user ID
#'@return character string of the username for that ID
#'@export
username_for_id <- function(user_id) {
  ID = user_id
  if (ID == 0) return("Unknown Name")
  else
  user_df_from_db() %>% filter(user_id == ID)  %>%
    select(first_name,last_name) %>%
    as.character() %>%
    stringr::str_flatten(collapse = " ")

}

#' @title name of the person associated with a Libreview glucose file.
#' @description
#' Given a valid Libreview file, return a string of the form first_name last_name
#' @param filepath path to the CSV file
#' @return a space-separated character string made of first_name last_name
#' @export
name_from_libreview_file <- function(filepath) {
  first2 <- readLines(con=filepath,2)
  if (first2[1] %>% str_detect("Patient"))
  {name <- str_split(first2[2],pattern=",")[[1]][1]}
  else name <- str_split(first2[1],pattern=",")[[1]][5]
  return(str_squish(name))
}

#' @title user_id of a valid name string
#' @description
#' Assuming the name string is already in the user database, returns the user_id
#' @param name a string representation of the name you want to look up
#' @return user_id user ID from `user_df_from_libreview`
#' @export
lookup_id_from_name <- function(name) {
  name_split <- str_split(name, pattern = " ", simplify = TRUE)
  first <- first(name_split)
  last <- paste(name_split[-1], collapse=" ")
  ID <- user_df_from_db() %>% filter(first_name == first &
                                            stringr::str_detect(last_name, last)) %>%
    pull(user_id)
  return(if(length(ID)>0) ID else NULL)
  # return(paste("your name",first_name,last_name))

}

#' @title Unified dataframe for all glucose CSV files in `path`
#' @description
#' Read glucose files in `path` and return one big dataframe with all glucose values.
#' As a neat trick, look up the `user_id` based on entries in `user_df_from_libreview` and
#' add that to the dataframe.
#' Assumes it's a valid file if it has the string "glucose" in its name.
#' @param path file path to a directory of libreview CSV files.
#' @return dataframe including `user_id` matching those for data in the notes_records
#' @export
load_libreview_csv_from_directory <- function(path = config::get("tastermonial")$datadir) {

  datafiles <- list.files(path)
  datafiles <- datafiles[datafiles %>% str_detect("glucose")]
  exceptions <- read_csv(file.path(path,"Tastermonial_Exceptions.csv")) %>% mutate(fullname=paste(first_name, last_name))

  df <- NULL
  for (d in datafiles) {
    f <-  file.path(path, d)
    libreview_name <- name_from_libreview_file(f)
    new_tz <-  if (libreview_name %in% exceptions$fullname) {
      new_tz <- filter(exceptions,fullname == libreview_name) %>% pull(timezone)
      if(!is.null(new_tz)) new_tz else Sys.timezone()
    } else Sys.timezone()
    ID <- lookup_id_from_name(libreview_name)
    message(sprintf("Reading ID = %s", ID))
    g_df <- glucose_df_from_libreview_csv(file = f,
                                          user_id = ID,
                                          new_tz)
    df <- bind_rows(df, g_df)
  }
  return(df)
  # count the number of unique user_id like this:
  # df %>% group_by(user_id) %>% summarize(n())
}

