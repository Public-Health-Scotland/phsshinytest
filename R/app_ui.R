#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    div(
      class = "wrapper",
      bslib::page(
        theme = bslib::bs_theme(version = 5),
        div(
          class = "container d-flex justify-content-between align-items-center",
          img(
            class = "logo cursor-pointer m-3",
            src = "www/phs_logo.png",
            height = "90px",
            alt = "PHS logo"
          ),
          bslib::input_dark_mode()
        ),

        bslib::page_navbar(
          title = "PHS Shiny Test App",
          id = "main_nav",
          bg = "#3F3685",

          bslib::nav_panel(
            title = "Home",
            value = "home",
            mod_home_ui("home")
          ),
          bslib::nav_panel(
            title = "Analytics",
            value = "analytics",
            mod_analytics_ui("analytics")
          ),
          bslib::nav_panel(
            title = "Reporting",
            value = "reporting",
            mod_report_ui("reporting")
          ),
          bslib::nav_panel(
            title = "Open Data",
            value = "open_data",
            mod_open_data_ui("open_data")
          ),
          bslib::nav_spacer(),
          bslib::nav_menu(
            title = "Links",
            align = "right",
            bslib::nav_item(
              tags$a(
                shiny::icon("book"),
                span(
                  "Publication",
                  style = "font-size: 0.875rem; margin-left: 0.4rem;"
                ),
                href = "https://publichealthscotland.scot/publications/",
                target = "_blank"
              )
            ),
            bslib::nav_item(
              tags$a(
                shiny::icon("github"),
                span(
                  "PHS GitHub",
                  style = "font-size: 0.875rem; margin-left: 0.4rem;"
                ),
                href = "https://github.com/Public-Health-Scotland",
                target = "_blank"
              )
            )
          )
        )
      )
    ),
    div(
      class = "footer mt-5 py-5 bg-light",
      div(
        class = "container",
        div(
          class = "row",
          div(
            class = "col-md-4",
            h5("Quick Links"),
            tags$ul(
              class = "list-unstyled",
              tags$li(
                tags$a(
                  href = "https://www.publichealthscotland.scot/contact-us/freedom-of-information-foi-and-environmental-information-regulation-eir-requests/", 
                  "Freedom of Information"
                )
              ),
              tags$li(
                tags$a(
                  href = "https://www.publichealthscotland.scot/terms-and-conditions/", 
                  "Terms and Conditions"
                )
              ),
              tags$li(
                tags$a(
                  href = "https://www.publichealthscotland.scot/our-privacy-notice/organisational-background/", 
                  "Privacy notice"
                )
              )
            )
          ),
          div(
            class = "col-md-8",
            p(
              HTML("&#169"), 
              " Public Health Scotland."
            ),
            p("All content available under the ",
              tags$a(
                href = "https://www.nationalarchives.gov.uk/doc/open-government-licence/",
                "Open Government Licence v3.0"
              ),
              ", except where otherwise stated."
            ),
            p(
              class = "text-muted",
              "This is an open source, experimental, project. The content on this site is for test purposes only."
            )
          )
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "phsshinytestgolem"
    ),
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "www/custom.css"
    )
  )
}
