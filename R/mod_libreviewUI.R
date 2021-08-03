# module to display plots of glucose values



#' @title UI for Libreview plots
#' @description
#' Plot a Libreview object along with its AUC value
#' @param id Shiny id
#' @export
mod_libreviewUI <- function(id) {
  ns <- NS(id)

  fluidRow(
          plotOutput(ns("libreview")),
          h3("AUC"),
          textOutput(ns("auc_value")))

}

#' @title Make a glucose chart
#' @description
#' Given a (reactive) libreview dataframe, this Shiny module will
#' generate a valid ggplot object and display it in an accompanying UI
#' @param id shiny module id
#' @param glucose_df reactive for a valid glucose dataframe
#' @param title a title for the plot
#' @return ggplot object representing a glucose chart
#' @export
mod_libreview_plotServer <- function(id,  glucose_df, title="Name") {

  moduleServer(id, function(input, output, session) {
    # observe({
    #   cat(file=stderr(),
    #       sprintf("found your dataframe with %d rows\n",nrow(glucose_df())))
    # })

    output$auc_value <- renderText(sprintf("%.2f",psiCGM::auc_calc(glucose_df())))

    observeEvent(glucose_df(),
                 {     cat(file=stderr(),
                           sprintf("User %s dataframe still has %d rows\n",title(), nrow(glucose_df())))
                 output$libreview <- renderPlot(psiCGM:::plot_glucose(glucose_df(), title()))
                 }
    )

    current_glucose <- reactive({message("inside reactive")
                                         glucose_df()})


    #message(current_glucose())
    g <- reactive(psiCGM:::plot_glucose(current_glucose(), title))
    return(g)

  })

}


#' @title Demo the libreviewUI
cgm_demo <- function() {


  glucose_df <- psiCGM::sample_libreview_df
  ui <- fluidPage(mod_libreviewUI("x"))
  server <- function(input, output, session) {
    mod_libreview_plotServer("x", reactive(glucose_df), reactiveVal("Username"))
  }
  shinyApp(ui, server)

}


