#' @keywords internal
#'
#' @importFrom dplyr bind_cols
#' @importFrom dplyr mutate
#' @importFrom magrittr set_names
#' @importFrom magrittr subtract
#' @importFrom readr read_tsv
#' @importFrom rlang .data
#' @importFrom snakecase to_snake_case
#' @importFrom stringr str_c
#' @importFrom stringr str_length
#' @importFrom stringr str_pad
#' @importFrom stringr str_remove_all
#' @importFrom stringr str_replace_all
#' @importFrom stringr str_subset
#' @importFrom stringr str_trunc
#' @importFrom tibble as_tibble
#' @importFrom tibble column_to_rownames
#' @importFrom utils download.file
#' @importFrom xml2 read_html
#' @importFrom xml2 xml_attrs
#' @importFrom xml2 xml_find_all
get_sample_metadata <- function(geo_series_accession) {
    series_directory <-
        base::tempdir() |>
        base::file.path(geo_series_accession)

    base::dir.create(series_directory, showWarnings = FALSE, recursive = TRUE)

    accession_nchar <-
        stringr::str_length(geo_series_accession)

    truncated_width <-
        magrittr::subtract(accession_nchar, 3)

    accession_short <-
        stringr::str_trunc(geo_series_accession, truncated_width, ellipsis = "") |>
        stringr::str_pad(accession_nchar, side = "right", pad = "n")

    parent_directory_url <-
        stringr::str_c("https://ftp.ncbi.nlm.nih.gov/geo/series/", accession_short, "/", geo_series_accession, "/matrix/")

    series_matrix_files <-
        xml2::read_html(parent_directory_url) |>
        xml2::xml_find_all("//a") |>
        xml2::xml_attrs("href") |>
        stringr::str_subset("^GSE")

    series_matrix_urls <-
        stringr::str_c(parent_directory_url, series_matrix_files)

    series_matrix_paths <-
        base::file.path(series_directory, series_matrix_files)

    base::mapply(utils::download.file, series_matrix_urls, series_matrix_paths)

    series_matrix_length <-
        base::length(series_matrix_paths)

    series_matrix_names <-
        stringr::str_remove_all(series_matrix_files, "_series_matrix.txt.gz")

    geo_metadata_list <-
        base::vector(mode = "list", length = series_matrix_length) |>
        magrittr::set_names(series_matrix_names)

    series_matrix_seq <-
        base::seq_len(series_matrix_length)

    for (i in series_matrix_seq) {
        series_matrix_connection <-
            base::gzfile(series_matrix_paths[i])

        series_matrix_character <-
            base::readLines(series_matrix_connection)

        base::close(series_matrix_connection)

        series_metadata <-
            stringr::str_subset(series_matrix_character, "!Series_") |>
            stringr::str_replace_all("!Series_", "series_") |>
            base::I() |>
            readr::read_tsv(col_names = FALSE, progress = FALSE, show_col_types = FALSE) |>
            dplyr::mutate(X1 = base::make.names(.data$X1, unique = TRUE)) |>
            dplyr::mutate(X1 = snakecase::to_snake_case(.data$X1)) |>
            tibble::column_to_rownames(var = "X1") |>
            base::t() |>
            tibble::as_tibble()

        sample_metadata <-
            stringr::str_subset(series_matrix_character, "!Sample_") |>
            stringr::str_replace_all("!Sample_", "sample_") |>
            base::I() |>
            readr::read_tsv(col_names = FALSE, progress = FALSE, show_col_types = FALSE) |>
            dplyr::mutate(X1 = base::make.names(.data$X1, unique = TRUE)) |>
            dplyr::mutate(X1 = snakecase::to_snake_case(.data$X1)) |>
            tibble::column_to_rownames(var = "X1") |>
            base::t() |>
            tibble::as_tibble()

        geo_metadata_list[[i]] <-
            dplyr::bind_cols(series_metadata, sample_metadata)
    }

    geo_metadata_list
}
