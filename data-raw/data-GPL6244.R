GPL6244 <-
    tuberculosis.pipeline:::get_annotation_data("GPL6244") |>
    dplyr::rename_with(snakecase::to_screaming_snake_case)

by_symbol <-
    dplyr::select(GPL6244, ID, GENE_ASSIGNMENT) |>
    tidyr::separate_rows(GENE_ASSIGNMENT, sep = " /// ") |>
    tidyr::separate(GENE_ASSIGNMENT, base::c(NA, "GENE_ASSIGNMENT", NA, NA, NA), sep = " // ", fill = "right") |>
    dplyr::filter(!base::is.na(GENE_ASSIGNMENT)) |>
    dplyr::distinct(ID, GENE_ASSIGNMENT) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_symbol(GENE_ASSIGNMENT)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_symbol, "ID")

by_prev_symbol <-
    dplyr::select(GPL6244, ID, GENE_ASSIGNMENT) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    tidyr::separate_rows(GENE_ASSIGNMENT, sep = " /// ") |>
    tidyr::separate(GENE_ASSIGNMENT, base::c(NA, "GENE_ASSIGNMENT", NA, NA, NA), sep = " // ", fill = "right") |>
    dplyr::filter(!base::is.na(GENE_ASSIGNMENT)) |>
    dplyr::distinct(ID, GENE_ASSIGNMENT) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_prev_symbol(GENE_ASSIGNMENT)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_prev_symbol, "ID") |>
    base::c(remapped_ids)

by_alias_symbol <-
    dplyr::select(GPL6244, ID, GENE_ASSIGNMENT) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    tidyr::separate_rows(GENE_ASSIGNMENT, sep = " /// ") |>
    tidyr::separate(GENE_ASSIGNMENT, base::c(NA, "GENE_ASSIGNMENT", NA, NA, NA), sep = " // ", fill = "right") |>
    dplyr::filter(!base::is.na(GENE_ASSIGNMENT)) |>
    dplyr::distinct(ID, GENE_ASSIGNMENT) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_alias_symbol(GENE_ASSIGNMENT)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_alias_symbol, "ID") |>
    base::c(remapped_ids)

by_ensembl_gene_id <-
    dplyr::select(GPL6244, ID, MRNA_ASSIGNMENT) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    dplyr::mutate(MRNA_ASSIGNMENT = stringr::str_extract_all(MRNA_ASSIGNMENT, "ENSG[0-9]+")) |>
    tidyr::unnest_longer(MRNA_ASSIGNMENT) |>
    dplyr::filter(!base::is.na(MRNA_ASSIGNMENT)) |>
    dplyr::distinct(ID, MRNA_ASSIGNMENT) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_ensembl_gene_id(MRNA_ASSIGNMENT)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_ensembl_gene_id, "ID") |>
    base::c(remapped_ids)

by_entrez_id <-
    dplyr::select(GPL6244, ID, GENE_ASSIGNMENT) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    tidyr::separate_rows(GENE_ASSIGNMENT, sep = " /// ") |>
    tidyr::separate(GENE_ASSIGNMENT, base::c(NA, NA, NA, NA, "GENE_ASSIGNMENT"), sep = " // ", fill = "right") |>
    dplyr::filter(!base::is.na(GENE_ASSIGNMENT)) |>
    dplyr::distinct(ID, GENE_ASSIGNMENT) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_entrez_id(GENE_ASSIGNMENT)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_entrez_id, "ID") |>
    base::c(remapped_ids)

by_ena <-
    dplyr::select(GPL6244, ID, GB_LIST) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    tidyr::separate_rows(GB_LIST, sep = ",") |>
    dplyr::filter(!base::is.na(GB_LIST)) |>
    dplyr::distinct(ID, GB_LIST) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_ena(GB_LIST)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

remapped_ids <-
    magrittr::use_series(by_ena, "ID") |>
    base::c(remapped_ids)

by_refseq_accession <-
    dplyr::select(GPL6244, ID, GB_LIST) |>
    dplyr::filter(!(ID %in% remapped_ids)) |>
    tidyr::separate_rows(GB_LIST, sep = ",") |>
    dplyr::filter(!base::is.na(GB_LIST)) |>
    dplyr::distinct(ID, GB_LIST) |>
    dplyr::mutate(SYMBOL = tuberculosis.pipeline:::map_refseq_accession(GB_LIST)) |>
    dplyr::filter(!base::is.na(SYMBOL)) |>
    dplyr::select(ID, SYMBOL)

GPL6244 <-
    dplyr::bind_rows(by_symbol, by_prev_symbol, by_alias_symbol, by_ensembl_gene_id, by_entrez_id, by_ena, by_refseq_accession) |>
    dplyr::add_count(ID) |>
    dplyr::filter(n == 1) |>
    dplyr::select(ID, SYMBOL) |>
    base::as.data.frame()

usethis::use_data(GPL6244, overwrite = TRUE)
