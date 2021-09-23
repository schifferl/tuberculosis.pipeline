tuberculosis.pipeline:::get_sample_metadata("GSE18794") |>
    tuberculosis.pipeline:::tidyup_sample_metadata() |>
    tuberculosis.pipeline:::review_sample_metadata() |>
    purrr::imap(tuberculosis.pipeline:::upload_sample_metadata) |>
    purrr::imap(tuberculosis.pipeline:::get_microarray_data) |>
    purrr::imap(tuberculosis.pipeline:::upload_microarray_data)
