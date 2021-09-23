#' @keywords internal
#'
#' @importFrom googledrive drive_auth
#' @importFrom googledrive drive_put
#' @importFrom readr write_csv
#' @importFrom stringr str_c
upload_sample_metadata <- function(geo_metadata_df, geo_series_accession) {
    csv_file <-
        base::tempdir() |>
        base::file.path(geo_series_accession) |>
        stringr::str_c(".csv")

    readr::write_csv(geo_metadata_df, csv_file, progress = FALSE)

    googledrive::drive_auth(email = TRUE, use_oob = TRUE)

    googledrive::drive_put(csv_file, path = "tuberculosis/sample-metadata/", type = "spreadsheet")

    geo_metadata_df
}
