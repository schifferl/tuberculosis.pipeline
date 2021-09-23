#' @keywords internal
#'
#' @importFrom dplyr mutate
#' @importFrom dplyr rename
#' @importFrom magrittr use_series
#' @importFrom purrr map
#' @importFrom purrr map_chr
#' @importFrom rentrez entrez_search
#' @importFrom rentrez entrez_summary
#' @importFrom rlang .data
#' @importFrom stringr str_extract
translate_geo_rownames <- function(geo_metadata_df) {
    sra_ids <-
        magrittr::use_series(geo_metadata_df, "rowname") |>
        purrr::map(~ rentrez::entrez_search("sra", .x)) |>
        purrr::map_chr(magrittr::use_series, "id")

    srr_ids <-
        purrr::map(sra_ids, ~ rentrez::entrez_summary("sra", id = .x)) |>
        purrr::map(magrittr::use_series, "runs") |>
        purrr::map_chr(stringr::str_extract, "SRR[0-9]+")

    dplyr::rename(geo_metadata_df, `Sample Accession` = .data$rowname) |>
        dplyr::mutate(rowname = srr_ids, .before = .data$`Sample Accession`)
}
