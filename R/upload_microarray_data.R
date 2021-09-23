#' @keywords internal
#'
#' @importFrom googledrive drive_auth
#' @importFrom googledrive drive_put
#' @importFrom readr write_csv
#' @importFrom stringr str_c
upload_microarray_data <- function(geo_microarray_df, geo_series_accession) {
    csv_file <-
        base::tempdir() |>
        base::file.path(geo_series_accession) |>
        stringr::str_c(".csv.gz")

    readr::write_csv(geo_microarray_df, csv_file, progress = FALSE)

    googledrive::drive_auth(email = TRUE, use_oob = TRUE)

    googledrive::drive_put(csv_file, path = "tuberculosis/microarray-data/")

    geo_microarray_df
}
