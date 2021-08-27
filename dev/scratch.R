
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



bind_rows(
  food_times_df(lookup_id_from_name("Richard"),foodname = "Pop-Tart"),
  food_times_df(lookup_id_from_name("Richard"),foodname = "Real food")
) %>% filter(!is.na(value)) %>% group_by(meal) %>% arrange(t) %>% mutate(value = value-first(value)) %>%
  ungroup() %>%  arrange(meal, t) %>% View()#%>% ggplot(aes(t,value, color = foodname)) + geom_line(size = 2)



