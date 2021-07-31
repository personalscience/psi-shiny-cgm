#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#




library(shiny)
library(tidyverse)
library(lubridate)

Sys.setenv(R_CONFIG_ACTIVE = "local")


#' Define server logic required to display CGM information
#' @import shiny
#' @import magrittr dplyr
server <- function(input, output) {

    datafilepath <- psiCGM:::csvFilePathServer("datafile")

    output$show_file <- renderText(datafilepath()$name)

    active_glucose_record <- mod_filterServer("psi_filter_plot")

    g <- mod_cgm_plot_server("modChart", active_glucose_record, title = "inside server")

}






