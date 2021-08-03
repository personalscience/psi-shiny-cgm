# Shiny Module for filtering the Libreview glucose dataframes

#' @title Shiny module (UI) to filter CGM result based on user input
#' @param id input id for server
#' @description
#' Standalone UI renders HTML for a main panel
#' @export
mod_filterUI <- function(id) {

  ns <- NS(id)

    tagList(
      numericInput(ns("user_id"), label = "User ID", value = 1235),
      dateInput(ns("start_date"), label = "Start Date", value = as_datetime("2021-06-17", tz = Sys.timezone() )),
      sliderInput(ns("start_hour"), label = "Start Time (Hour)", value = 12, min = 0, max = 23),
      sliderInput(ns("time_length"), label = "Time length (Min)", value = 120, min = 10, max = 480, step = 30),
      checkboxInput(ns("zoom_to_date"), label = "Zoom Day", value = FALSE),
      # textInput(ns("zoom_to_food"), label = "Food", value = "blueberries"),
      # actionButton(ns("submit_food"), label = "Submit Food"),


    checkboxInput(ns("chk_sleep"), label = "Sleep", value = FALSE),
    textOutput(ns("show_food"))
    )
}

#' @title Shiny module (server) to filter a CGM result based on user input
#' @param id server input id
#' @return valid libreview-based dataframe encapsulated as a reactive
#' @export
mod_filterServer <- function(id){

  moduleServer(id, function(input, output, session) {
    ID<- reactive(input$user_id)
    start_date <- reactive(force_tz(input$start_date,
                                    tzone=Sys.timezone()) +
                             lubridate::hours(input$start_hour))
    # go_date <- reactive(if(input$submit_food) psiCGM:::food_times_df()
    #                     else (input$start_date + lubridate::hours(input$start_time))
    # )


    glucose_df <- reactive({

      # if(input$submit_food){ output$show_food <- renderText(paste("You made it!", input$zoom_to_food))
      # }

      if(input$zoom_to_date) {

        glucose_df_from_db(user_id = ID()) %>%
          filter(time >= start_date()) %>%
          filter(time <= start_date() + lubridate::minutes(input$time_length))
      } else  glucose_df_from_db(user_id = ID()) %>% filter(time >= start_date())
    })
    return(glucose_df)
  })

}

#' @title demo a shiny UI/server combination
#' @description useful for debugging
demo_filter <- function(){


  ui <- fluidPage(
    mod_filterUI("x"),
    dataTableOutput("table")
  )

  server <- function(input, output, session) {
    gdf <- mod_filterServer("x")
    output$table <- renderDataTable(gdf())
  }

  shinyApp(ui, server)
}


