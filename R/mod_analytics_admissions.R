#' analytics_admissions UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_analytics_admissions_ui <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      class = "analytics-subhead container d-flex justify-content-between align-items-center",
      h2("Admissions")
    ),
    
  )
}
    
#' analytics_admissions Server Functions
#'
#' @noRd 
mod_analytics_admissions_server <- function(id, data){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_analytics_admissions_ui("analytics_admissions_1")
    
## To be copied in the server
# mod_analytics_admissions_server("analytics_admissions_1")
