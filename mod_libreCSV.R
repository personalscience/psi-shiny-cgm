# module to plot glucose values

DEFAULT_LIBRELINK_FILE_PATH <- file.path(Sys.getenv("ONEDRIVE"),"General", "Health",
                                         "RichardSprague_glucose.csv")



glucose_from_csv <- function(csv_filepath){
  libre_raw <- readr::read_csv(csv_filepath, col_types = "cccdddddcddddcddddd",
                               skip = 1)
  libre_raw$`Device Timestamp` <- lubridate::force_tz(lubridate::mdy_hm(libre_raw$`Device Timestamp`), Sys.timezone())

  glucose <- libre_raw %>% transmute(time = `Device Timestamp`,
                                     scan = as.numeric(`Scan Glucose mg/dL`) ,
                                     hist = `Historic Glucose mg/dL` ,
                                     strip = as.numeric(`Strip Glucose mg/dL`),
                                     food = "Notes")


  glucose$value <- dplyr::if_else(is.na(glucose$scan),glucose$hist,glucose$scan)

  return(glucose)


}


libreview_ui <- function(id) {

  fluidRow(
    fileInput("ask_filename", "Choose CSV File", accept = ".csv"),
    dataTableOutput(NS(id, "glucoseTable"))
  )

}

test_server <- function(id,  librelink_csv) {
  message(librelink_csv)
  moduleServer(id, function(input, output, session) {
    glucose_df <- reactive(glucose_from_csv(librelink_csv))

    output$glucoseTable <- renderDataTable(
      glucose_df(),
      options = list(pageLength = 5))


  })

}

libreCSV_demo <- function() {


  #glucose_df <- glucose_from_csv(DEFAULT_LIBRELINK_FILE_PATH) %>% head(2000)
  ui <- fluidPage(libreview_ui("x"))
  server <- function(input, output, session) {
    test_server("x", DEFAULT_LIBRELINK_FILE_PATH)
  }
  shinyApp(ui, server)

}

libreCSV_demo()
