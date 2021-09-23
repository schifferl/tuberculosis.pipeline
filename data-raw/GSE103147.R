tuberculosis.pipeline:::get_sample_metadata("GSE103147") |>
    tuberculosis.pipeline:::tidyup_sample_metadata() |>
    tuberculosis.pipeline:::review_sample_metadata() |>
    purrr::map(tuberculosis.pipeline:::translate_geo_rownames) |>
    purrr::imap(tuberculosis.pipeline:::upload_sample_metadata) |>
    purrr::imap(tuberculosis.pipeline:::write_sh)
