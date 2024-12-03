#' report UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_report_ui <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      class = "container",
      h1("Report"),
      bslib::layout_sidebar(
        sidebar = div(
          h5("Report builder"),
          selectInput(
            ns("report_service"),
            "Service: ",
            choices = NULL
          ),
          dateRangeInput(
            ns("report_date_range"),
            "Date range: ",
            start = lubridate::ymd("2022-12-31"),
            end = lubridate::ymd("2023-12-31"),
            min = "2018-01-01",
            max = "2023-12-31"
          ),
          checkboxGroupInput(
            ns("report_metrics"),
            "Metrics: ",
            choices = c(
              "Service Overview" = "overview",
              "Referrals" = "referrals",
              "Treatments" = "treatments",
              "Assessments" = "assessments"
            ),
            selected = c("overview", "referrals", "treatments", "assessments")
          ),
          div(
            class = "d-flex flex-wrap",
            actionButton(
              ns("report_preview"),
              "Preview report",
              class = "btn-light flex-fill m-1"
            ),
            downloadButton(
              ns("report_download"),
              "Download report",
              class = "btn-primary flex-fill m-1"
            )
          )
        ),
        div(
          bslib::card(
            full_screen = TRUE,
            bslib::card_header(
              "Report preview",
              bslib::tooltip(
                icon("info-circle"),
                "Report generated based on the selected options"
              )
            ),
            bslib::card_body(
              uiOutput(ns("report_content_preview"))
            )
          ),
          bslib::card(
            full_screen = TRUE,
            bslib::card_header(
              "Report data summary",
              bslib::tooltip(
                icon("info-circle"),
                "Data used to generate the report"
              )
            ),
            bslib::card_body(
              tableOutput(ns("report_data_preview"))
            )
          )
        )
      ),
    )
  )
}

#' report Server Functions
#'
#' @noRd
mod_report_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    data <- mod_data_mgr_server("data_mgr")

    # Report service selection (dropdown)
    observe({
      updateSelectInput(
        session,
        "report_service",
        choices = setNames(nm = data$services()$service_name)
      )
    })

    # Generate report
    generate_report <- function(output_format = "html_document", output_file = NULL) {
      req(input$report_service != "")

      render_env <- new.env(parent = globalenv())

      params <- list(
        service = input$report_service,
        active_referrals = data$overview_stats()$active_episodes,
        assessments_due = data$overview_stats()$due_assessments
      )

      template_file <- "inst/rmd/phs-mgtinfo-template/skeleton.Rmd"

      if (!file.exists(template_file)) {
        stop("Template file not found at: ", template_file)
      }

      if(is.null(output_file)) {
        output_file <- tempfile(fileext = paste0(tools::file_ext(output_format)))
      }

      tryCatch({
        rmarkdown::render(
          system.file("rmd/phs-mgtinfo-template/skeleton.Rmd", package = "phsshinytestgolem"),
          output_file = output_file,
          output_format = output_format,
          params = params,
          envir = render_env,
          quiet = FALSE
        )

        output_file
      },
      error = function(e) {
        stop("Error generating report: ", e$message)
      })
    }

    # Report preview
    report_preview_output <- eventReactive(input$report_preview, {
      withProgress(
        message = "Generating preview...",
        value = 0.5,
        {
          tryCatch({
            preview_file <- paste0(generate_report("html_document"), ".html")
            if (!file.exists(paste0(preview_file))) {
              stop("Preview file not found")
            }
            preview_content <- readLines(preview_file, warn = FALSE)
            unlink(preview_file)
            if (length(preview_content) == 0) {
              stop("Preview content is empty")
            }
            content <- paste(preview_content, collapse = "\n")
            body_content <- sub(".*<body[^>]*>(.*)</body>.*", "\\1", content)
            paste0(
              "<div class='report-preview-container'>",
              body_content,
              "</div>"
            )
          },
          error = function(e) {
          paste("Error generating preview: ", e$message)
          })
        }
      )
    })

    output$report_content_preview <- renderUI({
      req(report_preview_output())
      HTML(report_preview_output())
    })

    # Report download
    output$report_download <- downloadHandler(
      filename = function() {
        paste0("phstestreport - ", input$report_service, ".docx")
      },
      content = function(file) {
        output = generate_report(output_format = "word_document", output_file = file)
        file.copy(output, file)
      }
    )
  })
}

## To be copied in the UI
# mod_report_ui("report_1")

## To be copied in the server
# mod_report_server("report_1")
