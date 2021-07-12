# display plots


display_plotUI <- function(id) {

  ns <- NS(id)
  mainPanel(
    titlePanel("CGM Display"),
   # plotOutput(ns("display_plot")),
    dateInput(ns("date1"), "Start Date:",
                   value = "2021-06-01"),
  )
}

mod_display_plot_server <- function(id,  glucose_df, title="Name from Server") {

  moduleServer(id, function(input, output, session) {
  g <- renderPlot(psiCGM:::plot_glucose(glucose_df %>% filter(time > input$date1), title))
  return(g)


  })

}


display_demo <- function() {


  glucose_df <- sample_libreview_df
  ui <- fluidPage(display_plotUI("x"),
                  plotOutput("my_plot"))
  server <- function(input, output, session) {

    g <- mod_display_plot_server("x", glucose_df )
    output$my_plot <- g

  }
  shinyApp(ui, server)

}

display_demo()

