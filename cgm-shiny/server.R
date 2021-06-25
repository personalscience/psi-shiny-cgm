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

glucose_from_csv <- function(csv_filepath){
    libre_raw <- readr::read_csv(csv_filepath, col_types = "cccdddddcddddcddddd",
                                 skip = 1)
    libre_raw$`Device Timestamp` <- lubridate::force_tz(lubridate::mdy_hm(libre_raw$`Device Timestamp`), Sys.timezone())

    glucose <- libre_raw %>% transmute(time = `Device Timestamp`,
                                       scan = as.numeric(`Scan Glucose mg/dL`) ,
                                       hist = `Historic Glucose mg/dL` ,
                                       strip = as.numeric(`Strip Glucose mg/dL`),
                                       food = "Notes")


    glucose$value <- dplyr::if_else(is.na(glucose$scan),glucose$hist,glucose$scan)

    return(glucose)


}

# Define server logic required to display CGM information
shinyServer(function(input, output) {
    message("back to the server")


    output$csv_file_path <- renderText(input$ask_filename)

    output$glucose <- reactive(glucose_from_csv(input$ask_filename))

    output$glucoseTable <- renderDataTable(
         head(glucose_from_csv(input$ask_filename)))
})






