# module to plot glucose values

# library(tidyverse)
# library(ggthemes)
library(showtext)
font_add_google("Montserrat")
showtext_auto()

#' Stylized theme for consistent plot style
#' @import ggplot2
#' @export
psi_theme <-   theme(text = element_text(family = "Montserrat", face = "bold", size = 15),
                         axis.text.x = element_text(size = 15, angle = 90, hjust = 1),
                         legend.title = element_blank())


DEFAULT_LIBRELINK_FILE_PATH <- file.path(Sys.getenv("ONEDRIVE"),"General", "Health",
                                         "RichardSprague_glucose.csv")
#' @title Plot a glucose dataframe
#' @description Plot of a valid CGM file.
#' @param glucose_raw dataframe of a valid CGM data stream
#' @param title string to display on ggplot
#' @import ggplot2
#' @return ggplot object
plot_glucose <- function(glucose_raw, title = "Name") {
  g = ggplot(data = glucose_raw, aes(x=time, y = value) )
  g + psi_theme + geom_line(color = "red")  +
    labs(title = title, x = "", y = "mg/mL", subtitle = "Continuous glucose monitoring") +
    scale_x_datetime(date_breaks = "1 day", date_labels = "%a %b-%d") +
    coord_cartesian(ylim = c(40, 130))
}

#' Make a dataframe from a csv file
#' @param csv_filepath path to a valid Libreview CSV file
#' @import readr
#' @return dataframe of the glucose values from the Libreview csv file
# libreview_glucose_from_csv <- function(csv_filepath){
#   libre_raw <- readr::read_csv(csv_filepath, col_types = "cccdddddcddddcddddd",
#                                skip = 1)
#   libre_raw$`Device Timestamp` <- lubridate::force_tz(lubridate::mdy_hm(libre_raw$`Device Timestamp`), Sys.timezone())
#
#   glucose <- libre_raw %>% transmute(time = `Device Timestamp`,
#                                      scan = as.numeric(`Scan Glucose mg/dL`) ,
#                                      hist = `Historic Glucose mg/dL` ,
#                                      strip = as.numeric(`Strip Glucose mg/dL`),
#                                      food = "Notes")
#
#
#   glucose$value <- dplyr::if_else(is.na(glucose$scan),glucose$hist,glucose$scan)
#
#   return(glucose)
#
#
# }


libreviewUI <- function(id) {

  tagList(
    plotOutput(NS(id, "libreview"))
  )

}

mod_cgm_plot_server <- function(id,  glucose_df, title="Name") {

  moduleServer(id, function(input, output, session) {

    g <- reactive(plot_glucose(glucose_df, title))
    output$libreview <- renderPlot(g())

  })

}


cgm_demo <- function() {


  glucose_df <- glucose_df_from_libreview_csv(DEFAULT_LIBRELINK_FILE_PATH) %>% head(2000)
  ui <- fluidPage(libreviewUI("x"))
  server <- function(input, output, session) {
    mod_cgm_plot_server("x", glucose_df)
  }
  shinyApp(ui, server)

}


