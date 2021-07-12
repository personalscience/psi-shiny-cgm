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

mod_choose_userUI <- function(id) {
  ns <- NS(id)
  sidebarPanel(
    h3("Choose user"),
    numericInput(ns("enter_user"),label = "User", value = 1234),
    textOutput(ns("current_user")),
    plotOutput(ns("updated_plot"))
  )
}

#' Shiny server to return a valid glucose dataframe
#' @returns dataframe
mod_filter_glucose_server <- function(id, user_id = 1234){

  moduleServer(id, function(input, output, session) {
    #mod_choose_userUI()

    #ID <- input$enter_user
    output$current_user <- renderText(paste0("Current User = ",input$enter_user))

    df <- reactive(psiCGM:::glucose_df_from_db(user_id = input$enter_user))
    output$updated_plot <- renderPlot(psiCGM:::plot_glucose(df()))
    return(sample_libreview_df)
  })

}

display_demo <- function() {
  glucose_df <- sample_libreview_df
  ui <- fluidPage(
    includeCSS("R/www/psi_shiny.css"),
    titlePanel("Overall Title"),
    display_plotUI("x"),
    mod_choose_userUI("filter_ux"),
    plotOutput("my_plot")
  )
  server <- function(input, output, session) {

    current_glucose <- mod_filter_glucose_server("filter_ux", user_id = 1234)
    g <- mod_display_plot_server("x", current_glucose)
    output$my_plot <- g

  }
  shinyApp(ui, server)

}

display_demo()

