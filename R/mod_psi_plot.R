# PSI Plot:  shiny server module for plotting panes

#' @title Shiny module (UI) to plot a CGM result based on user input
#' @param id input id for server
#' @description
#' Standalone UI renders HTML for a main panel
#'
psi_plotUI <- function(id) {

  ns <- NS(id)
  mainPanel(
    numericInput(ns("user_id"), label = "User ID", value = 1235),

    flowLayout(
    dateInput(ns("start_date"), label = "Start Date", value = "2021-06-15" ),
    sliderInput(ns("start_time"), label = "Start Time (Hour)", value = 12, min = 0, max = 23),
    sliderInput(ns("time_length"), label = "Time length (Min)", value = 120, min = 10, max = 480, step = 30),
    checkboxInput(ns("zoom_to_date"), label = "Zoom Day", value = FALSE),
    textInput(ns("zoom_to_food"), label = "Food"),
    actionButton(ns("submit_food"), label = "Submit Food")
        ),

    checkboxInput(ns("chk_sleep"), label = "Sleep", value = FALSE),
    plotOutput(ns("psi_plot"))
  )

}

#' @title Shiny module (server) to plot a CGM result based on user input
#' @param id server input id
#' @return valid libreview-based dataframe encapsulated as a reactive
mod_psi_plot <- function(id){

  moduleServer(id, function(input, output, session) {
    ID<- reactive(input$user_id)
    start_date <- reactive(input$start_date + lubridate::hours(input$start_time))
    go_date <- reactive(if(input$submit_food) psiCGM:::food_times_df()
                        else (input$start_date + lubridate::hours(input$start_time))
    )


    glucose_df <- reactive(
      if(input$zoom_to_date) {
        glucose_df_from_db(user_id = ID(), from_date = start_date()) %>%
          filter(.data[["time"]] < (start_date() +
                           lubridate::hours(input$start_time) +
                           lubridate::minutes(input$time_length)))
      } else  glucose_df_from_db(user_id = ID(), from_date = start_date())
      )
    output$psi_plot <- renderPlot(psiCGM:::plot_glucose(glucose_df(),
                                                        title = paste0("User =", username_for_id(ID()))))
    return(glucose_df)
  })

}


#' @title demo a shiny UI/server combination
#' @description useful for debugging
demo_psi_plot <- function(){


  ui <- fluidPage(
    psi_plotUI("x")
  )

  server <- function(input, output, session) {
    mod_psi_plot("x")
  }

  shinyApp(ui, server)
}

#demo_psi_plot()
