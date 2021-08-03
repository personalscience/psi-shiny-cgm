# Shiny module to compare foods

#' @title UI for food-related plots
#' @description
#' Plot a food object
#' @param id Shiny id
#' @export
mod_foodUI <- function(id) {
  ns <- NS(id)

  fluidRow(
    plotOutput(ns("libreview")),
    textInput(ns("food_name"), label = "Food", value = "blueberries"),
    actionButton(ns("submit_food"), label = "Submit Food")
  )


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
mod_foodServer <- function(id,  glucose_df, title = "Name") {

  moduleServer(id, function(input, output, session) {

    #foodname <- input$food_name
    output$libreview <- renderPlot({
      input$submit_food
      plot_food_compare(food_times = food_times_df(foodname = isolate(input$food_name)),
                        foodname = isolate(input$food_name))
    })
    })

}

demo_food <- function(){

  glucose_df <- glucose_df_from_db(user_id = 1235)
  ui <- fluidPage(mod_foodUI("x"))
  server <- function(input, output, session) {
    mod_foodServer("x", reactive(glucose_df), reactiveVal("Username"))
  }
  shinyApp(ui, server)

}

demo_food()
