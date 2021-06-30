# module to plot glucose values

library(tidyverse)
library(ggthemes)
library(showtext)
font_add_google("Montserrat")
showtext_auto()


sprague_theme <-   theme(text = element_text(family = "Montserrat", face = "bold", size = 15),
                         axis.text.x = element_text(size = 15, angle = 90, hjust = 1),
                         legend.title = element_blank())


DEFAULT_LIBRELINK_FILE_PATH <- file.path(Sys.getenv("ONEDRIVE"),"General", "Health",
                                         "RichardSprague_glucose.csv")

plot_glucose <- function(glucose_raw, title = "Martha") {
  g = ggplot(data = glucose_raw, aes(x=time, y = value) )
  g + sprague_theme + geom_line(color = "red")  +
    labs(title = title, x = "", y = "mg/mL", subtitle = "Continuous glucose monitoring") +
    scale_x_datetime(date_breaks = "1 day", date_labels = "%a %b-%d") +
    coord_cartesian(ylim = c(40, 130))
}


libreview_glucose_from_csv <- function(csv_filepath){
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


libreviewUI <- function(id) {

  tagList(
    plotOutput(NS(id, "libreview"))
  )

}

mod_cgm_plot_server <- function(id,  glucose_df, title="Name") {

  moduleServer(id, function(input, output, session) {

    output$libreview <- renderPlot(plot_glucose(glucose_df, title))

  })

}

cgm_demo <- function() {


  glucose_df <- libreview_glucose_from_csv(DEFAULT_LIBRELINK_FILE_PATH) %>% head(2000)
  ui <- fluidPage(libreviewUI("x"))
  server <- function(input, output, session) {
    mod_cgm_plot_server("x", glucose_df)
  }
  shinyApp(ui, server)

}


