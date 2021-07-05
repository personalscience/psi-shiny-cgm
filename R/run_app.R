# This is where the web app starts

Sys.setenv(R_CONFIG_ACTIVE = "local")


#' Run the Personal Science CGM Web Application
#' @title Personal Science Web App
#' @export
#' @import shiny
run_app <- function(){
  shinyApp(ui = ui,
           server = server)

}
