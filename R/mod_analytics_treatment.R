#' analytics_treatment UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_analytics_treatment_ui <- function(id) {
  ns <- NS(id)
  tagList(
 
  )
}
    
#' analytics_treatment Server Functions
#'
#' @noRd 
mod_analytics_treatment_server <- function(id, data){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_analytics_treatment_ui("analytics_treatment_1")
    
## To be copied in the server
# mod_analytics_treatment_server("analytics_treatment_1")
