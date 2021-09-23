zip_file <-
    base::tempfile()

utils::download.file("http://tools.thermofisher.com/content/sfs/supportFiles/hgu133plus2_libraryfile.zip", zip_file)

temp_dir <-
    base::tempdir()

cdf_file <-
    utils::unzip(zip_file, list = TRUE) |>
    magrittr::use_series("Name") |>
    stringr::str_subset("HG-U133_Plus_2.cdf")

cdf_file <-
    utils::unzip(zip_file, files = cdf_file, junkpaths = TRUE, exdir = temp_dir)

cdf_dir <-
    base::dirname(cdf_file)

cdf_file <-
    base::basename(cdf_file)

`HG-U133_Plus_2` <-
    makecdfenv::make.cdf.env(cdf_file, cdf.path = cdf_dir, verbose = FALSE)

usethis::use_data(`HG-U133_Plus_2`, overwrite = TRUE)
