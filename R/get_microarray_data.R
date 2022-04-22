#' @keywords internal
#'
#' @importFrom affy ReadAffy
# @importFrom affy exprs
# @importFrom affy rma
#' @importFrom dplyr across
#' @importFrom dplyr c_across
#' @importFrom dplyr filter
#' @importFrom dplyr group_by
#' @importFrom dplyr inner_join
#' @importFrom dplyr n
#' @importFrom dplyr rename
#' @importFrom dplyr rename_with
#' @importFrom dplyr rowwise
#' @importFrom dplyr select
#' @importFrom dplyr slice_sample
#' @importFrom dplyr summarize
#' @importFrom dplyr transmute
#' @importFrom dplyr ungroup
#' @importFrom limma backgroundCorrect
#' @importFrom limma backgroundCorrect.matrix
#' @importFrom limma read.idat
#' @importFrom limma read.maimages
#' @importFrom magrittr extract
#' @importFrom magrittr inset
#' @importFrom magrittr set_colnames
#' @importFrom magrittr set_rownames
#' @importFrom magrittr use_series
# @importFrom oligo exprs
#' @importFrom oligo read.celfiles
# @importFrom oligo rma
#' @importFrom purrr map
#' @importFrom purrr map_chr
#' @importFrom purrr map2
#' @importFrom purrr reduce
#' @importFrom readr cols
#' @importFrom readr read_tsv
#' @importFrom rlang .data
#' @importFrom stringr str_c
#' @importFrom stringr str_extract
#' @importFrom stringr str_remove
#' @importFrom stringr str_remove_all
#' @importFrom stringr str_replace
#' @importFrom tibble as_tibble
#' @importFrom tibble column_to_rownames
#' @importFrom tidyselect any_of
#' @importFrom tidyselect starts_with
#' @importFrom utils data
get_microarray_data <- function(geo_metadata_df, geo_series_accession) {
    series_directory <-
        base::tempdir() |>
        base::file.path(geo_series_accession)

    base::dir.create(series_directory, showWarnings = FALSE, recursive = TRUE)

    file_urls <-
        magrittr::use_series(geo_metadata_df, "sample_supplementary_file")

    file_extensions <-
        stringr::str_remove_all(file_urls, "^.+/") |>
        stringr::str_extract("\\..+\\.gz")

    file_names <-
        magrittr::use_series(geo_metadata_df, "rowname") |>
        stringr::str_c(file_extensions)

    file_paths <-
        base::file.path(series_directory, file_names)

    base::mapply(utils::download.file, file_urls, file_paths)

    series_platform <-
        magrittr::use_series(geo_metadata_df, "Platform Accession") |>
        base::unique()

    if (series_platform == "GPL96") {
        `HG-U133A` <-
            utils::data("HG-U133A") |>
            base::get()

        GPL96 <-
            utils::data("GPL96") |>
            base::get()

        geo_microarray_df <-
            affy::ReadAffy(filenames = file_paths, compress = TRUE, cdfname = "HG-U133A") |>
            affy::rma(verbose = FALSE, normalize = FALSE, background = FALSE) |>
            affy::exprs() |>
            magrittr::set_colnames(geo_metadata_df$rowname) |>
            limma::backgroundCorrect.matrix(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            tibble::as_tibble(rownames = "ID") |>
            dplyr::inner_join(GPL96, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL570") {
        `HG-U133_Plus_2` <-
            utils::data("HG-U133_Plus_2") |>
            base::get()

        GPL570 <-
            utils::data("GPL570") |>
            base::get()

        geo_microarray_df <-
            affy::ReadAffy(filenames = file_paths, compress = TRUE, cdfname = "HG-U133_Plus_2") |>
            affy::rma(verbose = FALSE, normalize = FALSE, background = FALSE) |>
            affy::exprs() |>
            magrittr::set_colnames(geo_metadata_df$rowname) |>
            limma::backgroundCorrect.matrix(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            tibble::as_tibble(rownames = "ID") |>
            dplyr::inner_join(GPL570, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL6480") {
        file_names <-
            stringr::str_remove_all(file_names, file_extensions)

        file_extensions <-
            stringr::str_remove(file_extensions, "\\.")

        GPL6480 <-
            utils::data("GPL6480") |>
            base::get()

        geo_microarray_df <-
            limma::read.maimages(files = file_names, source = "agilent", path = series_directory, ext = file_extensions, green.only = TRUE, verbose = FALSE) |>
            limma::backgroundCorrect(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            base::as.data.frame() |>
            dplyr::rename(ID = .data$ProbeName) |>
            dplyr::inner_join(GPL6480, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL1352") {
        U133_X3P <-
            utils::data("U133_X3P") |>
            base::get()

        GPL1352 <-
            utils::data("GPL1352") |>
            base::get()

        geo_microarray_df <-
            affy::ReadAffy(filenames = file_paths, compress = TRUE, cdfname = "U133_X3P") |>
            affy::rma(verbose = FALSE, normalize = FALSE, background = FALSE) |>
            affy::exprs() |>
            magrittr::set_colnames(geo_metadata_df$rowname) |>
            limma::backgroundCorrect.matrix(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            tibble::as_tibble(rownames = "ID") |>
            dplyr::inner_join(GPL1352, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL6947") {
        col_specs <-
            readr::cols()

        file_names <-
            stringr::str_remove_all(file_names, file_extensions)

        GPL6947 <-
            utils::data("GPL6947") |>
            base::get()

        geo_microarray_df <-
            purrr::map(file_paths, readr::read_tsv, col_types = col_specs, progress = FALSE) |>
            purrr::map(~ dplyr::rename_with(.x, stringr::str_replace, .cols = tidyselect::starts_with("ID_REF"), ".+", "rowname")) |>
            purrr::map(~ dplyr::rename_with(.x, stringr::str_replace, .cols = tidyselect::starts_with("Probe_ID"), ".+", "rowname")) |>
            purrr::map2(file_names, ~ dplyr::rename_with(.x, stringr::str_replace, .cols = tidyselect::starts_with("VALUE"), ".+", .y)) |>
            purrr::map2(file_names, ~ dplyr::rename_with(.x, stringr::str_replace, .cols = tidyselect::starts_with("Signal"), ".+", .y)) |>
            purrr::map(~ dplyr::select(.x, "rowname", tidyselect::any_of(file_names))) |>
            purrr::reduce(dplyr::inner_join, by = "rowname") |>
            dplyr::group_by(.data$rowname) |>
            dplyr::filter(dplyr::n() == 1) |>
            dplyr::ungroup() |>
            tibble::column_to_rownames() |>
            base::data.matrix() |>
            limma::backgroundCorrect.matrix(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            tibble::as_tibble(rownames = "ID") |>
            dplyr::inner_join(GPL6947, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL6254") {
        col_specs <-
            readr::cols()

        file_names <-
            stringr::str_remove_all(file_names, file_extensions)

        row_names <-
            purrr::map(file_paths, readr::read_tsv, col_types = col_specs, progress = FALSE) |>
            purrr::map(magrittr::use_series, "ID_REF") |>
            purrr::reduce(~ base::ifelse(.x == .y, .x, NULL))

        GPL6254 <-
            utils::data("GPL6254") |>
            base::get()

        geo_microarray_df <-
            purrr::map(file_paths, readr::read_tsv, col_types = col_specs, progress = FALSE) |>
            purrr::map(dplyr::rowwise) |>
            purrr::map(~ dplyr::transmute(.x, VALUE = base::mean(dplyr::c_across(cols = tidyselect::starts_with("Sig_"))))) |>
            purrr::map(dplyr::ungroup) |>
            purrr::map2(file_names, ~ dplyr::rename_with(.x, stringr::str_replace, .cols = tidyselect::starts_with("VALUE"), ".+", .y)) |>
            purrr::reduce(base::cbind) |>
            base::data.matrix() |>
            limma::backgroundCorrect.matrix(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            magrittr::set_rownames(row_names) |>
            tibble::as_tibble(rownames = "ID") |>
            dplyr::group_by(.data$ID) |>
            dplyr::summarize(dplyr::across(.cols = tidyselect::starts_with("GSM"), .fns = base::mean)) |>
            dplyr::ungroup() |>
            dplyr::inner_join(GPL6254, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL1708") {
        file_names <-
            stringr::str_remove_all(file_names, file_extensions)

        file_extensions <-
            stringr::str_remove(file_extensions, "\\.")

        GPL1708 <-
            utils::data("GPL1708") |>
            base::get()

        geo_microarray_df <-
            limma::read.maimages(files = file_names, source = "agilent", path = series_directory, ext = file_extensions, green.only = TRUE, verbose = FALSE) |>
            limma::backgroundCorrect(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            base::as.data.frame() |>
            dplyr::rename(SPOT_ID = .data$ProbeName) |>
            dplyr::inner_join(GPL1708, by = "SPOT_ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL6884") {
        col_specs <-
            readr::cols()

        file_names <-
            stringr::str_remove_all(file_names, file_extensions)

        GPL6884 <-
            utils::data("GPL6884") |>
            base::get()

        geo_microarray_df <-
            purrr::map(file_paths, readr::read_tsv, col_types = col_specs, progress = FALSE) |>
            purrr::map(~ dplyr::rename_with(.x, stringr::str_replace, .cols = tidyselect::starts_with("ID_REF"), ".+", "rowname")) |>
            purrr::map2(file_names, ~ dplyr::rename_with(.x, stringr::str_replace, .cols = tidyselect::starts_with("VALUE"), ".+", .y)) |>
            purrr::map(~ dplyr::select(.x, "rowname", tidyselect::any_of(file_names))) |>
            purrr::reduce(dplyr::inner_join, by = "rowname") |>
            dplyr::group_by(.data$rowname) |>
            dplyr::filter(dplyr::n() == 1) |>
            dplyr::ungroup() |>
            tibble::column_to_rownames() |>
            base::data.matrix() |>
            limma::backgroundCorrect.matrix(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            tibble::as_tibble(rownames = "ID") |>
            dplyr::inner_join(GPL6884, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL4133") {
        file_names <-
            stringr::str_remove_all(file_names, file_extensions)

        file_extensions <-
            stringr::str_remove(file_extensions, "\\.")

        GPL4133 <-
            utils::data("GPL4133") |>
            base::get()

        geo_microarray_df <-
            limma::read.maimages(files = file_names, source = "agilent", path = series_directory, ext = file_extensions, green.only = TRUE, verbose = FALSE) |>
            limma::backgroundCorrect(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            base::as.data.frame() |>
            dplyr::rename(SPOT_ID = .data$ProbeName) |>
            dplyr::inner_join(GPL4133, by = "SPOT_ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL6848") {
        file_names <-
            stringr::str_remove_all(file_names, file_extensions)

        file_extensions <-
            stringr::str_remove(file_extensions, "\\.")

        GPL6848 <-
            utils::data("GPL6848") |>
            base::get()

        geo_microarray_df <-
            limma::read.maimages(files = file_names, source = "agilent", path = series_directory, ext = file_extensions, green.only = TRUE, verbose = FALSE) |>
            limma::backgroundCorrect(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            base::as.data.frame() |>
            dplyr::rename(ID = .data$ProbeName) |>
            dplyr::inner_join(GPL6848, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL5175") {
        if (!base::requireNamespace("pd.huex.1.0.st.v2", quietly = TRUE)) {
            stop("Install the pd.huex.1.0.st.v2 package.", call. = FALSE)
        }

        GPL5175 <-
            utils::data("GPL5175") |>
            base::get()

        geo_microarray_df <-
            oligo::read.celfiles(filenames = file_paths, pkgname = "pd.huex.1.0.st.v2", verbose = FALSE) |>
            oligo::rma(background = FALSE, normalize = FALSE, target = "core") |>
            oligo::exprs() |>
            magrittr::set_colnames(geo_metadata_df$rowname) |>
            limma::backgroundCorrect.matrix(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            tibble::as_tibble(rownames = "ID") |>
            dplyr::inner_join(GPL5175, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL6102") {
        col_specs <-
            readr::cols()

        file_names <-
            stringr::str_remove_all(file_names, file_extensions)

        GPL6102 <-
            utils::data("GPL6102") |>
            base::get()

        geo_microarray_df <-
            purrr::map(file_paths, readr::read_tsv, col_names = FALSE, col_types = col_specs, skip = 1, progress = FALSE) |>
            purrr::map(~ dplyr::rename_with(.x, stringr::str_replace, .cols = tidyselect::starts_with("X1"), ".+", "rowname")) |>
            purrr::map2(file_names, ~ dplyr::rename_with(.x, stringr::str_replace, .cols = tidyselect::contains("X2"), ".+", .y)) |>
            purrr::map(~ dplyr::select(.x, "rowname", tidyselect::any_of(file_names))) |>
            purrr::reduce(dplyr::inner_join, by = "rowname") |>
            dplyr::group_by(.data$rowname) |>
            dplyr::filter(dplyr::n() == 1) |>
            dplyr::ungroup() |>
            tibble::column_to_rownames() |>
            base::data.matrix() |>
            limma::backgroundCorrect.matrix(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            tibble::as_tibble(rownames = "ID") |>
            dplyr::inner_join(GPL6102, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL13497") {
        file_names <-
            stringr::str_remove_all(file_names, file_extensions)

        file_extensions <-
            stringr::str_remove(file_extensions, "\\.")

        GPL13497 <-
            utils::data("GPL13497") |>
            base::get()

        geo_microarray_df <-
            limma::read.maimages(files = file_names, source = "agilent", path = series_directory, ext = file_extensions, green.only = TRUE, verbose = FALSE) |>
            limma::backgroundCorrect(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            base::as.data.frame() |>
            dplyr::rename(ID = .data$ProbeName) |>
            dplyr::inner_join(GPL13497, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL6244") {
        if (!base::requireNamespace("pd.hugene.1.0.st.v1", quietly = TRUE)) {
            stop("Install the pd.hugene.1.0.st.v1 package.", call. = FALSE)
        }

        GPL6244 <-
            utils::data("GPL6244") |>
            base::get()

        geo_microarray_df <-
            oligo::read.celfiles(filenames = file_paths, pkgname = "pd.hugene.1.0.st.v1", verbose = FALSE) |>
            oligo::rma(background = FALSE, normalize = FALSE, target = "core") |>
            oligo::exprs() |>
            magrittr::set_colnames(geo_metadata_df$rowname) |>
            limma::backgroundCorrect.matrix(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            tibble::as_tibble(rownames = "ID") |>
            dplyr::inner_join(GPL6244, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL10558") {
        file_paths_seq <-
            base::seq_along(file_paths)

        for (i in file_paths_seq) {
            file_path <-
                magrittr::extract(file_paths, i)

            gzip_file <-
                base::gzfile(file_path, open = "rb")

            idat_path <-
                stringr::str_remove(file_path, "\\.gz")

            idat_file <-
                base::file(description = idat_path, open = "wb")

            repeat {
                buffer <-
                    base::readBin(gzip_file, "raw", n = 1e8, size = 1)

                if (base::length(buffer) == 0) {
                    break
                }

                base::writeBin(buffer, idat_file, size = 1)
            }

            base::closeAllConnections()

            file_paths <-
                magrittr::inset(file_paths, i, idat_path)
        }

        bgx_file <-
            base::system.file("extdata/HumanHT-12_V4_0_R2_15002873_B.bgx", package = "tuberculosis.pipeline")

        series_directory <-
            stringr::str_c(series_directory, "/")

        file_names <-
            stringr::str_remove_all(file_names, file_extensions)

        GPL10558 <-
            utils::data("GPL10558") |>
            base::get()

        geo_microarray_df <-
            limma::read.idat(file_paths, bgx_file, verbose = FALSE) |>
            limma::backgroundCorrect(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            base::as.data.frame() |>
            dplyr::rename_with(~ stringr::str_replace(.x, "Probe_Id", "ID")) |>
            dplyr::rename_with(~ stringr::str_remove_all(.x, series_directory)) |>
            dplyr::select("ID", tidyselect::any_of(file_names)) |>
            dplyr::inner_join(GPL10558, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL17077") {
        file_names <-
            stringr::str_remove_all(file_names, file_extensions)

        file_extensions <-
            stringr::str_remove(file_extensions, "\\.")

        GPL17077 <-
            utils::data("GPL17077") |>
            base::get()

        geo_microarray_df <-
            limma::read.maimages(files = file_names, source = "agilent", path = series_directory, ext = file_extensions, green.only = TRUE, verbose = FALSE) |>
            limma::backgroundCorrect(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            base::as.data.frame() |>
            dplyr::rename(ID = .data$ProbeName) |>
            dplyr::inner_join(GPL17077, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL15207") {
        PrimeView <-
            utils::data("PrimeView") |>
            base::get()

        GPL15207 <-
            utils::data("GPL15207") |>
            base::get()

        geo_microarray_df <-
            affy::ReadAffy(filenames = file_paths, compress = TRUE, cdfname = "PrimeView") |>
            affy::rma(verbose = FALSE, normalize = FALSE, background = FALSE) |>
            affy::exprs() |>
            magrittr::set_colnames(geo_metadata_df$rowname) |>
            limma::backgroundCorrect.matrix(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            tibble::as_tibble(rownames = "ID") |>
            dplyr::inner_join(GPL15207, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL17586") {
        if (!base::requireNamespace("pd.hta.2.0", quietly = TRUE)) {
            stop("Install the pd.hta.2.0 package.", call. = FALSE)
        }

        GPL17586 <-
            utils::data("GPL17586") |>
            base::get()

        geo_microarray_df <-
            oligo::read.celfiles(filenames = file_paths, pkgname = "pd.hta.2.0", verbose = FALSE) |>
            oligo::rma(background = FALSE, normalize = FALSE, target = "core") |>
            oligo::exprs() |>
            magrittr::set_colnames(geo_metadata_df$rowname) |>
            limma::backgroundCorrect.matrix(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            tibble::as_tibble(rownames = "ID") |>
            dplyr::inner_join(GPL17586, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL17692") {
        if (!base::requireNamespace("pd.hugene.2.1.st", quietly = TRUE)) {
            stop("Install the pd.hugene.2.1.st package.", call. = FALSE)
        }

        GPL17692 <-
            utils::data("GPL17692") |>
            base::get()

        geo_microarray_df <-
            oligo::read.celfiles(filenames = file_paths, pkgname = "pd.hugene.2.1.st", verbose = FALSE) |>
            oligo::rma(background = FALSE, normalize = FALSE, target = "core") |>
            oligo::exprs() |>
            magrittr::set_colnames(geo_metadata_df$rowname) |>
            limma::backgroundCorrect.matrix(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            tibble::as_tibble(rownames = "ID") |>
            dplyr::inner_join(GPL17692, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL23126") {
        if (!base::requireNamespace("pd.clariom.d.human", quietly = TRUE)) {
            stop("Install the pd.clariom.d.human package.", call. = FALSE)
        }

        GPL23126 <-
            utils::data("GPL23126") |>
            base::get()

        geo_microarray_df <-
            oligo::read.celfiles(filenames = file_paths, pkgname = "pd.clariom.d.human", verbose = FALSE) |>
            oligo::rma(background = FALSE, normalize = FALSE, target = "core") |>
            oligo::exprs() |>
            magrittr::set_colnames(geo_metadata_df$rowname) |>
            limma::backgroundCorrect.matrix(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            tibble::as_tibble(rownames = "ID") |>
            dplyr::inner_join(GPL23126, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    if (series_platform == "GPL21185") {
        file_names <-
            stringr::str_remove_all(file_names, file_extensions)

        file_extensions <-
            stringr::str_remove(file_extensions, "\\.")

        GPL21185 <-
            utils::data("GPL21185") |>
            base::get()

        geo_microarray_df <-
            limma::read.maimages(files = file_names, source = "agilent", path = series_directory, ext = file_extensions, green.only = TRUE, verbose = FALSE) |>
            limma::backgroundCorrect(method = "normexp", normexp.method = "saddle", verbose = FALSE) |>
            base::as.data.frame() |>
            dplyr::rename(ID = .data$ProbeName) |>
            dplyr::inner_join(GPL21185, by = "ID") |>
            dplyr::group_by(.data$SYMBOL) |>
            dplyr::slice_sample() |>
            dplyr::ungroup() |>
            dplyr::rename(rowname = .data$SYMBOL) |>
            dplyr::select(.data$rowname, tidyselect::starts_with("GSM"))

        return(geo_microarray_df)
    }

    stop("Platform is not annotated.", call. = FALSE)
}
