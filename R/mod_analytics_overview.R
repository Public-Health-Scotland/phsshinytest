#' analytics_overview UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_analytics_overview_ui <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      class = "analytics-subhead container d-flex justify-content-between align-items-center",
      h2("Overview"),
      selectInput(
        ns("user"),
        "",
        choices = c("Group A", "Group B", "Group C")
      ),
    ),
    bslib::layout_column_wrap(
      bslib::value_box(
        title = "Total service users",
        value = textOutput(ns("total_service_users")),
        showcase = icon("users"),
        showcase_layout = "top right"
      ),
      bslib::value_box(
        title = "Active service users",
        value = textOutput(ns("active_service_users")),
        showcase = icon("user-check"),
        showcase_layout = "top right"
      ),
      bslib::value_box(
        title = "Active episodes",
        value = textOutput(ns("active_episodes")),
        showcase = icon("hand-holding-medical"),
        showcase_layout = "top right"
      ),
    ),
    bslib::card(
      full_screen = TRUE,
      bslib::card_header(
        "Admissions over time",
        bslib::tooltip(
          icon("info-circle"),
          "Number of admissions over time"
        )
      ),
      fluidRow(
        column(
          width = 5,
          dateRangeInput(
            ns("admissions_date_range"),
            "Date range:",
            start = lubridate::ymd("2023-12-31") - lubridate::days(90),
            end = lubridate::ymd("2023-12-31"),
            min = "2018-01-01",  # Adjust based on your data
            max = "2023-12-31"
          )
        )
      ),
      plotly::plotlyOutput(ns("admissions_time_series"))
    )
  )
}
    
#' analytics_overview Server Functions
#'
#' @noRd 
mod_analytics_overview_server <- function(id, data){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    output$total_service_users <- renderText({
      data$overview_stats()$total_service_users
    })

    output$active_service_users <- renderText({
      data$overview_stats()$active_service_users
    })

    output$active_episodes <- renderText({
      data$overview_stats()$active_episodes
    })

    filtered_data <- reactive({
      req(input$admissions_date_range)
      data$referral_summary() |>
        dplyr::filter(
          referral_date >= input$admissions_date_range[1],
          referral_date <= input$admissions_date_range[2]
        )
    })

    output$admissions_time_series <- plotly::renderPlotly({
      req(filtered_data())

      p <- filtered_data() |>
        ggplot2::ggplot(ggplot2::aes(
          x = lubridate::as_date(referral_date), 
          y = n,
          text = paste0(
            "Date: ", lubridate::as_date(referral_date), "\n",
            "Referrals: ", n
          ))) +
        ggplot2::geom_line(
          ggplot2::aes(group = 1),
          colour = "#3F3685"
        ) +
        ggplot2::geom_point(colour = "#3F3685") +
        ggplot2::ylim(0, NA) +
        ggplot2::theme_minimal() +
        ggplot2::theme(
          axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 10)),
          axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 10)),
        ) +
        ggplot2::labs(
          x = NULL,
          y = "Admissions",
          title = NULL
        )

      plotly::ggplotly(p, tooltip = "text") |>
        plotly::config(
          displayModeBar = TRUE,
          modeBarButtonsToRemove = list(
            "zoomIn2d", "zoomOut2d", "autoScale2d",
            "toggleSpikelines", "hoverClosestCartesian",
            "hoverCompareCartesian", "lasso2d", "select2d"
          ),
          displaylogo = FALSE
        )
    })
    
  })
}
    
## To be copied in the UI
# mod_analytics_overview_ui("analytics_overview_1")
    
## To be copied in the server
# mod_analytics_overview_server("analytics_overview_1")
