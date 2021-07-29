# PSI Plot:  shiny server module for plotting panes

#' @title Shiny module (UI) to plot a CGM result based on user input
#' @param id input id for server
#' @description
#' Standalone UI renders HTML for a main panel
#'
psi_plotUI <- function(id) {

  ns <- NS(id)
  sidebarLayout(


    sidebarPanel(   fluidRow(
      numericInput(ns("user_id"), label = "User ID", value = 1235),
    dateInput(ns("start_date"), label = "Start Date", value = as_datetime("2021-06-15", tz = Sys.timezone() )),
    sliderInput(ns("start_time"), label = "Start Time (Hour)", value = 12, min = 0, max = 23),
    sliderInput(ns("time_length"), label = "Time length (Min)", value = 120, min = 10, max = 480, step = 30),
    checkboxInput(ns("zoom_to_date"), label = "Zoom Day", value = FALSE),
    textInput(ns("zoom_to_food"), label = "Food"),
    actionButton(ns("submit_food"), label = "Submit Food")
        ),

    checkboxInput(ns("chk_sleep"), label = "Sleep", value = FALSE)
    ),

    mainPanel(plotOutput(ns("psi_plot")))

  )

}

#' @title Shiny module (server) to plot a CGM result based on user input
#' @param id server input id
#' @return valid libreview-based dataframe encapsulated as a reactive
mod_psi_plot <- function(id){

  moduleServer(id, function(input, output, session) {
    ID<- reactive(input$user_id)
    start_date <- reactive(as_datetime(input$start_date,
                                       tz=Sys.timezone()) +
                             lubridate::hours(input$start_time))
    go_date <- reactive(if(input$submit_food) psiCGM:::food_times_df()
                        else (input$start_date + lubridate::hours(input$start_time))
    )


    glucose_df <- reactive(
      if(input$zoom_to_date) {
        mins <- start_date() + lubridate::minutes(input$time_length)
        glucose_df_from_db(user_id = ID(), from_date = start_date()) %>%
          filter(.data[["time"]] <= mins )
      } else  glucose_df_from_db(user_id = ID(), from_date = start_date())
      )
    output$psi_plot <- renderPlot(psiCGM:::plot_glucose(glucose_df(),
                                                        title = paste0("User =", psiCGM:::username_for_id(ID()))))
    return(glucose_df)
  })

}


#' @title demo a shiny UI/server combination
#' @description useful for debugging
demo_psi_plot <- function(){


  ui <- fluidPage(
    psi_plotUI("x"),
    dataTableOutput("table")
  )

  server <- function(input, output, session) {
    gdf <- mod_psi_plot("x")
    output$table <- renderDataTable(gdf())
  }

  shinyApp(ui, server)
}


demo_psi_plot()
