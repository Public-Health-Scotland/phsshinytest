#' home_card UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_home_card_ui <- function(id, card_title, card_icon, card_text) {
  ns <- NS(id)
  tagList(
    div(
      class = "card h-100",
      div(
        class = "card-header bg-body border-0 d-flex justify-content-between align-items-center",
        h5(
          card_title,
          style = "margin: 0"
        ),
        shiny::icon(
          card_icon,
          style = "color: #9B4393; font-size: 30px; margin: 1rem"
        )
      ),
      div(
        class = "card-body",
        card_text,
      ),
      div(
        class = "card-footer border-0 bg-transparent",
        div(
          class = "d-flex align-items-center mb-2",
          style = "float: right;",
          actionButton(
            ns("info_btn"),
            label = "Info",
            class = "btn btn-link mx-1"
          ),
          actionButton(
            inputId = ns("view_btn"),
            label = "",
            class = "btn btn-primary mx-1",
            icon = shiny::icon(
              "arrow-right",
              style = "color: white;"
            )
          )
        )
      )
    )
  )
}

#' home_card Server Functions
#'
#' @noRd
mod_home_card_server <- function(id, main_session){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    observeEvent(input$info_btn, {
      showModal(modalDialog(
      title = "Information",
      "This is some information about the card.",
      easyClose = TRUE,
      footer = NULL
      ))
    })

    observeEvent(input$view_btn, {
      bslib::nav_select(
        id = "main_nav", 
        selected = id,
        session = main_session
      )
    })
  })
}

## To be copied in the UI
# mod_home_card_ui("home_card_1")

## To be copied in the server
# mod_home_card_server("home_card_1")
