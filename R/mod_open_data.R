#' open_data UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_open_data_ui <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      class = "container",
      h1("Open Data"),
      bslib::layout_sidebar(
        sidebar = div(
          h5("Open Data explorer"),
          div(
            class = "d-flex flex-wrap",
            actionButton(
              ns("open_data_retrieve"),
              "Refresh data",
              icon = icon("arrows-rotate"),
              class = "btn-light flex-fill mb-3"
            )
          ),
          selectInput(
            ns("open_data_group"),
            "1. Group: ",
            choices = NULL
          ),
          selectInput(
            ns("open_data_dataset"),
            "2. Dataset: ",
            choices = NULL
          ),
          selectInput(
            ns("open_data_resource"),
            "3. Resource: ",
            choices = NULL
          ),
          div(
            class = "d-flex flex-wrap",
            actionButton(
              ns("open_data_view"),
              "View data",
              icon = icon("magnifying-glass"),
              class = "btn-primary flex-fill mt-3"
            )
          )
        ),
        bslib::layout_column_wrap(
          heights_equal = "row",
          bslib::card(
            full_screen = TRUE,
            title = "Selected data",
            status = "light",
            bslib::card_body(
              uiOutput(ns("open_data_view")) |>
                shinycssloaders::withSpinner()
            )
          )
        )
      )
    )
  )
}
    
#' open_data Server Functions
#'
#' @noRd 
mod_open_data_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # Get groups
    observeEvent(input$open_data_retrieve, {
      groups <- tryCatch({
        withProgress(
          message = "Loading data groups...",
          value = 0.3,
          {
            get_groups()
          }
        )
      }, error = function(e) {
        showNotification(
          "Failed to retrieve groups",
          duration = 5,
          type = "error"
        )
        message(e)
        return(NULL)
      })

      observe({
        group_choices <- setNames(groups$id, groups$title)

        updateSelectInput(
          session,
          "open_data_group",
          choices = group_choices
        )
      })
    })
    
    # Get datasets
    datasets <- reactive({
      req(input$open_data_group != "")

      tryCatch({
        withProgress(
          message = "Loading datasets...",
          value = 0.6,
          {
            get_group_datasets(input$open_data_group)
          }
        )
      }, error = function(e) {
        showNotification(
          "Failed to retrieve datasets",
          duration = 5,
          type = "error"
        )
        return(NULL)
      })
      
    })

    observe({
      if(input$open_data_group == "") {
        updateSelectInput(
          session,
          "open_data_dataset",
          choices = NULL
        )
      } else {
        dataset_choices <- setNames(datasets()$id, datasets()$title)

        updateSelectInput(
          session,
          "open_data_dataset",
          choices = dataset_choices
        )
      }
    })

    # Get resources
    resources <- reactive({
      req(input$open_data_dataset != "")

      tryCatch({
        withProgress(
          message = "Loading resources...",
          value = 0.9,
          {
            get_dataset_resources(input$open_data_dataset)
          }
        )
      }, error = function(e) {
        showNotification(
          "Failed to retrieve resources",
          duration = 5,
          type = "error"
        )
        return(NULL)
      })
    })

    observe({
      if(input$open_data_dataset == "") {
        updateSelectInput(
          session,
          "open_data_resource",
          choices = NULL
        ) 
      } else {
        resource_choices <- setNames(resources()$id, resources()$name)

        updateSelectInput(
          session,
          "open_data_resource",
          choices = resource_choices
        )
      }
    })

    output$open_data_view <- renderUI({
      if(!input$open_data_view || is.null(input$open_data_resource)) {
        div(
          class = "text-center",
          p("Please refresh data and select a resource to view")
        )
      } else {
        req(input$open_data_resource)
        DT::DTOutput(ns("open_data_preview")) |>
          shinycssloaders::withSpinner()
      }
    })

    # Get and display data when button is clicked
    observeEvent(input$open_data_view, {
      req(input$open_data_resource)

      output$open_data_preview <- DT::renderDT({
        withProgress(
          message = "Loading data...",
          value = 0.8,
          {
            data <- tryCatch({
              get_resource_data(input$open_data_resource)
            }, error = function(e) {
              showNotification(
                "Failed to retrieve data",
                duration = 5,
                type = "error"
              )
              return(NULL)
            })

            DT::datatable(
              data,
              options = list(
                pageLength = 10,  # Number of rows to display per page
                scrollX = TRUE,  # Enable horizontal scrolling
                dom = "l<'sep'>Bfrtip",  # Layout of the table controls
                buttons = c("copy", "csv", "excel", "print")  # Export buttons
              ),
              extensions = c("Buttons"),  # Enable Buttons extension
              filter = "top"  # Add a filter input box at the top of each column
            )
          }
        )
      })
    })
  })
}
    
## To be copied in the UI
# mod_open_data_ui("open_data_1")
    
## To be copied in the server
# mod_open_data_server("open_data_1")
