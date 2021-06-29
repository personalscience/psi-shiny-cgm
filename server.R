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



# Define server logic required to display CGM information
shinyServer(function(input, output) {
    message("back to the server")


    output$csv_file_path <- renderTable(input$ask_filename)


    #glucose <- reactive(read_libreview_csv(input$type_filename))
    glucose <- reactive(read_glucose_db())
    glucose_current <- reactive(glucose() %>% filter(time>input$daterange1[1] & time < input$daterange1[2] ))

    output$glucoseTable <- renderDataTable(
         glucose_current(),
         options = list(pageLength = 5))

    #output$glucoseChart <- renderPlot(plot_glucose(glucose_current(), title = input$ask_filename))
    mod_cgm_plot_server("modChart", glucose_current())


})






