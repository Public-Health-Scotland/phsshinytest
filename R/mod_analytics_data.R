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
    div(
      class = "analytics-subhead container d-flex justify-content-between align-items-center",
      h2("Data"),
      actionButton(ns("data_refresh"), "Refresh Data")
    ),
    bslib::layout_column_wrap(
      bslib::value_box(
        title = "RSIP Var",
        value = textOutput(ns("rsip_variable")),
        showcase = icon("database"),
        showcase_layout = "top right"
      ),
      bslib::value_box(
        title = "Active service users",
        value = "xxx",
        showcase = icon("user-check"),
        showcase_layout = "top right"
      ),
      bslib::value_box(
        title = "Active episodes",
        value = "xxx",
        showcase = icon("hand-holding-medical"),
        showcase_layout = "top right"
      ),
    )
  )
}

#' analytics_data Server Functions
#'
#' @noRd
mod_analytics_data_server <- function(id, data){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # Reactive that reads the RDS file
    read_value <- reactive({
      req(file.exists("/conf/RSIP/uat_data/var.RDS"))
      readRDS(here::here("/conf/RSIP/uat_data/var.RDS"))
    })

    # Observe refresh button to re-read file
    value <- eventReactive(input$data_refresh, {
      read_value()
    }, ignoreNULL = FALSE)

    # Display the number
    output$rsip_variable <- renderText({
      val <- value()
      if (is.null(val)) {
        "No value found"
      } else {
        paste(val)
      }
    })

  })
}

## To be copied in the UI
# mod_analytics_data_ui("analytics_data_1")

## To be copied in the server
# mod_analytics_data_server("analytics_data_1")
