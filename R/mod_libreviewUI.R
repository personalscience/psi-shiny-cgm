# module to display plots of glucose values



libreviewUI <- function(id) {
  ns <- NS(id)

  sidebarLayout(sidebarPanel(h3("AUC"),
                             textOutput(ns("auc_value"))),
                mainPanel(plotOutput(ns("libreview"))))

}

mod_cgm_plot_server <- function(id,  glucose_df, title="Name") {

  moduleServer(id, function(input, output, session) {
    # observe({
    #   cat(file=stderr(),
    #       sprintf("found your dataframe with %d rows\n",nrow(glucose_df())))
    # })

    output$auc_value <- renderText(sprintf("%.2f",psiCGM::auc_calc(glucose_df())))

    observeEvent(glucose_df(),
                 {     cat(file=stderr(),
                           sprintf("Your dataframe still has %d rows\n",nrow(glucose_df())))
                 #  output$auc_value <- renderText(paste0("AUC=",psiCGM::auc_calc(glucose_df())))
                 output$libreview <- renderPlot(psiCGM:::plot_glucose(glucose_df(), title))
                 }
    )

    current_glucose <- reactive({message("inside reactive")
                                         glucose_df()})


    #message(current_glucose())
    g <- reactive(psiCGM:::plot_glucose(current_glucose(), title))
    return(g)

  })

}


cgm_demo <- function() {


  glucose_df <- psiCGM::sample_libreview_df
  ui <- fluidPage(libreviewUI("x"))
  server <- function(input, output, session) {
    mod_cgm_plot_server("x", reactive(glucose_df))
  }
  shinyApp(ui, server)

}


