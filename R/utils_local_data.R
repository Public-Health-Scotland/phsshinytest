#' Database connection and data access utilities
#'
#' @description Functions for managing database connections and accessing data.
#'
#' @name utils_local_data
#' @keywords internal
NULL

#' Get the database connection
#' @return A database connection
#' @noRd
get_db_connection <- function() {
    db_path <- app_sys("data/test_data.sqlite")
    DBI::dbConnect(RSQLite::SQLite(), db_path)
}

#' Get the data from the database
#' @param table The table to get the data from
#' @return A data frame
#' @noRd
data_access <- list(
    # Overview statistics
    get_overview_stats = function(conn) {
        list(
            total_service_users = DBI::dbGetQuery(conn, "SELECT COUNT(DISTINCT service_user_id) FROM service_users")[[1]],
            active_service_users = DBI::dbGetQuery(conn, "SELECT COUNT(DISTINCT service_user_id) FROM episodes WHERE episode_status = 'Active'")[[1]],
            total_episodes = DBI::dbGetQuery(conn, "SELECT COUNT(*) FROM episodes")[[1]],
            active_episodes = DBI::dbGetQuery(conn, "SELECT COUNT(*) FROM episodes WHERE episode_status = 'Active'")[[1]],
            due_assessments = DBI::dbGetQuery(conn, "SELECT COUNT(*) FROM episodes e WHERE e.episode_status = 'Active' AND NOT EXISTS (SELECT * FROM assessments a WHERE e.episode_id = a.episode_id)")[[1]]
        )
    },

    # Admissions statistics
    get_admissions_stats = function(conn) {
        list(
            active_admissions = DBI::dbGetQuery(conn, "SELECT COUNT(*) FROM episodes WHERE episode_status = 'Active'")[[1]],
            new_admissions = DBI::dbGetQuery(conn, "SELECT COUNT(*) FROM episodes WHERE referral_date >= CONVERT(datetime, '2023-12-01')")[[1]],
            awaiting_treatment = DBI::dbGetQuery(conn, "SELECT COUNT(*) FROM episodes WHERE episode_status = 'Active' AND NOT EXISTS (SELECT * FROM treatments WHERE episodes.episode_id = treatments.episode_id)")[[1]],
            discharged_before_treatment = DBI::dbGetQuery(conn, "SELECT COUNT(*) FROM episodes WHERE discharged_before_treatment")[[1]]
        )
    },

    get_referral_summary = function(conn) {
      DBI::dbGetQuery(conn, "
        SELECT
            COUNT(*) AS n,
            referral_date
        FROM episodes
        GROUP BY referral_date
      ")
    },

    get_services = function(conn) {
        DBI::dbGetQuery(conn, "SELECT service_name FROM services ORDER BY service_name")
    },

    get_referral_sources = function(conn) {
        DBI::dbGetQuery(conn, "
        SELECT
            rs.source_name,
            COUNT(*) as count
        FROM episodes e
        JOIN referral_sources rs ON e.referral_source_id = rs.referral_source_id
        GROUP BY rs.source_name
        ORDER BY count DESC
        ")
    },

    get_referral_trends = function(conn) {
        DBI::dbGetQuery(conn, "
        SELECT
            strftime('%Y-%m', referral_date) as month,
            COUNT(*) as referral_count,
            SUM(CASE WHEN discharged_before_treatment THEN 1 ELSE 0 END) as discharged_before_treatment_count
        FROM episodes
        GROUP BY strftime('%Y-%m', referral_date)
        ORDER BY month
        ")
    },

    # Treatment statistics
    get_treatment_stats = function(conn) {
        list(
            active_treatments = DBI::dbGetQuery(conn, "SELECT COUNT(*) FROM treatments WHERE completion_status = 'Ongoing'")[[1]]
        )
    },

    get_treatment_summary = function(conn) {
        DBI::dbGetQuery(conn, "
        SELECT
            tt.treatment_name,
            t.completion_status,
            COUNT(*) as count
        FROM treatments t
        JOIN treatment_types tt ON t.treatment_type_id = tt.treatment_type_id
        GROUP BY
            tt.treatment_name,
            t.completion_status
        ORDER BY count DESC
        ")
    },

    # Assessment statistics
    get_assessment_summary = function(conn) {
        DBI::dbGetQuery(conn, "
        SELECT
            COUNT(DINSTINCT e.episode_id) as total_episodes,
            COUNT(DINSTINCT a.episode_id) as assessed_episodes,
        FROM episodes e
        LEFT JOIN assessments a ON e.episode_id = a.episode_id
        WHERE NOT e.discharged_before_treatment
        ")
    }
)
