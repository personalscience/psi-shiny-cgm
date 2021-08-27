# Shiny Module and UI to compare foods for a single user

#' @title UI for food-related plots
#' @description
#' Plot a food object
#' @param id Shiny id
#' @export
mod_food2UI <- function(id) {
  ns <- NS(id)

  sidebarLayout(
    sidebarPanel(
      selectInput(
        ns("user_id"),
        label = "User Name",
        choices = with(user_df_from_libreview, paste(first_name, last_name)),
        selected = "Ayumi Blystone"
      ),
      textInput(ns("food_name1"), label = "Food 1", value = "Real Food Bar"),
      textInput(ns("food_name2"), label = "Food 2", value = "Kind, nuts & Spices"),
      actionButton(ns("submit_foods"), label = "Submit Foods"),
      checkboxInput(ns("normalize"), label = "Normalize")
    ),
    mainPanel(plotOutput(ns("libreview")),
              tableOutput(ns("auc_table")))
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
mod_food2Server <- function(id,  glucose_df, title = "Name") {

  moduleServer(id, function(input, output, session) {

    ID<- reactive( {message(paste("Selected User", isolate(input$user_id)))
      lookup_id_from_name(input$user_id[1])}
    )

    output$libreview <- renderPlot({
      input$submit_food
      plot_food_compare(food_times = food_times_df(user_id = user_df_from_libreview$user_id,
                                                   foodname = isolate(input$food_name)),
                        foodname = isolate(input$food_name))
    })
    output$auc_table <- renderTable({
      input$submit_food
      food_times_df(user_id = user_df_from_libreview$user_id,
                    foodname = isolate(input$food_name)) %>% filter(!is.na(value)) %>% distinct() %>%  # %>%
        group_by(meal) %>%
        summarize(auc = DescTools::AUC(t,value-first(value)),
                  min = min(value),
                  max = max(value),
                  rise = last(value) - first(value)) %>%
        #summarize(auc = sum((lag(value)-value)*(t-lag(t)), na.rm = TRUE)) %>%
        arrange(auc)

    })
  })

}

demo_food2 <- function(){

  glucose_df <- glucose_df_from_db(user_id = 1235)
  ui <- fluidPage(mod_foodUI("x"))
  server <- function(input, output, session) {
    mod_foodServer("x", reactive(glucose_df), reactiveVal("Username"))
  }
  shinyApp(ui, server)

}
