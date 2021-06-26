library(ggthemes)
library(showtext)
font_add_google("Montserrat")
showtext_auto()


sprague_theme <-   theme(text = element_text(family = "Montserrat", face = "bold", size = 15),
                         axis.text.x = element_text(size = 15, angle = 90, hjust = 1),
                         legend.title = element_blank())

plot_glucose <- function(glucose_raw, title = "Martha") {
  g = ggplot(data = glucose_raw, aes(x=time, y = value) )
  g + sprague_theme + geom_line(color = "red")  +
    labs(title = title, x = "", y = "mg/mL", subtitle = "Continuous glucose monitoring") +
    scale_x_datetime(date_breaks = "1 day", date_labels = "%a %b-%d") +
    coord_cartesian(ylim = c(40, 130))
}


plotGlucoseServer <- function(id, glucose_df) {
  moduleServer(
    id,
    function(input, output, session) {

      return(ggplot(data=tibble(x=1:5,y=LETTERS[1:5]),
                    aes(x=x,y=x, label = y)) + geom_point() + geom_text(vjust = -1.5))
    }

  )
}

