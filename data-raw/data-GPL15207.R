GPL15207 <-
    tuberculosis.pipeline:::get_annotation_data("GPL15207") |>
    dplyr::rename_with(snakecase::to_screaming_snake_case)

by_symbol <-
    dplyr::select(GPL15207, ID, GENE_SYMBOL) |>
    tidyr::separate_rows(GENE_SYMBOL, sep = " /// ") |>
    dplyr::filter(GENE_SYMBOL != "---") |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_symbol(GENE_SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_symbol, "ID")

by_prev_symbol <-
    dplyr::select(GPL15207, ID, GENE_SYMBOL) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    tidyr::separate_rows(GENE_SYMBOL, sep = " /// ") |>
    dplyr::filter(GENE_SYMBOL != "---") |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_prev_symbol(GENE_SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_prev_symbol, "ID") |>
    base::c(remapped_ids)

by_alias_symbol <-
    dplyr::select(GPL15207, ID, GENE_SYMBOL) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    tidyr::separate_rows(GENE_SYMBOL, sep = " /// ") |>
    dplyr::filter(GENE_SYMBOL != "---") |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_alias_symbol(GENE_SYMBOL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_alias_symbol, "ID") |>
    base::c(remapped_ids)

by_ensembl_gene_id <-
    dplyr::select(GPL15207, ID, ENSEMBL) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    tidyr::separate_rows(ENSEMBL, sep = " /// ") |>
    dplyr::filter(ENSEMBL != "---") |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_ensembl_gene_id(ENSEMBL)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_ensembl_gene_id, "ID") |>
    base::c(remapped_ids)

by_entrez_id <-
    dplyr::select(GPL15207, ID, ENTREZ_GENE) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    tidyr::separate_rows(ENTREZ_GENE, sep = " /// ") |>
    dplyr::filter(ENTREZ_GENE != "---") |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_entrez_id(ENTREZ_GENE)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_entrez_id, "ID") |>
    base::c(remapped_ids)

by_ena <-
    dplyr::select(GPL15207, ID, GB_ACC) |>
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
    dplyr::select(GPL15207, ID, GB_ACC) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    dplyr::mutate(GB_ACC = stringr::str_remove_all(GB_ACC, "\\.[0-9]+$")) |>
    dplyr::filter(!base::is.na(GB_ACC)) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_refseq_accession(GB_ACC)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

GPL15207 <-
    dplyr::bind_rows(by_symbol, by_prev_symbol, by_alias_symbol, by_ensembl_gene_id, by_entrez_id, by_ena, by_refseq_accession) |>
    dplyr::add_count(ID) |>
    dplyr::filter(n == 1) |>
    dplyr::select(ID, SYMBOL) |>
    base::as.data.frame()

usethis::use_data(GPL15207, overwrite = TRUE)
