# psi User Management Functions

#' @title All user records in the database
#' @param conn_args database connection
#' @return dataframe of all user records
user_df_from_db <- function(conn_args = config::get("dataconnection")){
  con <- DBI::dbConnect(
    drv = conn_args$driver,
    user = conn_args$user,
    host = conn_args$host,
    port = conn_args$port,
    dbname = conn_args$dbname,
    password = conn_args$password
  )

  users_df <- table_df_from_db(conn_args = conn_args,
                               table_name = "user_list" )

  DBI::dbDisconnect()
  return(users_df)

}

#'@title Find username associated with an ID
#'@param user_id user ID
#'@return character string of the username for that ID
username_for_id <- function(user_id) {
  ID = user_id
  user_df_from_libreview %>% filter(user_id == ID)  %>%
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
  return(name)
}

#' @title user_id of a valid name string
#' @description
#' Assuming the name string is already in the user database, returns the user_id
#' @return user_id user ID from `user_df_from_libreview`
#' @export
lookup_id_from_name <- function(name) {
  name_split <- str_split(name, pattern = " ", simplify = TRUE)
  first <- name_split[1]
  last <- name_split[2]
  ID <- user_df_from_libreview %>% filter(first_name == first & last_name == last) %>% pull(user_id)
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
#' @return dataframe including `user-id`
#' @export
load_libreview_csv_from_directory <- function(path = config::get("tastermonial")$datadir) {

  datafiles <- list.files(path)
  datafiles <- datafiles[datafiles %>% str_detect("glucose")]

  df <- NULL
  for (d in datafiles) {
    f <-  file.path(taster_data_path, d)
    ID <- lookup_id_from_name(name_from_libreview_file(f))
    message(sprintf("Reading ID = %s", ID))
    g_df <- glucose_df_from_libreview_csv(file = f,
                                          user_id = ID)
    df <- bind_rows(df, g_df)
  }
  return(df)
  # count the number of unique user_id like this:
  # df %>% group_by(user_id) %>% summarize(n())
}

