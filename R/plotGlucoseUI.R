
# plot glucose


plotGlucoseUI <- function(id, label = "glucoseChartModule") {
  ns = NS(id)
  tagList(
    plotOutput(ns("glucoseChart"))
  )
}

