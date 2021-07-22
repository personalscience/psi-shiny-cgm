# okay to delete anything here

#Sys.setenv(R_CONFIG_ACTIVE = "p4mi")

# find the name of user_id

user_df_from_libreview %>% filter(user_id == 1236)  %>%
  select(first_name,last_name) %>%
  as.character() %>%
  paste() %>%
  str()


extra_user_df <- read_csv(file = system.file("extdata",
                            package = "psiCGM",
                            "Tastermonial_Extra_Users.csv"),
         col_types = "cccccd") %>% mutate(birthdate = lubridate::mdy(birthdate))


user_df_from_libreview %>%
  dplyr::anti_join(extra_user_df,
                   by = c("first_name","last_name")) %>% bind_rows(extra_user_df)

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
