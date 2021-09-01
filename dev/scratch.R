
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


#Sys.setenv(R_CONFIG_ACTIVE = "localtest")
#Sys.setenv(R_CONFIG_ACTIVE = "tastercloud")

NOTES_COLUMNS <- c("Sleep", "Event", "Food","Exercise")

notes<- read_csv(file=system.file("extdata", package="psiCGM", "FirstName1Lastname1_notes.csv")) %>%
  transmute(Start = mdy_hm(Start, tz = Sys.timezone()),
            End = mdy_hm(End, tz = Sys.timezone()),
            Activity = factor(Activity, levels = NOTES_COLUMNS),
            Comment = Comment,
            Z = Z    )

#
#                  col_types = cols(Start = col_datetime(),
#                                   End = col_datetime(),
#                                   Activity = col_factor(levels = NOTES_COLUMNS)))



notes %>% filter(is.na(Start))
bind_rows(notes_df_from_notes_table(),notes)
