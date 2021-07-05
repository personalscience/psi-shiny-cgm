# module to choose and perform actions on a specific user



userSelectionUI <- function(id) {

  fluidPage(
    tagList(
      textOutput(NS(id, "user"))
    )
    # ,
    #
    # textInput(NS(id,"enter_name"))
  )

  # tagList(
  #   textInput(NS(id, "enter_name"))
  # )

}

mod_user_selection_server <- function(id, username="Name") {

  moduleServer(id, function(input, output, session) {


    output$user <- renderText(username)

  })

}


user_selection_demo <- function() {



  ui <- userSelectionUI("x")
  server <- function(input, output, session) {
    mod_user_selection_server("x", username = "My name")
  }
  shinyApp(ui, server)

}

user_selection_demo()
