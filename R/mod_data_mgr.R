#' data_mgr Server Functions
#'
#' @noRd 
mod_data_mgr_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    # Initialise database connection
    conn <- get_db_connection()

    # Close the connection when the session ends
    session$onSessionEnded(function() {
      DBI::dbDisconnect(conn)
    })

    # Return reactive functions to access the database
    list(
      overview_stats = reactive({ data_access$get_overview_stats(conn) }),
      admission_stats = reactive({ data_access$get_admission_stats(conn) }),
      referral_summary = reactive({ data_access$get_referral_summary(conn) }),
      services = reactive({ data_access$get_services(conn) }),
      referral_sources = reactive({ data_access$get_referral_sources(conn) }),
      referral_trends = reactive({ data_access$get_referral_trends(conn) }),
      treatment_stats = reactive({ data_access$get_treatment_stats(conn) }),
      treatment_summary = reactive({ data_access$get_treatment_summary(conn) }),
      assessment_summary = reactive({ data_access$get_assessment_summary(conn) })
    )
  })
}
    
## To be copied in the UI
# mod_data_mgr_ui("data_mgr_1")
    
## To be copied in the server
# mod_data_mgr_server("data_mgr_1")
