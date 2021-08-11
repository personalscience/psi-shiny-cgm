
library(psiCGM)
library(tidyverse)
library(lubridate)

conn_args=config::get("dataconnection")
con <- DBI::dbConnect(drv = conn_args$driver,
                      user = conn_args$user,
                      host = conn_args$host,
                      port = conn_args$port,
                      dbname = conn_args$dbname,
                      password = conn_args$password)




rs_file <- file.path("/Users/sprague/OneDrive/Ensembio/Personal Science/Partners/Tastermonial/data/RichardSprague_glucose_8-10-2021.csv")


rs_g <- glucose_df_from_libreview_csv(rs_file)

pop_tart_start <- rs_g %>% filter(stringr::str_detect(food, "Pop-Tart")) %>% pull(time)

pt <- rs_g %>% filter(time >= pop_tart_start) %>%
  filter(time <= (pop_tart_start + minutes(160)))

auc_calc(pt)

pt1 <- pt %>% transmute(t = as.numeric(time - pop_tart_start)/60,
                        value = value,
                        meal="Pop-Tarts™",
                        user_id = factor(1235))
pt1
plot_food_compare(food_times = filter(pt1, !is.na(value)), foodname = "Pop-Tarts™") +
  labs(title = "Glucose Levels", subtitle = sprintf("AUC=%.2f",auc_calc(pt)))


glucose_df_from_db() %>%
  filter(!is.na(food)) %>%
  transmute(food = stringr::str_replace(food,"Notes=","")) %>%
  group_by(food) %>% add_count() %>%
  filter(n < 10 & n > 3)

plot_food_compare(food_times = food_times_df(user_id = 1234, foodname = "beer"), foodname = "beer")
