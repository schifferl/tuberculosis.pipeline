#' @keywords internal
#'
#' @importFrom withr with_dir
#' @importFrom AzureStor storage_endpoint
#' @importFrom AzureStor storage_container
#' @importFrom AzureStor storage_multiupload
upload_expression_data <- function(upload_dir) {
    withr::with_dir(upload_dir, {
        endpoint_url <-
            base::as.character("https://bioconductorhubs.blob.core.windows.net")

        eh_sas_key <-
            base::Sys.getenv(x = "EH_SAS_KEY")

        if (eh_sas_key == "") {
            stop("Set the EH_SAS_KEY environment variable.", call. = FALSE)
        }

        storage_endpoint <-
            AzureStor::storage_endpoint(endpoint_url, sas = eh_sas_key)

        storage_container <-
            AzureStor::storage_container(storage_endpoint, "staginghub")

        src <-
            base::dir(pattern = "rda")

        base_name <-
            base::basename(upload_dir)

        dst <-
            base::paste("tuberculosis", base_name, src, sep = "/")

        AzureStor::storage_multiupload(storage_container, src = src, dest = dst)
    })
}
