#' @keywords internal
#'
#' @importFrom googledrive drive_auth
#' @importFrom googledrive drive_get
#' @importFrom googlesheets4 gs4_auth
#' @importFrom googlesheets4 read_sheet
#' @importFrom googlesheets4 sheet_append
#' @importFrom magrittr use_series
#' @importFrom purrr imap_dfr
#' @importFrom purrr map
#' @importFrom purrr pluck
#' @importFrom rentrez entrez_search
#' @importFrom rentrez entrez_summary
#' @importFrom stringr str_c
update_series_metadata <- function() {
    gds_terms <-
        stringr::str_c("\"Tuberculosis\"[MeSH Terms]") |>
        stringr::str_c("\"Homo sapiens\"[Organism]", sep = " AND ") |>
        stringr::str_c("\"gse\"[Filter]", sep = " AND ") |>
        stringr::str_c("(\"Expression profiling by array\"[Filter]", sep = " AND ") |>
        stringr::str_c("\"Expression profiling by high throughput sequencing\"[Filter])", sep = " OR ")

    googledrive::drive_auth(email = TRUE, use_oob = TRUE)

    googlesheets4::gs4_auth(email = TRUE, use_oob = TRUE)

    sheets_path <-
        googledrive::drive_get(path = "tuberculosis/series-metadata")

    sheets_uids <-
        googlesheets4::read_sheet(sheets_path) |>
        magrittr::use_series("Entrez UID") |>
        base::as.character()

    entrez_uids <-
        rentrez::entrez_search("gds", gds_terms, retmax = 9999) |>
        magrittr::use_series("ids") |>
        base::setdiff(sheets_uids) |>
        base::rev()

    if (base::length(entrez_uids) == 0) {
        message("Series metadata is up to date.")

        return(invisible(NULL))
    }

    series_metadata <-
        rentrez::entrez_summary("gds", entrez_uids, always_return_list = TRUE) |>
        purrr::map(purrr::pluck, "accession") |>
        purrr::imap_dfr(get_series_metadata)

    googlesheets4::sheet_append(sheets_path, series_metadata)

    series_metadata
}
