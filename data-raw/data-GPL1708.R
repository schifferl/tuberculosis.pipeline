GPL1708 <-
    tuberculosis.pipeline:::get_annotation_data("GPL1708") |>
    dplyr::rename_with(snakecase::to_screaming_snake_case)

by_symbol <-
    dplyr::select(GPL1708, SPOT_ID, GENE_SYMBOL) |>
    dplyr::filter(!base::is.na(GENE_SYMBOL)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_symbol(GENE_SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(SPOT_ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_symbol, "SPOT_ID")

by_prev_symbol <-
    dplyr::select(GPL1708, SPOT_ID, GENE_SYMBOL) |>
    dplyr::filter(!(SPOT_ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(GENE_SYMBOL)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_prev_symbol(GENE_SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(SPOT_ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_prev_symbol, "SPOT_ID") |>
    base::c(remapped_ids)

by_alias_symbol <-
    dplyr::select(GPL1708, SPOT_ID, GENE_SYMBOL) |>
    dplyr::filter(!(SPOT_ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(GENE_SYMBOL)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_alias_symbol(GENE_SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(SPOT_ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_alias_symbol, "SPOT_ID") |>
    base::c(remapped_ids)

by_ensembl_gene_id <-
    dplyr::select(GPL1708, SPOT_ID, ENSEMBL_ID) |>
    dplyr::filter(!(SPOT_ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(ENSEMBL_ID)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_ensembl_gene_id(ENSEMBL_ID)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(SPOT_ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_ensembl_gene_id, "SPOT_ID") |>
    base::c(remapped_ids)

by_entrez_id <-
    dplyr::select(GPL1708, SPOT_ID, GENE) |>
    dplyr::filter(!(SPOT_ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(GENE)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_entrez_id(GENE)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(SPOT_ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_entrez_id, "SPOT_ID") |>
    base::c(remapped_ids)

by_ena <-
    dplyr::select(GPL1708, SPOT_ID, GB_ACC) |>
    dplyr::filter(!(SPOT_ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(GB_ACC)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_ena(GB_ACC)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(SPOT_ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_ena, "SPOT_ID") |>
    base::c(remapped_ids)

by_refseq_accession <-
    dplyr::select(GPL1708, SPOT_ID, REFSEQ) |>
    dplyr::filter(!(SPOT_ID %in% remapped_ids)) |>
    dplyr::filter(!base::is.na(REFSEQ)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_refseq_accession(REFSEQ)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(SPOT_ID, SYMBOL)

GPL1708 <-
    dplyr::bind_rows(by_symbol, by_prev_symbol, by_alias_symbol, by_ensembl_gene_id, by_entrez_id, by_ena, by_refseq_accession) |>
    dplyr::add_count(SPOT_ID) |>
    dplyr::filter(n == 1) |>
    dplyr::select(SPOT_ID, SYMBOL) |>
    base::as.data.frame()

usethis::use_data(GPL1708, overwrite = TRUE)
