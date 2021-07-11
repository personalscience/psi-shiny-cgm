# Plot glucose

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
