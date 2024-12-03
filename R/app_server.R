#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  
  mod_home_server("home", session)
  mod_analytics_server("analytics")
  mod_report_server("reporting")
  mod_open_data_server("open_data")

}
