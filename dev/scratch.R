
library(psiCGM)
library(tidyverse)
library(lubridate)


#Sys.setenv(R_CONFIG_ACTIVE = "tastercloud")
#Sys.setenv(R_CONFIG_ACTIVE = "localtest")
#Sys.setenv(R_CONFIG_ACTIVE = "local")
conn_args=config::get("dataconnection")
con <- DBI::dbConnect(drv = conn_args$driver,
                      user = conn_args$user,
                      host = conn_args$host,
                      port = conn_args$port,
                      dbname = conn_args$dbname,
                      password = conn_args$password)


G <- auc_example["value"] %>% as_vector()
t <- auc_example["time"] %>% as_vector()
A <- rep(0,length(t)-1)
A
t

G_ <- function(x) {
  return(G[x+1])
}
t_ <- function(x) {
  return(t[x+1])
}

G_(0)
t_(0)
t_(5)


A[1] <-  ifelse(G_(1) >G_(0),
                (G_(1) - G_(0)) * (t_(1) - t(0)) /2,
                0)
A

x = 2

A[x] <- if(G_(x) >= G_(0) & G_(x-1) >= G_(0)) {
  ((G_(x) - G_(0)) / 2 + (G_(x-1) - G_(0))/2 )  * (t_(x) - t_(x-1))
}
A

x=6
ifelse(G_(x) >= G_(0) & G_(x-1) >= G_(0),
  ((G_(x) - G_(0)) / 2 + (G_(x-1) - G_(0))/2 )  * (t_(x) - t_(x-1)),
  ifelse((G_(x) >= G_(0)) & G_(x-1) < G_(0),
    ((G_(x) - G_(0))^2)/(G_(x) - G_(x-1)) * (t_(x) - t_(x-1))/2,
    ifelse((G_(x) < G_(0)) & G_(x-1) >= G_(0),
           ((G_(x-1) - G_(0))^2) / (G_(x-1) - G_(x))*(t_(x) - t_(x-1))/2,
           ifelse((G_(x) < G_(0)) & (G_(x-1) < G_(0)),
                  0,
                  NULL))))



x = 4
G_(x) < G_(0) & G_(x-1) >= G_(0)

((G_(x-1) - G_(0))^2) / (G_(x-1) - G_(x))*(t_(x) - t_(x-1))/2
x = 6

((G_(x-1) - G_(0))^2) / (G_(x-1) - G_(x))*(t_(x) - t_(x-1))/2

x=7
(t_(x) ) #- t_(x-1))

t
A
G[i]>=G[1]
