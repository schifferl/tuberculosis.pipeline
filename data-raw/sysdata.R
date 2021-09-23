hgnc_symbol_data <-
    httr::GET("http://rest.genenames.org/fetch/status/approved", httr::accept_json()) |>
    httr::content(as = "text", encoding = "UTF-8") |>
    jsonlite::fromJSON() |>
    magrittr::use_series("response") |>
    magrittr::use_series("docs")

symbol2symbol <-
    dplyr::select(hgnc_symbol_data, symbol)

prev_symbol2symbol <-
    dplyr::select(hgnc_symbol_data, prev_symbol, symbol) |>
    tidyr::unnest_longer(prev_symbol) |>
    dplyr::filter(!base::is.na(prev_symbol)) |>
    base::as.data.frame()

alias_symbol2symbol <-
    dplyr::select(hgnc_symbol_data, alias_symbol, symbol) |>
    tidyr::unnest_longer(alias_symbol) |>
    dplyr::filter(!base::is.na(alias_symbol)) |>
    base::as.data.frame()

ensembl_gene_id2symbol <-
    dplyr::select(hgnc_symbol_data, ensembl_gene_id, symbol) |>
    dplyr::filter(!base::is.na(ensembl_gene_id))

entrez_id2symbol <-
    dplyr::select(hgnc_symbol_data, entrez_id, symbol) |>
    dplyr::filter(!base::is.na(entrez_id))

ena2symbol <-
    dplyr::select(hgnc_symbol_data, ena, symbol) |>
    tidyr::unnest_longer(ena) |>
    dplyr::filter(!base::is.na(ena)) |>
    base::as.data.frame()

refseq_accession2symbol <-
    dplyr::select(hgnc_symbol_data, refseq_accession, symbol) |>
    tidyr::unnest_longer(refseq_accession) |>
    dplyr::filter(!base::is.na(refseq_accession)) |>
    base::as.data.frame()

usethis::use_data(symbol2symbol, prev_symbol2symbol, alias_symbol2symbol, ensembl_gene_id2symbol, entrez_id2symbol, ena2symbol, refseq_accession2symbol, internal = TRUE, overwrite = TRUE)
