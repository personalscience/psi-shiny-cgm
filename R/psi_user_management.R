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
