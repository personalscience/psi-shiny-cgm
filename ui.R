#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

DEFAULT_LIBRELINK_FILE_PATH <- file.path(Sys.getenv("ONEDRIVE"),"General", "Health",
                                         "RichardSprague_glucose.csv")
library(shiny)

# Define UI for application that reads a CSV file
shinyUI(fluidPage(

    # Application title
    titlePanel("Your CGM Data"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            fileInput("ask_filename", "Choose CSV File", accept = ".csv"),
            checkboxInput("header", "Header", TRUE),
            textInput("type_filename",
                        "Librelink CSV file:",
                      DEFAULT_LIBRELINK_FILE_PATH,
                      placeholder = "Enter a valid Libreview CSV file"
                      ),

            dateRangeInput("daterange1", "Date range:",
                           start = "2021-05-30",
                           end   = "2021-06-25"),
        ),

        # Show a plot of the glucose levels
        mainPanel(
            # plotOutput("glucoseChart"),
            libreviewUI("modChart"),
            dataTableOutput("glucoseTable")
        )
    )
))
