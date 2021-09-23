#' @keywords internal
#'
#' @importFrom stringr str_remove
#' @importFrom stringr str_c
#' @importFrom readr write_csv
write_metadata_csv_file <- function(upload_dir, path = "~/eh-metadata-csv") {
    rda_path <-
        base::dir(path = upload_dir, pattern = "rda")

    Title <-
        base::basename(rda_path) |>
        stringr::str_remove("\\.rda$")

    Description <-
        stringr::str_remove(Title, "^([^A-Z]+\\.)")

    BiocVersion <-
        base::as.character("3.14")

    Genome <-
        base::as.character("GRCh38")

    SourceType <-
        base::as.character("CSV")

    SourceUrl <-
        base::as.character("https://www.ncbi.nlm.nih.gov/geo/")

    SourceVersion <-
        base::as.character(NA_character_)

    Species <-
        base::as.character("Homo sapiens")

    TaxonomyId <-
        base::as.character("9606")

    Coordinate_1_based <-
        base::as.logical(FALSE)

    DataProvider <-
        base::as.character("NCBI")

    Maintainer <-
        base::as.character("Lucas Schiffer schiffer.lucas@gmail.com")

    RDataClass <-
        base::as.character("matrix")

    DispatchClass <-
        base::as.character("Rda")

    dir_name <-
        base::basename(upload_dir)

    RDataPath <-
        stringr::str_c("tuberculosis/", dir_name, "/", rda_path)

    Tags <-
        base::as.character("tuberculosis")

    csv_name <-
        stringr::str_c(dir_name, ".csv")

    csv_path <-
        base::file.path(path, csv_name)

    if (!base::dir.exists(path)) {
        base::dir.create(path)
    }

    base::data.frame(Title, Description, BiocVersion, Genome, SourceType, SourceUrl, SourceVersion, Species, TaxonomyId, Coordinate_1_based, DataProvider, Maintainer, RDataClass, DispatchClass, RDataPath, Tags) |>
        readr::write_csv(csv_path)

    base::invisible(NULL)
}
