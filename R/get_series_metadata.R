#' @keywords internal
#'
#' @importFrom dplyr distinct
#' @importFrom dplyr select
#' @importFrom magrittr use_series
#' @importFrom purrr map
#' @importFrom purrr map_chr
#' @importFrom purrr map_int
#' @importFrom purrr reduce
#' @importFrom tibble tibble
#' @importFrom tidyselect starts_with
get_series_metadata <- function(geo_series_accession, entrez_uid) {
    `Entrez UID` <-
        base::as.character(entrez_uid)

    `Series Accession` <-
        base::as.character(geo_series_accession)

    geo_metadata_list <-
        get_sample_metadata(geo_series_accession)

    `Platform Accession` <-
        purrr::map(geo_metadata_list, ~ dplyr::select(.x, tidyselect::starts_with("series_platform_id"))) |>
        purrr::map(dplyr::distinct) |>
        purrr::map(base::as.character) |>
        purrr::reduce(base::unique)

    `Experiment Type` <-
        purrr::map(geo_metadata_list, magrittr::use_series, "series_type") |>
        purrr::map_chr(base::unique)

    `Sample Number` <-
        tidyup_sample_metadata(geo_metadata_list) |>
        purrr::map_int(base::nrow)

    tibble::tibble(`Entrez UID`, `Series Accession`, `Platform Accession`, `Experiment Type`, `Sample Number`)
}
