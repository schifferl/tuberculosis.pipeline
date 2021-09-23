GPL10558 <-
    tuberculosis.pipeline:::get_annotation_data("GPL10558") |>
    dplyr::rename_with(snakecase::to_screaming_snake_case)

by_symbol <-
    dplyr::select(GPL10558, ID, SYMBOL) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_symbol(SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_symbol, "ID")

by_prev_symbol <-
    dplyr::select(GPL10558, ID, SYMBOL) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_prev_symbol(SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_prev_symbol, "ID") |>
    base::c(remapped_ids)

by_alias_symbol <-
    dplyr::select(GPL10558, ID, SYMBOL) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_alias_symbol(SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_alias_symbol, "ID") |>
    base::c(remapped_ids)

by_entrez_id <-
    dplyr::select(GPL10558, ID, ENTREZ_GENE_ID) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(ENTREZ_GENE_ID)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_entrez_id(ENTREZ_GENE_ID)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_entrez_id, "ID") |>
    base::c(remapped_ids)

by_ena <-
    dplyr::select(GPL10558, ID, GB_ACC) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    dplyr::mutate(GB_ACC = stringr::str_remove_all(GB_ACC, "\\.[0-9]+$")) |>
    dplyr::filter(!base::is.na(GB_ACC)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_ena(GB_ACC)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_ena, "ID") |>
    base::c(remapped_ids)

by_refseq_accession <-
    dplyr::select(GPL10558, ID, GB_ACC) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    dplyr::mutate(GB_ACC = stringr::str_remove_all(GB_ACC, "\\.[0-9]+$")) |>
    dplyr::filter(!base::is.na(GB_ACC)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_refseq_accession(GB_ACC)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

GPL10558 <-
    dplyr::bind_rows(by_symbol, by_prev_symbol, by_alias_symbol, by_entrez_id, by_ena, by_refseq_accession) |>
    dplyr::add_count(ID) |>
    dplyr::filter(n == 1) |>
    dplyr::select(ID, SYMBOL) |>
    base::as.data.frame()

usethis::use_data(GPL10558, overwrite = TRUE)
