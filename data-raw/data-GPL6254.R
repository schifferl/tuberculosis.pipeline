GPL6254 <-
    tuberculosis.pipeline:::get_annotation_data("GPL6254") |>
    dplyr::rename_with(snakecase::to_screaming_snake_case)

by_symbol <-
    dplyr::select(GPL6254, ID, GENE_SYMBOL) |>
    dplyr::filter(!base::is.na(GENE_SYMBOL)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_symbol(GENE_SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_symbol, "ID")

by_prev_symbol <-
    dplyr::select(GPL6254, ID, GENE_SYMBOL) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(GENE_SYMBOL)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_prev_symbol(GENE_SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_prev_symbol, "ID") |>
    base::c(remapped_ids)

by_alias_symbol <-
    dplyr::select(GPL6254, ID, GENE_SYMBOL) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(GENE_SYMBOL)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_alias_symbol(GENE_SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_alias_symbol, "ID") |>
    base::c(remapped_ids)

by_ensembl_gene_id <-
    dplyr::select(GPL6254, ID, ENSEMBL_GENE_ID) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    tidyr::separate_rows(ENSEMBL_GENE_ID, sep = ",") |>
    dplyr::filter(!base::is.na(ENSEMBL_GENE_ID)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_ensembl_gene_id(ENSEMBL_GENE_ID)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

GPL6254 <-
    dplyr::bind_rows(by_symbol, by_prev_symbol, by_alias_symbol, by_ensembl_gene_id) |>
    dplyr::add_count(ID) |>
    dplyr::filter(n == 1) |>
    dplyr::select(ID, SYMBOL) |>
    base::as.data.frame()

usethis::use_data(GPL6254, overwrite = TRUE)
