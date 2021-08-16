# This is where the web app starts

#Sys.setenv(R_CONFIG_ACTIVE = "local")


#' Run the Personal Science CGM Web Application
#' @title Personal Science Web App
#' @param mode character string indicating operational mode: Uses config::get() or "run" (default)
#' @export
#' @import shiny
run_app <- function(mode = attr(config::get(),"config")){
  if(mode == "run") {Sys.setenv(R_CONFIG_ACTIVE = "local")}
  else Sys.setenv(R_CONFIG_ACTIVE = mode)
  shinyApp(ui = ui,
           server = server)

}
