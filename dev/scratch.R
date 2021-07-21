# okay to delete anything here

#Sys.setenv(R_CONFIG_ACTIVE = "p4mi")

read_db <- function(conn_args=config::get("dataconnection"),
                     user_id = 1235,
                     from_date="2019-11-01"){

  con <- DBI::dbConnect(drv = conn_args$driver,
                        user = conn_args$user,
                        host = conn_args$host,
                        port = conn_args$port,
                        dbname = conn_args$dbname,
                        password = conn_args$password)


  ID <- user_id # needed for SQL conversion.

  tbl(con, conn_args$glucose_table)


}





glucose_for_food_df()
