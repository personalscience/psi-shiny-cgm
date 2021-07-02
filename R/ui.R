#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

Sys.setenv(R_CONFIG_ACTIVE = "local")


library(shiny)

#' Define UI for application that reads a CSV file
#' @import shiny
#' @import magrittr dplyr
ui <- fluidPage(


    # Application title
    titlePanel("Personal Science Experiments", windowTitle = "Personal Science, Inc."),
    tags$a(href="https://personalscience.com", "More details"),

    # Application title
    titlePanel("Your CGM Data"),

    # Sidebar with file picker
    sidebarLayout(
        sidebarPanel(
            csvFileUI("datafile", "Libreview CSV file"),
            textInput("type_filename",
                        "Librelink CSV file:",
                      DEFAULT_LIBRELINK_FILE_PATH,
                      placeholder = "Enter a valid Libreview CSV file"
                      ),
            textOutput("show_file"),

            dateRangeInput("daterange1", "Date range:",
                           start = "2021-05-30",
                           end   = "2021-06-25"),
        ),

        # Show a plot of the glucose levels
        mainPanel(
            plotOutput("glucoseChart"),
            dataTableOutput("glucoseTable")
        )
    )
)

