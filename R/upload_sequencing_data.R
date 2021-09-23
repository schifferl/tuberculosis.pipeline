#' @keywords internal
#'
#' @importFrom dplyr across
#' @importFrom dplyr bind_rows
#' @importFrom dplyr filter
#' @importFrom dplyr group_by
#' @importFrom dplyr if_else
#' @importFrom dplyr mutate
#' @importFrom dplyr rename_with
#' @importFrom dplyr select
#' @importFrom dplyr summarize
#' @importFrom dplyr ungroup
#' @importFrom furrr future_map
#' @importFrom googledrive drive_auth
#' @importFrom googledrive drive_put
#' @importFrom readr read_tsv
#' @importFrom readr write_csv
#' @importFrom rlang .data
#' @importFrom stringr str_c
#' @importFrom stringr str_remove_all
#' @importFrom stringr str_split
#' @importFrom stringr str_subset
#' @importFrom tidyr pivot_longer
#' @importFrom tidyr pivot_wider
#' @importFrom tidyselect starts_with
upload_sequencing_data <- function(geo_sequencing_path) {
    geo_series_accession <-
        stringr::str_split(geo_sequencing_path, "/", simplify = TRUE) |>
        stringr::str_subset("^GSE")

    csv_file <-
        base::tempdir() |>
        base::file.path(geo_series_accession) |>
        stringr::str_c(".csv.gz")

    geo_sequencing_df <-
        base::dir(path = geo_sequencing_path, pattern = "tsv", full.names = TRUE, recursive = TRUE) |>
        furrr::future_map(readr::read_tsv, col_types = "-ci", progress = FALSE) |>
        furrr::future_map(~ tidyr::pivot_longer(.x, tidyselect::starts_with("SRR"))) |>
        dplyr::bind_rows() |>
        tidyr::pivot_wider(values_fn = base::sum) |>
        dplyr::rename_with(~ stringr::str_remove_all(.x, "Aligned.sortedByCoord.out.bam")) |>
        dplyr::rename_with(~ stringr::str_remove_all(.x, "_1")) |>
        dplyr::mutate(rowname = map_symbol(.data$gene_name), .before = .data$gene_name) |>
        dplyr::mutate(rowname = dplyr::if_else(base::is.na(.data$rowname), map_prev_symbol(.data$gene_name), .data$rowname)) |>
        dplyr::mutate(rowname = dplyr::if_else(base::is.na(.data$rowname), map_alias_symbol(.data$gene_name), .data$rowname)) |>
        dplyr::filter(!base::is.na(.data$rowname)) |>
        dplyr::group_by(.data$rowname) |>
        dplyr::summarize(dplyr::across(tidyselect::starts_with("SRR"), base::sum)) |>
        dplyr::ungroup() |>
        dplyr::select(.data$rowname, tidyselect::starts_with("SRR")) |>
        readr::write_csv(csv_file, progress = FALSE)

    googledrive::drive_auth(email = TRUE, use_oob = TRUE)

    googledrive::drive_put(csv_file, path = "tuberculosis/sequencing-data/")

    geo_sequencing_df
}
