library(testthat)
library(psiCGM)

message("Running tests...")
active_env <- Sys.getenv("R_CONFIG_ACTIVE")
Sys.setenv(R_CONFIG_ACTIVE = "localtest")


test_check("psiCGM")

Sys.setenv(R_CONFIG_ACTIVE = active_env )
