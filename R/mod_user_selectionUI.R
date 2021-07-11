# module to choose and perform actions on a specific user




#' Shiny module for user selection UI.
#' A panel of items to select a user ID and then display as a plot
userSelectionUI <- function(id) {
  ns <- NS(id)

  sidebarLayout(
  sidebarPanel(
    h3("Input values"),
    numericInput(ns("enter_main_user"), label = "User Number:", value = 1234),
    actionButton(ns("pull_db"), "Pull user from DB")
  ),
  mainPanel(
    h2("Glucose"),
   # textOutput(ns("user")),
    plotOutput(ns("db_plot"))
  ))
}

#' Shiny module server to show a Libreview plot from the database
mod_db_selection_server <- function(id, username="Default Name") {

  moduleServer(id,
               function(input, output, session) {
                 output$user <- reactive(input$enter_main_user) #renderText(paste(input$enter_text,"is", paste(userlist, collapse = ", ")))

                 output$db_plot <- renderPlot({
                   if (input$pull_db == 0) # if the pull_db button has never been pressed, grab the csv data
                   { message(paste("pulled from csv:", paste(input$enter_main_user)))
                     psiCGM:::plot_glucose(psiCGM::sample_libreview_df)
                   }
                   {
                     message(paste("pulled from db:", paste(input$enter_main_user)))
                     psiCGM:::plot_glucose(psiCGM:::glucose_df_from_db(user_id=input$enter_main_user,
                                                                     fromDate = "2021-06-01"),
                                           title = paste0("User: ",input$enter_main_user))
                   }
                 })


                 return(reactive(psiCGM:::glucose_df_from_db(user_id=input$enter_main_user)))
               }
  )


}

user_selection_demo <- function() {

  userlist <- c("1234","789") # placeholder: ultimately it should display all the users selected

  ui <- userSelectionUI("x")
  server <- function(input, output, session) {
    active_glucose_record <- mod_db_selection_server("x", username = userlist)
  }
  shinyApp(ui, server)

}

user_selection_demo()  # runs the final, official version of this module

## DEMO (old) ----

#' selectionUI for test purposes: trying to work out how to use various shiny objects
biguserSelectionUI <- function(id) {

  ns <- NS(id)

  wellPanel(
    h2("List of Users"),
    textOutput(ns("user")),
    textInput(ns("enter_text"),"Enter User Number", "0000"),
    actionButton(ns("press_button"),"Add user"),
    actionButton(ns("pull_db"),"Pull User From DB"),
    actionButton(ns("pull_csv"),"Pull User From CSV"),
    numericInput(ns("enter_main_user"), label = "Main user:", value = 1234),
    dataTableOutput(ns("main_user_table"))




  )

}

#' Shiny module server to serve UI selections
mod_user_selection_server2 <- function(id, username="Name") {

  moduleServer(id,
               function(input, output, session) {
                 userlist <- username
                 main_user_table <- reactive(psiCGM:::glucose_df_from_libreview_csv(file=file.path("inst/extdata/Firstname2Lastname2_glucose.csv"),
                                                                                    user_id = 1235))

                 observeEvent(input$press_button, {
                   userlist <- append(userlist,input$enter_text)
                   message(paste("button pressed:", paste(userlist, collapse = ",")))
                 })
                 # observeEvent(input$pull_db, {
                 #   main_user_table <- reactive(psiCGM:::glucose_df_from_db(ID=input$enter_main_user))
                 #   message(paste("pulled from db:", paste(input$enter_main_user)))
                 # })
                 # observeEvent(input$pull_csv, {
                 #   main_user_table <- reactive(psiCGM:::glucose_df_from_libreview_csv(file=file.path("inst/extdata/Firstname2Lastname2_glucose.csv"),
                 #                                                                      user_id = 1235))
                 #
                 #   message(paste("pulled from csv:", paste(input$enter_main_user)))
                 # })

                 # add_user_button<- reactive(input$press_button)

                 output$user <- reactive(input$enter_main_user) #renderText(paste(input$enter_text,"is", paste(userlist, collapse = ", ")))
                 output$main_user_table <- renderDataTable({
                   if (input$pull_db != 0)
                   { message(paste("pulled from db:", paste(input$enter_main_user)))
                     return(psiCGM:::glucose_df_from_db(user_id=input$enter_main_user))
                   }
                   if (input$pull_csv == 0) {
                     message("initial csv")
                     return(psiCGM:::glucose_df_from_libreview_csv(file=file.path("inst/extdata/Firstname2Lastname2_glucose.csv"),
                                                                   user_id = 1235))
                   }
                   message("default path")
                   psiCGM:::glucose_df_from_libreview_csv(file=file.path("inst/extdata/Firstname2Lastname2_glucose.csv"),
                                                          user_id = 1235)
                 })

                 output$db_plot <- renderPlot(psiCGM:::plot_glucose(psiCGM:::glucose_df_from_db(user_id=input$enter_main_user,
                                                                                                fromDate = "2021-06-01")))
               }
  )


}

user_selection_demo2 <- function() {

 userlist <- c("1234","789")

  ui <- biguserSelectionUI("x")
  server <- function(input, output, session) {
    mod_user_selection_server2("x", username = userlist)
  }
  shinyApp(ui, server)

}

#user_selection_demo2()




