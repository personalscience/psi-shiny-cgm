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



#' Define server logic required to display CGM information
#' @import shiny
#' @import magrittr dplyr
server <- function(input, output) {
    message("Server is running...")

    datafilepath <- psiCGM:::csvFilePathServer("datafile")

    output$show_file <- renderText(datafilepath()$name)

    glucose <- reactive(glucose_df_from_libreview_csv(datafilepath()$datapath))
    #glucose <- reactive(glucose_df_from_db())
    glucose_current <- reactive(glucose() %>% filter(time>input$daterange1[1] & time < input$daterange1[2] ))


    output$glucoseTable <- renderDataTable({
        glucose_current()
    })

    output$glucoseChart <- renderPlot(psiCGM:::plot_glucose(glucose_current(),
                                                   datafilepath()$name))

    psiCGM:::mod_cgm_plot_server("modChart", glucose_current(), datafilepath()$name)
}






