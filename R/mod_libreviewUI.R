# module to display plots of glucose values



libreviewUI <- function(id) {
  ns <- NS(id)

  sidebarLayout(sidebarPanel(h3("AUC"),
                             textOutput(ns("auc_value"))),
                mainPanel(plotOutput(ns("libreview"))))

}

mod_cgm_plot_server <- function(id,  glucose_df, title="Name") {

  moduleServer(id, function(input, output, session) {

    g <- reactive(psiCGM:::plot_glucose(glucose_df, title))
    output$auc_value <- renderText(paste0("AUC=",psiCGM::auc_calc(glucose_df)))
    output$libreview <- renderPlot(g())
    return(g)

  })

}


cgm_demo <- function() {


  glucose_df <- sample_libreview_df
  ui <- fluidPage(libreviewUI("x"))
  server <- function(input, output, session) {
    mod_cgm_plot_server("x", glucose_df)
  }
  shinyApp(ui, server)

}


