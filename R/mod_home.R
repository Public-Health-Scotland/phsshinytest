#' home UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_home_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::page_fixed(
      h1(
        "Home"
      ),
      div(
        class = "row",
        bslib::layout_column_wrap(
          width = "250px",
          mod_home_card_ui(
            ns("analytics"),
            "Analytics",
            "chart-simple",
            shinipsum::random_text(nwords = 20)
          ),
          mod_home_card_ui(
            ns("reporting"),
            "Reporting",
            "file-lines",
            shinipsum::random_text(nwords = 18)
          ),
          mod_home_card_ui(
            ns("open_data"),
            "Open Data",
            "cloud",
            shinipsum::random_text(nwords = 24)
          )
        )
      )
    )
  )
}

#' home Server Functions
#'
#' @noRd
mod_home_server <- function(id, main_session){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    mod_home_card_server("analytics", main_session)
    mod_home_card_server("reporting", main_session)
    mod_home_card_server("open_data", main_session)
  })
}

## To be copied in the UI
# mod_home_ui("home_1")

## To be copied in the server
# mod_home_server("home_1")
