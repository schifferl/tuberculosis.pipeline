#' @keywords internal
#'
#' @importFrom magrittr use_series
#' @importFrom purrr map
#' @importFrom purrr map_chr
#' @importFrom rentrez entrez_search
#' @importFrom rentrez entrez_summary
#' @importFrom stringr str_c
#' @importFrom stringr str_extract
write_sh <- function(geo_metadata_df, geo_series_accession) {
    sra_ids <-
        magrittr::use_series(geo_metadata_df, "rowname") |>
        purrr::map(~ rentrez::entrez_search("sra", .x)) |>
        purrr::map_chr(magrittr::use_series, "id")

    xml_str <-
        purrr::map(sra_ids, ~ rentrez::entrez_summary("sra", id = .x)) |>
        purrr::map(magrittr::use_series, "expxml")

    series_library_layout <-
        stringr::str_extract(xml_str, "PAIRED|SINGLE")

    if (base::anyNA(series_library_layout)) {
        stop("Read type can not be determined.", call. = FALSE)
    }

    base::file.path("exec", geo_series_accession) |>
        base::dir.create(showWarnings = FALSE, recursive = TRUE)

    sh_file <-
        base::file.path("exec", geo_series_accession, geo_series_accession) |>
        stringr::str_c(".sh")

    base::file.create(sh_file)

    base::cat("#!/bin/bash -l", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("#$ -e /dev/null", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("#$ -o /dev/null", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("#$ -P tuberculosis", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("#$ -pe omp 16", file = sh_file, fill = TRUE, append = TRUE)

    magrittr::use_series(geo_metadata_df, "rowname") |>
        base::length() |>
        purrr::map_chr(~ stringr::str_c("#$ -t 1-", .x, collapse = TRUE)) |>
        base::cat(file = sh_file, fill = TRUE, append = TRUE)

    base::cat("", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("module load sratoolkit/2.10.5", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("module load nextflow/19.10.0", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("INDEX=$(($SGE_TASK_ID-1))", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("", file = sh_file, fill = TRUE, append = TRUE)

    magrittr::use_series(geo_metadata_df, "rowname") |>
        stringr::str_c(collapse = " ") |>
        purrr::map_chr(~ stringr::str_c("INPUT=(", .x, ")", collapse = TRUE)) |>
        base::cat(file = sh_file, fill = TRUE, append = TRUE)

    base::cat("SRRID=${INPUT[$INDEX]}", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("", file = sh_file, fill = TRUE, append = TRUE)

    stringr::str_c(series_library_layout, collapse = " ") |>
        purrr::map_chr(~ stringr::str_c("SERIES_LIBRARY_LAYOUT=(", .x, ")", collapse = TRUE)) |>
        base::cat(file = sh_file, fill = TRUE, append = TRUE)

    base::cat("SAMPLE_LIBRARY_LAYOUT=${SERIES_LIBRARY_LAYOUT[$INDEX]}", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("", file = sh_file, fill = TRUE, append = TRUE)
    base::cat('if [[ -e "$SRRID.tsv.gz" ]]; then', file = sh_file, fill = TRUE, append = TRUE)
    base::cat("  exit", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("fi", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("", file = sh_file, fill = TRUE, append = TRUE)
    base::cat('prefetch --output-directory "/scratch/$USER" $SRRID | grep "\\S" &> "$SRRID.log"', file = sh_file, fill = TRUE, append = TRUE)
    base::cat("", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("if [[ -d $SRRID ]]; then", file = sh_file, fill = TRUE, append = TRUE)
    base::cat('  mv $SRRID/* "/scratch/$USER/$SRRID" && rm -rf $SRRID', file = sh_file, fill = TRUE, append = TRUE)
    base::cat("fi", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("", file = sh_file, fill = TRUE, append = TRUE)
    base::cat('(cd "/scratch/$USER" && fasterq-dump --outdir $SRRID --temp $SRRID --threads 16 $SRRID) &>> "$SRRID.log"', file = sh_file, fill = TRUE, append = TRUE)
    base::cat("", file = sh_file, fill = TRUE, append = TRUE)
    base::cat('if [[ $SAMPLE_LIBRARY_LAYOUT == "PAIRED" ]]; then', file = sh_file, fill = TRUE, append = TRUE)
    base::cat('  nextflow run -profile singularity -revision 1.4.2 -work-dir "/scratch/$USER/$SRRID/work" nf-core/rnaseq --reads "/scratch/$USER/$SRRID/*{1,2}.fastq" --genome GRCh38 --skipBiotypeQC --outdir "/scratch/$USER/$SRRID/results" &>> "$SRRID.log"', file = sh_file, fill = TRUE, append = TRUE)
    base::cat("fi", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("", file = sh_file, fill = TRUE, append = TRUE)
    base::cat('if [[ $SAMPLE_LIBRARY_LAYOUT == "SINGLE" ]]; then', file = sh_file, fill = TRUE, append = TRUE)
    base::cat('  nextflow run -profile singularity -revision 1.4.2 -work-dir "/scratch/$USER/$SRRID/work" nf-core/rnaseq --reads "/scratch/$USER/$SRRID/*.fastq" --singleEnd --genome GRCh38 --skipBiotypeQC --outdir "/scratch/$USER/$SRRID/results" &>> "$SRRID.log"', file = sh_file, fill = TRUE, append = TRUE)
    base::cat("fi", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("", file = sh_file, fill = TRUE, append = TRUE)
    base::cat('if [[ -n $(grep -l "Succeeded   : 13" "$SRRID.log") ]]; then', file = sh_file, fill = TRUE, append = TRUE)
    base::cat('  gzip --stdout "/scratch/$USER/$SRRID/results/featureCounts/merged_gene_counts.txt" > "$SRRID.tsv.gz"', file = sh_file, fill = TRUE, append = TRUE)
    base::cat("fi", file = sh_file, fill = TRUE, append = TRUE)
    base::cat("", file = sh_file, fill = TRUE, append = TRUE)
    base::cat('rm -rf "/scratch/$USER/$SRRID"', file = sh_file, fill = TRUE, append = TRUE)
    base::cat("", file = sh_file, fill = TRUE, append = TRUE)

    geo_metadata_df
}
