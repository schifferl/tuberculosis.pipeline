#' @keywords internal
#'
#' @importFrom dplyr across
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr pull
#' @importFrom dplyr rename_with
#' @importFrom dplyr select
#' @importFrom purrr map_lgl
#' @importFrom purrr pluck
#' @importFrom stringr str_detect
#' @importFrom stringr str_replace_all
#' @importFrom tibble tibble
#' @importFrom tidyselect any_of
#' @importFrom tidyselect everything
#' @importFrom tidyselect starts_with
#' @importFrom tidyselect vars_select_helpers
tidyup_sample_metadata <- function(geo_metadata_list) {
    geo_metadata_seq <-
        base::seq_along(geo_metadata_list)

    for (i in geo_metadata_seq) {
        geo_metadata_df <-
            purrr::pluck(geo_metadata_list, i)

        series_type <-
            dplyr::select(geo_metadata_df, tidyselect::starts_with("series_type"))

        if (base::ncol(series_type) == 1) {
            series_type <-
                dplyr::pull(series_type, 1)
        } else if (base::ncol(series_type) == base::length(geo_metadata_seq)) {
            series_type <-
                dplyr::pull(series_type, i)
        } else {
            series_type <-
                base::as.character("Series type can not be determined")

            warning("Series type can not be determined.", call. = FALSE)
        }

        microarray <-
            purrr::map_lgl(series_type, stringr::str_detect, "Expression profiling by array") |>
            base::all()

        sequencing <-
            purrr::map_lgl(series_type, stringr::str_detect, "Expression profiling by high throughput sequencing") |>
            base::all()

        if (microarray) {
            col_prefixes <- base::c(
                "sample_geo_accession",
                "sample_platform_id",
                "sample_title",
                "sample_source_name",
                "sample_characteristics",
                "sample_supplementary_file"
            )

            geo_metadata_list[[i]] <-
                dplyr::filter(geo_metadata_df, base::all(base::rowSums(dplyr::across(tidyselect::starts_with("sample_organism"), ~ stringr::str_detect(.x, "Homo sapiens")), na.rm = TRUE) > 0)) |>
                dplyr::filter(!base::any(base::rowSums(dplyr::across(tidyselect::starts_with("sample_characteristics"), ~ stringr::str_detect(.x, "cell line|THP1|THP-1|A549|BEAS-2B")), na.rm = TRUE) > 0)) |>
                dplyr::filter(!base::any(base::rowSums(dplyr::across(tidyselect::starts_with("sample_characteristics"), ~ stringr::str_detect(.x, "death|postmortem")), na.rm = TRUE) > 0)) |>
                dplyr::filter(!base::any(base::rowSums(dplyr::across(tidyselect::starts_with("sample_characteristics"), ~ stringr::str_detect(.x, "recombinant")), na.rm = TRUE) > 0)) |>
                dplyr::filter(dplyr::across(tidyselect::starts_with("sample_type"), ~ stringr::str_detect(.x, "RNA"))) |>
                dplyr::mutate(dplyr::across(tidyselect::starts_with("sample_supplementary_file"), ~ stringr::str_replace_all(.x, "ftp://", "https://"))) |>
                dplyr::mutate(dplyr::across(tidyselect::starts_with("sample_supplementary_file"), ~ stringr::str_replace_all(.x, "CHP.gz", NA_character_))) |>
                dplyr::mutate(dplyr::across(tidyselect::starts_with("sample_supplementary_file"), ~ stringr::str_replace_all(.x, "EXP.gz", NA_character_))) |>
                dplyr::mutate(dplyr::across(tidyselect::starts_with("sample_supplementary_file"), ~ stringr::str_replace_all(.x, "gpr.gz", NA_character_))) |>
                dplyr::mutate(dplyr::across(tidyselect::starts_with("sample_supplementary_file"), ~ stringr::str_replace_all(.x, "xml.gz", NA_character_))) |>
                dplyr::filter(base::rowSums(dplyr::across(tidyselect::starts_with("sample_supplementary_file"), ~ stringr::str_detect(.x, "https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM")), na.rm = TRUE) > 0) |>
                dplyr::select(tidyselect::any_of(tidyselect::starts_with(col_prefixes))) |>
                dplyr::select(tidyselect::vars_select_helpers$where(~ !base::all(base::is.na(.x)))) |>
                dplyr::rename_with(stringr::str_replace_all, .cols = tidyselect::everything(), "sample_geo_accession", "rowname") |>
                dplyr::rename_with(stringr::str_replace_all, .cols = tidyselect::everything(), "sample_platform_id", "Platform Accession")

            next
        }

        if (sequencing) {
            col_prefixes <- base::c(
                "sample_geo_accession",
                "sample_platform_id",
                "sample_title",
                "sample_source_name",
                "sample_characteristics"
            )

            geo_metadata_list[[i]] <-
                dplyr::filter(geo_metadata_df, base::all(base::rowSums(dplyr::across(tidyselect::starts_with("sample_organism"), ~ stringr::str_detect(.x, "Homo sapiens")), na.rm = TRUE) > 0)) |>
                dplyr::filter(!base::any(base::rowSums(dplyr::across(tidyselect::starts_with("sample_characteristics"), ~ stringr::str_detect(.x, "cell line|THP1|THP-1|A549|BEAS-2B")), na.rm = TRUE) > 0)) |>
                dplyr::filter(!base::any(base::rowSums(dplyr::across(tidyselect::starts_with("sample_characteristics"), ~ stringr::str_detect(.x, "death|postmortem")), na.rm = TRUE) > 0)) |>
                dplyr::filter(!base::any(base::rowSums(dplyr::across(tidyselect::starts_with("sample_characteristics"), ~ stringr::str_detect(.x, "recombinant")), na.rm = TRUE) > 0)) |>
                dplyr::filter(dplyr::across(tidyselect::starts_with("sample_library_selection"), ~ stringr::str_detect(.x, "cDNA"))) |>
                dplyr::filter(dplyr::across(tidyselect::starts_with("sample_library_source"), ~ stringr::str_detect(.x, "transcriptomic"))) |>
                dplyr::filter(dplyr::across(tidyselect::starts_with("sample_library_strategy"), ~ stringr::str_detect(.x, "RNA-Seq"))) |>
                dplyr::filter(dplyr::across(tidyselect::starts_with("sample_type"), ~ stringr::str_detect(.x, "SRA"))) |>
                dplyr::select(tidyselect::any_of(tidyselect::starts_with(col_prefixes))) |>
                dplyr::select(tidyselect::vars_select_helpers$where(~ !base::all(base::is.na(.x)))) |>
                dplyr::rename_with(stringr::str_replace_all, .cols = tidyselect::everything(), "sample_geo_accession", "rowname") |>
                dplyr::rename_with(stringr::str_replace_all, .cols = tidyselect::everything(), "sample_platform_id", "Platform Accession")

            next
        }

        geo_metadata_list[[i]] <-
            tibble::tibble()
    }

    geo_metadata_list
}
