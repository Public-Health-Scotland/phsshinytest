#' analytics_data UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_analytics_data_ui <- function(id) {
  ns <- NS(id)
  tagList(
 
  )
}
    
#' analytics_data Server Functions
#'
#' @noRd 
mod_analytics_data_server <- function(id, data){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_analytics_data_ui("analytics_data_1")
    
## To be copied in the server
# mod_analytics_data_server("analytics_data_1")
