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
    message("Server is running...")


    datafilepath <- psiCGM:::csvFilePathServer("datafile")

    output$show_file <- renderText(datafilepath()$name)

    #glucose <- reactive(psiCGM:::glucose_df_from_libreview_csv(datafilepath()$datapath))
    #active_glucose_record <- psiCGM:::mod_db_selection_server("test1", username = "Server Name Here")

    active_glucose_record <- psiCGM:::mod_psi_plot("psi_filter_plot")
    message("new active glucose record")

    #glucose <- reactive(glucose_df_from_db())
    #glucose_current <- reactive(glucose() %>% filter(time>input$daterange1[1] & time < input$daterange1[2] ))

        glucose_current <-reactive(active_glucose_record() ) #%>% filter(time>input$daterange1[1] & time < input$daterange1[2] ))

    output$glucoseTable <- renderDataTable({
        glucose_current()
    })

    output$glucoseChart <- renderPlot(psiCGM:::plot_glucose(glucose_current(),
                                                            title = "User"
                                                            # datafilepath()$name),
    ) + annotate("text", x = glucose_current()$time[1] + lubridate::days(2),
                 y = 100,
                 label = paste("AUC=", auc_calc(glucose_current())
                 )
    ))

   # output$auc_value <- renderText(paste("AUC=", auc_calc(glucose_current())))

   # psiCGM:::mod_cgm_plot_server("modChart", reactive(glucose_current()), title = "inside SErver")

}






