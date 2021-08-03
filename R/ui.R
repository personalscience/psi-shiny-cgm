#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#



library(shiny)

#' Define UI for application that reads a CSV file
#' @import shiny
#' @import magrittr dplyr
ui <- fluidPage(


    #includeCSS(file.path("R","www","psi_shiny.css")),
    # Application title
    titlePanel("Personal Science Experiments", windowTitle = "Personal Science, Inc."),
    tags$a(href="https://personalscience.com", "More details"),

    # Application title
    h2("Your CGM Data"),

        # Show a plot of the glucose levels
        sidebarLayout(
          sidebarPanel(
              mod_filterUI("psi_filter_plot"),

            ),


        # textOutput("auc"),
           mainPanel(
             mod_libreviewUI("modChart"),
             mod_foodUI("food_compare_plot")
          # dataTableOutput("glucoseTable")
        ))

)

