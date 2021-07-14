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

#' @title Generate a ggplot2 overlay for notes dataframe
#' @description
#' When following a `plot_glucose()` call to generate a ggplot object, this returns a
#' ggplot object to draw the correct information from the notes dataframe
#' @import ggplot2
#' @param notes_df a valid notes dataframe
#' @return ggplot object
plot_notes_overlay <- function(g, notes_df) {

  f = geom_vline(xintercept = notes_df %>%
                   dplyr::filter(.data$Activity == "Food") %>% select("Start") %>%
                   unlist(), color = "yellow")

  fc =   geom_text(data = notes_df %>%
                     dplyr::filter(.data$Activity == "Food") %>% select("Start",
                                                                        "Comment"), aes(x = Start, y = 50, angle = 90, hjust = FALSE,
                                                                                        label = Comment), size = 6)


  s <- geom_rect(data = notes_df %>%
              dplyr::filter(.data$Activity == "Sleep") %>%
              select(xmin = .data$Start,
                     xmax = End) %>%
              cbind(ymin = -Inf, ymax = Inf),
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = "red",
            alpha = 0.2, inherit.aes = FALSE)

  return(g + s + f + fc)



}
