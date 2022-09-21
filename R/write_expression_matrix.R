#' @keywords internal
#'
#' @importFrom stringr str_remove_all
#' @importFrom stringr str_c
#' @importFrom magrittr not
#' @importFrom purrr map_if
#' @importFrom utils read.csv
#' @importFrom purrr keep
#' @importFrom purrr map
#' @importFrom tibble column_to_rownames
write_expression_matrix <- function(download_dir, path = "~/abs-upload-data") {
    date_prefix <-
        base::basename(download_dir)

    csv_paths <-
        base::dir(path = download_dir, full.names = TRUE)

    obj_suffix <-
        base::basename(csv_paths) |>
        stringr::str_remove_all(".csv.gz")

    obj_names <-
        stringr::str_c(date_prefix, obj_suffix, sep = ".")

    file_names <-
        stringr::str_c(obj_names, ".rda")

    file_paths <-
        stringr::str_c(path, date_prefix, file_names, sep = "/")

    read_file <-
        base::file.exists(file_paths) |>
        magrittr::not()

    matrix_objs <-
        purrr::map_if(csv_paths, read_file, ~ utils::read.csv(.x)) |>
        purrr::keep(~ base::is.data.frame(.x)) |>
        purrr::map(~ tibble::column_to_rownames(.x)) |>
        purrr::map(~ base::as.matrix(.x))

    save_index <-
        base::seq_along(matrix_objs)

    upload_dir <-
        base::dirname(file_paths) |>
        base::unique()

    if (!base::dir.exists(upload_dir)) {
        base::dir.create(upload_dir, recursive = TRUE)
    }

    for (i in save_index) {
        base::assign(obj_names[[i]], matrix_objs[[i]])
        base::save(list = obj_names[[i]], file = file_paths[[i]], compress = "bzip2")
        base::rm(list = obj_names[[i]])
    }

    base::invisible(upload_dir)
}
