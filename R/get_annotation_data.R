#' @keywords internal
#'
#' @importFrom readr col_character
#' @importFrom readr cols
#' @importFrom readr read_tsv
#' @importFrom stringr str_c
#' @importFrom stringr str_remove
#' @importFrom stringr str_replace
#' @importFrom xml2 read_html
#' @importFrom xml2 xml_attr
#' @importFrom xml2 xml_find_first
get_annotation_data <- function(geo_platform_accession) {
    col_specs <-
        readr::cols(.default = readr::col_character())

    stringr::str_c("https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=", geo_platform_accession) |>
        xml2::read_html() |>
        xml2::xml_find_first("//input[@name='fulltable']") |>
        xml2::xml_attr("onclick") |>
        stringr::str_replace("OpenLink\\('", "https://www.ncbi.nlm.nih.gov") |>
        stringr::str_replace("window.open\\('", "https://www.ncbi.nlm.nih.gov") |>
        stringr::str_replace("view=data", "mode=raw&is_datatable=true") |>
        stringr::str_remove("', '_self'\\)") |>
        stringr::str_remove("', '_blank'\\)") |>
        readr::read_tsv(col_types = col_specs, comment = "#", progress = FALSE)
}
