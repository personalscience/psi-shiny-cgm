# module to choose and perform actions on a specific user



userSelectionUI <- function(id) {


  wellPanel(
    h2("List of Users"),
      textOutput(NS(id, "user")),
     textInput(NS(id,"enter_text"),"Enter User Number", "0000"),
      actionButton(NS(id,"press_button"),"Add user"),




  )

}

mod_user_selection_server <- function(id, username="Name") {

  moduleServer(id,
               function(input, output, session) {
                 userlist <- username

                 observeEvent(input$press_button, {
                   userlist <- append(userlist,input$enter_text)
                   message(paste("button pressed:", paste(userlist, collapse = ",")))
                 })

                # add_user_button<- reactive(input$press_button)

                 output$user <- renderText(paste(input$enter_text,"is", paste(userlist, collapse = ", ")))
                 }
  )

}




user_selection_demo <- function() {

 userlist <- c("1234","789")

  ui <- userSelectionUI("x")
  server <- function(input, output, session) {
    mod_user_selection_server("x", username = userlist)
  }
  shinyApp(ui, server)

}

user_selection_demo()
