# module to display plots of glucose values



libreviewUI <- function(id) {
  ns <- NS(id)

  sidebarLayout(sidebarPanel(h3("AUC is here"),
                             textOutput(ns("auc_value"))),
                mainPanel(plotOutput(ns("libreview"))))

}

mod_cgm_plot_server <- function(id,  glucose_df, title="Name") {

  moduleServer(id, function(input, output, session) {
    current_glucose <- reactive(glucose_df)
    #g <- reactive(psiCGM:::plot_glucose(current_glucose(), title))
    output$auc_value <- renderText(paste0("AUC=",psiCGM::auc_calc(current_glucose())))
    output$libreview <- renderPlot(psiCGM:::plot_glucose(current_glucose(), title))
    return(current_glucose)

  })

}


cgm_demo <- function() {


  glucose_df <- psiCGM::sample_libreview_df
  ui <- fluidPage(libreviewUI("x"))
  server <- function(input, output, session) {
    mod_cgm_plot_server("x", glucose_df)
  }
  shinyApp(ui, server)

}


