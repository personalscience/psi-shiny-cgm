# chooseLibreviewUI.R
# Shiny module to select a CSV file.



# Module UI function
csvFileUI <- function(id, label = "CSV file") {
  # `NS(id)` returns a namespace function, which was save as `ns` and will
  # invoke later.
  ns <- NS(id)

  tagList(
    fileInput(ns("file"), label)
  )

}


# Module server function
csvFileServer <- function(id, stringsAsFactors) {
  moduleServer(
    id,
    ## Below is the module function
    function(input, output, session) {
      # The selected file, if any
      userFile <- reactive({
        # If no file is selected, don't do anything
        validate(need(input$file, message = FALSE))
        input$file
      })

      # The user's data, parsed into a data frame
      dataframe <- reactive({
        readr::read_csv(userFile()$datapath, col_types = "cccdddddcddddcddddd",
                        skip = 1)
      })

      # We can run observers in here if we want to
      observe({
        msg <- sprintf("File %s was uploaded", userFile()$name)
        cat(msg, "\n")
      })

      # Return the reactive that yields the data frame
      return(dataframe)
    }
  )
}

demo_read_CSV <- function () {
  ui <- fluidPage(
    sidebarLayout(
      sidebarPanel(csvFileUI("datafile", "Libreview CSV file")
                   ),
      mainPanel(
        dataTableOutput("table")
      )
    )
  )

  server <- function(input, output, session) {
    datafile <- csvFileServer("datafile",stringsAsFactors = FALSE)


    output$table <- renderDataTable({
      datafile()
    })

  }
  shinyApp(ui, server)
}



