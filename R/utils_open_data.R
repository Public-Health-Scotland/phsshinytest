#' Open Data CKAN API Utils

#' Base URL for the CKAN API
base_ckan_url <- "https://www.opendata.nhs.scot/api/3/action/"

#' CKAN API call
#' @param action The API action to perform
#' @param params A list of parameters to pass to the API
#'
#' @return Parsed JSON response
#'
#' @noRd
call_ckan_api <- function(action, params = list()) {
    url <- paste0(base_ckan_url, action)

    response <- httr::GET(
        url,
        query = params
    )

    # Debugging
    message("URL: ", url)
    message("Response: ", httr::status_code(response))

    if (httr::http_error(response)) {
        stop(
            "API call failed: ",
            httr::content(response, "text")
        )
    }

    content <- httr::content(response, "parsed")
    if (!content$success) {
        stop(
            "API call failed: ",
            content$error$message
        )
    }

    content$result
}

#' Get top-level groups
#' @return A data frame of groups
#' @noRd
get_groups <- function() {
    groups <- call_ckan_api("group_list", list(all_fields = TRUE))
    dplyr::bind_rows(lapply(groups, function(x) {
        list(
            id = x$id,
            name = x$name,
            title = x$title
        )
    }))
}

#' Get datasets from a group
#' @param group_id The group ID to get datasets for
#' @return A data frame of datasets
#' @noRd
get_group_datasets <- function(group_id) {
    datasets <- call_ckan_api("group_package_show", list(id = group_id))
    dplyr::bind_rows(lapply(datasets, function(x) {
        list(
            id = x$id,
            name = x$name,
            title = x$title,
            notes = x$notes
        )
    }))
}

#' Get resources from a dataset
#' @param dataset_id The dataset ID to get resources for
#' @return A data frame of resources
#' @noRd
get_dataset_resources <- function(dataset_id) {
    resources <- call_ckan_api("package_show", list(id = dataset_id))
    dplyr::bind_rows(lapply(resources$resources, function(x) {
        list(
            id = x$id,
            name = x$name,
            description = x$description
        )
    }))
}

#' Get data from a resource
#' @param resource_id The resource ID to get data from
#' @return A data frame of data
#' @noRd
get_resource_data <- function(resource_id) {
    tryCatch({
        resource <- call_ckan_api("datastore_search", list(id = resource_id))
        records <- resource$records
        if (length(records) == 0) {
            return(data.frame(message = "No data available"))
        }
        dplyr::bind_rows(records)
    }, error = function(e) {
        return(data.frame(message = e$message))
    })
}
