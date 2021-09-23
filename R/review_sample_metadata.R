#' @keywords internal
#'
#' @importFrom purrr compact
review_sample_metadata <- function(geo_metadata_list) {
    geo_metadata_list <-
        purrr::compact(geo_metadata_list)

    if (base::length(geo_metadata_list) == 0) {
        stop("Sample metadata can not be included.", call. = FALSE)
    }

    geo_metadata_list
}
