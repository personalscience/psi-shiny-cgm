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

library(ggthemes)
library(showtext)
font_add_google("Montserrat")
showtext_auto()


sprague_theme <-   theme(text = element_text(family = "Montserrat", face = "bold", size = 15),
                         axis.text.x = element_text(size = 15, angle = 90, hjust = 1),
                         legend.title = element_blank())

plot_glucose <- function(glucose_raw, title = "Martha") {
    g = ggplot(data = glucose_raw, aes(x=time, y = value) )
    g + sprague_theme + geom_line(color = "red")  +
        labs(title = title, x = "", y = "mg/mL", subtitle = "Continuous glucose monitoring") +
        scale_x_datetime(date_breaks = "1 day", date_labels = "%a %b-%d") +
        coord_cartesian(xlim = c(now() - days(7), now()),
                        ylim = c(40, 130),
        )
}


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

    glucose <- reactive(glucose_from_csv(input$ask_filename))

    output$glucoseTable <- renderDataTable(
         glucose() %>% filter(time>input$daterange1[1] & time < input$daterange1[2] ),
         options = list(pageLength = 5))

    output$glucoseChart <- renderPlot(plot_glucose(glucose(), title = input$ask_filename))


})






