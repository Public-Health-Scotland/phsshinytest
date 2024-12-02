#' analytics UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_analytics_ui <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      class = "container",
      h1("Analytics"),
      div(
        #class = "d-none d-lg-block analytics-nav",
        class = "analytics-nav",
        bslib::navset_pill_list(
          id = "analytics_nav",
          well = FALSE,
          widths = c(3, 9),
          bslib::nav_panel(
            span(
              "Overview", 
              style = "margin-left: 0.6rem;"
            ),
            value = "overview",
            icon = icon("house"),
            mod_analytics_overview_ui(ns("overview"))
          ),
          bslib::nav_panel(
            span(
              "Admissions", 
              style = "margin-left: 0.6rem;"
            ),
            value = "admissions",
            icon = icon("bed"),
            mod_analytics_admissions_ui(ns("admissions"))
          ),
          bslib::nav_panel(
            span(
              "Assessments", 
              style = "margin-left: 0.6rem;"
            ),
            value = "assessments",
            icon = icon("notes-medical"),
            mod_analytics_assessments_ui(ns("assessments"))
          ),
          bslib::nav_panel(
            span(
              "Treatment", 
              style = "margin-left: 0.6rem;"
            ),
            value = "treatment",
            icon = icon("stethoscope"),
            mod_analytics_treatment_ui(ns("treatment"))
          ),
          bslib::nav_panel(
            span(
              "Data", 
              style = "margin-left: 0.6rem;"
            ),
            value = "data",
            icon = icon("database"),
            mod_analytics_data_ui(ns("data"))
          ),
          bslib::nav_spacer(),
          bslib::nav_item(
            bslib::card(
              id = "publication-card",
              bslib::card_body(
                h5("Test publication"),
                p("Access publication on PHS website"),
                actionButton(
                  ns("publication-link"),
                  class = "btn-light",
                  "View publication",
                  icon = icon("arrow-up-right-from-square")
                )
              )
            )
          )
        )
      ),
    ),
    tags$head(
      tags$link(
        rel = "stylesheet",
        type = "text/css",
        href = "www/mod_analytics.css"
      )
    )
  )
}

#' analytics Server Functions
#'
#' @noRd
mod_analytics_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    data <- mod_data_mgr_server("data_mgr")

    mod_analytics_overview_server("overview", data)
    # mod_analytics_admissions_server("admissions", data)
    # mod_analytics_assessments_server("assessments", data)
    # mod_analytics_treatment_server("treatment", data)
    # mod_analytics_data_server("data", data)

  })
}

## To be copied in the UI
# mod_analytics_ui("analytics_1")

## To be copied in the server
# mod_analytics_server("analytics_1")
