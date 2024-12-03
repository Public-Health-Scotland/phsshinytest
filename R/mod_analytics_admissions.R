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
    bslib::layout_column_wrap(
      bslib::value_box(
        title = "New admissions (last 30 days)",
        value = textOutput(ns("new_admissions")),
        showcase = icon("user-plus"),
        showcase_layout = "top right"
      ),
      bslib::value_box(
        title = "Waiting treatment",
        value = textOutput(ns("waiting_treatment")),
        showcase = icon("stopwatch"),
        showcase_layout = "top right"
      ),
      bslib::value_box(
        title = "Discharged before treatment",
        value = textOutput(ns("discharged_before_treatment")),
        showcase = icon("user-xmark"),
        showcase_layout = "top right"
      ),
    )
  )
}
    
#' analytics_admissions Server Functions
#'
#' @noRd 
mod_analytics_admissions_server <- function(id, data){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    output$new_admissions <- renderText({
      #data$admission_stats()$new_admissions
      1027
    })

    output$waiting_treatment <- renderText({
      #data$admission_stats()$discharged_before_treatment
      1381      
    })

    output$discharged_before_treatment <- renderText({
      data$admission_stats()$discharged_before_treatment
    })
  })
}
    
## To be copied in the UI
# mod_analytics_admissions_ui("analytics_admissions_1")
    
## To be copied in the server
# mod_analytics_admissions_server("analytics_admissions_1")

# Convert SQL to R using tidyverse functions and treating tables as dataframes
sql <- "SELECT COUNT(*) FROM episodes WHERE episode_status = 'Active' AND NOT EXISTS (SELECT * FROM treatments WHERE episodes.episode_id = treatments.episode_id)"
r <- "episodes %>% filter(episode_status == 'Active') %>% filter(!episode_id %in% treatments$episode_id) %>% nrow()"