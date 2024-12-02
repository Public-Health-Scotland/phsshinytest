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
          )
        ),
        bslib::layout_column_wrap(
          heights_equal = "row",
          bslib::card(
            full_screen = TRUE,
            title = "Selected data",
            status = "light",
            bslib::card_body(
              DT::DTOutput(ns("open_data_preview")) |>
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
    groups <- reactive({
      get_groups()
    })

    observe({
      group_choices <- setNames(get_groups()$id, get_groups()$title)

      updateSelectInput(
        session,
        "open_data_group",
        choices = group_choices
      )
    })

    # Get datasets
    datasets <- reactive({
      req(input$open_data_group != "")

      withProgress(
        message = "Loading datasets...",
        value = 0.3,
        {
          get_group_datasets(input$open_data_group)
        }
      )
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
          choices = dataset_choices,
        )
      }
    })

    # Get resources
    resources <- reactive({
      req(input$open_data_dataset != "")

      withProgress(
        message = "Loading resources...",
        value = 0.6,
        {
          get_dataset_resources(input$open_data_dataset)
        }
      )
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

    # Get and display data
    output$open_data_preview <- DT::renderDT({
      req(input$open_data_resource)

      withProgress(
        message = "Loading data...",
        value = 0.9,
        {
          data <- get_resource_data(input$open_data_resource)

          DT::datatable(
            data,
            options = list(
              pageLength = 10,
              scrollX = TRUE,
              dom = "l<'sep'>Bfrtip",
              buttons = c("copy", "csv", "excel", "print")
            ),
            extensions = c("Buttons"),
            filter = "top"
          )
        }
      )
    })
  })
}
    
## To be copied in the UI
# mod_open_data_ui("open_data_1")
    
## To be copied in the server
# mod_open_data_server("open_data_1")
