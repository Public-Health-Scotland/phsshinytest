#' analytics_assessments UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_analytics_assessments_ui <- function(id) {
  ns <- NS(id)
  tagList(
 
  )
}
    
#' analytics_assessments Server Functions
#'
#' @noRd 
mod_analytics_assessments_server <- function(id, data){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_analytics_assessments_ui("analytics_assessments_1")
    
## To be copied in the server
# mod_analytics_assessments_server("analytics_assessments_1")
