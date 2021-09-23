zip_file <-
    base::tempfile()

utils::download.file("https://support.illumina.com/content/dam/illumina-support/documents/downloads/productfiles/humanht-12/HumanHT-12_V4_0_R2_15002873_B.zip", zip_file)

utils::unzip(zip_file, exdir = "inst/extdata")
