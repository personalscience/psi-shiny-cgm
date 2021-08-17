# deploy to shinyapps.io


Sys.setenv(R_CONFIG_ACTIVE = "tastercloud")

rsconnect::setAccountInfo(name=config::get("shiny")$name,
                          token=config::get("shiny")$token,
                          secret=config::get("shiny")$secret)

# options(repos = c("https://cran.rstudio.com",
#                   devtools::install_github("personalscience/psi-shiny-cgm")))

devtools::install_github("personalscience/psi-shiny-cgm")


rsconnect::deployApp(appDir = file.path(getwd(),"R"),
                     appName = "Tastermonial",
                     appFiles = c("ui.R","server.R",
                                  "read_data_utils.R",
                                  "mod_filter.R",
                                  "mod_calc_util.R",
                                  "psi_user_management.R",
                                  "config.yml"),
                     forceUpdate = TRUE
                     )


