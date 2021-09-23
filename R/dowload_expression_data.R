#' @keywords internal
#'
#' @importFrom googledrive drive_auth
#' @importFrom googledrive drive_ls
#' @importFrom dplyr filter
#' @importFrom rlang .data
#' @importFrom dplyr group_split
#' @importFrom purrr map
#' @importFrom googledrive drive_download
dowload_expression_data <- function(path = "~/expression-data") {
    current_date <-
        base::Sys.Date()

    download_dir <-
        base::paste(path, current_date, sep = "/")

    if (!base::dir.exists(download_dir)) {
        base::dir.create(download_dir, recursive = TRUE)
    }

    old_csv_files <-
        base::dir(path = path, pattern = "csv.gz", recursive = TRUE) |>
        base::basename()

    googledrive::drive_auth(email = TRUE, use_oob = TRUE)

    new_csv_files <-
        googledrive::drive_ls(path = "tuberculosis", pattern = "csv.gz", recursive = TRUE)

    reset_workdir <-
        base::getwd()

    base::setwd(download_dir)

    dplyr::filter(new_csv_files, !(.data[["name"]] %in% old_csv_files)) |>
        dplyr::group_split(.data[["name"]]) |>
        purrr::map(~ googledrive::drive_download(.x))

    base::setwd(reset_workdir)

    base::invisible(download_dir)
}
