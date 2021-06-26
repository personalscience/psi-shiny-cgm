# text module ----

DEFAULT_LIBRELINK_FILE_PATH <- file.path(Sys.getenv("ONEDRIVE"),"General", "Health",
                                         "RichardSprague_glucose.csv")

plot_glucose <- function(glucose_raw, title = "Martha") {
  g = ggplot(data = glucose_raw, aes(x=time, y = value) )
  g + sprague_theme + geom_line(color = "red")  +
    labs(title = title, x = "", y = "mg/mL", subtitle = "Continuous glucose monitoring") +
    scale_x_datetime(date_breaks = "1 day", date_labels = "%a %b-%d") +
    coord_cartesian(ylim = c(40, 130))
}


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
    textOutput(NS(id, "text")),
    plotOutput(NS(id, "libreview1"))
  )

}

text_server <- function(id, df, glucose_df, vbl, threshhold) {

  moduleServer(id, function(input, output, session) {

    n <- reactive({sum(df()[[vbl]] > threshhold)})
    output$text <- renderText({
      paste("In this month",
            vbl,
            "exceeded the average daily threshhold of",
            threshhold,
            "a total of",
            n(),
            "days")
    })
    output$glucoseChart <- renderPlot(plot_glucose(glucose_df))

  })

}

cgm_demo <- function() {

  df <- data.frame(day = 1:30, arr_delay = 1:30)
  glucose_df <- glucose_from_csv(DEFAULT_LIBRELINK_FILE_PATH) %>% head(2000)
  ui <- fluidPage(libreview_ui("x"))
  server <- function(input, output, session) {
    text_server("x", reactive({df}), glucose_df, vbl = "arr_delay", threshhold =  15)
  }
  shinyApp(ui, server)

}

cgm_demo()
