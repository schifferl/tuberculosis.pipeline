#' @keywords internal
#'
#' @importFrom furrr future_map
#' @importFrom furrr future_map_chr
#' @importFrom magrittr extract
#' @importFrom magrittr use_series
#' @importFrom stringr str_c
#' @importFrom stringr str_which
map_prev_symbol <- function(prev_symbol) {
    pattern <-
        stringr::str_c("(?i)^", prev_symbol, "$")

    string <-
        magrittr::use_series(prev_symbol2symbol, "prev_symbol")

    value <-
        magrittr::use_series(prev_symbol2symbol, "symbol")

    furrr::future_map(pattern, ~ stringr::str_which(string, .x)) |>
        furrr::future_map(~ magrittr::extract(value, .x)) |>
        furrr::future_map(base::unique) |>
        furrr::future_map_chr(~ base::ifelse(length(.x) == 1, .x, NA_character_))
}
