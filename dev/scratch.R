# okay to delete anything here

Sys.setenv(R_CONFIG_ACTIVE = "p4mi")

read_db <- function(conn_args=config::get("dataconnection"),
                     user_id = 1234,
                     fromDate="2019-11-01"){

  con <- DBI::dbConnect(drv = conn_args$driver,
                        user = conn_args$user,
                        host = conn_args$host,
                        port = conn_args$port,
                        dbname = conn_args$dbname,
                        password = conn_args$password)


  ID <- user_id # needed for SQL conversion.

  tbl(con, conn_args$glucose_table)


}

#' return rows where food matches food
#' eg. records_with_food(ID=8, foodname="apple")
#' @import DBI stringr
#' @return a valid glucose dataframe containing records matching `food`
glucose_for_food_df <- function(conn_args=config::get("dataconnection"),
                                ID=13,
                                foodname = "banana"){


  con <- DBI::dbConnect(drv = conn_args$driver,
                        user = conn_args$user,
                        host = conn_args$host,
                        port = conn_args$port,
                        dbname = conn_args$dbname,
                        password = conn_args$password)

  glucose_df <- tbl(con, conn_args$glucose_table) %>%
    dplyr::filter(user_id %in% ID ) #%>% collect()# & top_n(record_date,2))# %>%


  gf = glucose_df %>% mutate(food=stringr::str_to_lower(stringr::str_replace(food,"Notes=",""))) #, user_id=factor(user_id))

  return(slice(gf,stringr::str_which(gf$food,foodname)))

  # nf = read_notes(ID=ID)
  #
  # slice(gf,str_which(str_to_lower(nf$Comment),str_to_lower(foodname))) %>% pull(time)
}


read_db()
