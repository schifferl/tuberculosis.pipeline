GPL21185 <-
    tuberculosis.pipeline:::get_annotation_data("GPL21185") |>
    dplyr::rename_with(snakecase::to_screaming_snake_case)

by_symbol <-
    dplyr::select(GPL21185, ID, GENE_SYMBOL) |>
    dplyr::filter(!base::is.na(GENE_SYMBOL)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_symbol(GENE_SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_symbol, "ID")

by_prev_symbol <-
    dplyr::select(GPL21185, ID, GENE_SYMBOL) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(GENE_SYMBOL)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_prev_symbol(GENE_SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_prev_symbol, "ID") |>
    base::c(remapped_ids)

by_alias_symbol <-
    dplyr::select(GPL21185, ID, GENE_SYMBOL) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(GENE_SYMBOL)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_alias_symbol(GENE_SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_alias_symbol, "ID") |>
    base::c(remapped_ids)

by_ensembl_gene_id <-
    dplyr::select(GPL21185, ID, ENSEMBL_ID) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(ENSEMBL_ID)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_ensembl_gene_id(ENSEMBL_ID)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_ensembl_gene_id, "ID") |>
    base::c(remapped_ids)

by_ena <-
    dplyr::select(GPL21185, ID, GB_ACC) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(GB_ACC)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_ena(GB_ACC)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_ena, "ID") |>
    base::c(remapped_ids)

by_refseq_accession <-
    dplyr::select(GPL21185, ID, REFSEQ) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(REFSEQ)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_refseq_accession(REFSEQ)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

GPL21185 <-
    dplyr::bind_rows(by_symbol, by_prev_symbol, by_alias_symbol, by_ensembl_gene_id, by_ena, by_refseq_accession) |>
    dplyr::add_count(ID) |>
    dplyr::filter(n == 1) |>
    dplyr::select(ID, SYMBOL) |>
    base::as.data.frame()

usethis::use_data(GPL21185, overwrite = TRUE)
