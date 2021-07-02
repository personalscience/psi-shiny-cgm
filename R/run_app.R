#' Run the Personal Science CGM Web Application
#' @title Personal Science Web App
#' @export
#' @import shiny
run_app <- function(){
  shinyApp(ui = ui,
           server = server)

}
