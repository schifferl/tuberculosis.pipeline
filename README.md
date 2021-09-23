
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tuberculosis.pipeline

<!-- badges: start -->
<!-- badges: end -->

This is the data processing pipeline for the
[tuberculosis](https://bioconductor.org/packages/tuberculosis/)
R/Bioconductor package; it should be run inside the
[tuberculosis.pipeline](https://hub.docker.com/r/schifferl/tuberculosis.pipeline)
Docker container. The Docker container is available through Docker Hub,
and the
[tuberculosis.pipeline](https://github.com/schifferl/tuberculosis.pipeline)
GitHub repository has a branch,
[docker](https://github.com/schifferl/tuberculosis.pipeline/tree/docker),
which contains the related Dockerfile.

## Developer Notes

Be sure you are in the right place before proceeding; the
[tuberculosis.pipeline](https://github.com/schifferl/tuberculosis.pipeline)
GitHub repository is intended for developers and extremely curious users
of the [tuberculosis](https://bioconductor.org/packages/tuberculosis/)
R/Bioconductor package alone. The functions in the
[tuberculosis.pipeline](https://github.com/schifferl/tuberculosis.pipeline)
R package are not documented and receive only a high-level overview
here. A number of steps in the pipeline upload/download files to/from
Google Drive or read/write files from/to Google Sheets; anyone wishing
to run the pipeline would need connect their own Google Drive and Google
Sheets accounts. When run inside the
[tuberculosis.pipeline](https://hub.docker.com/r/schifferl/tuberculosis.pipeline)
Docker container, the pipeline should be completely reproducible – the
[NOTES.md](NOTES.md) file details all changes beyond standard operation
of the pipeline that are necessary to reproduce data from the
[tuberculosis](https://bioconductor.org/packages/tuberculosis/)
R/Bioconductor package exactly. “Sample Number” in the
[NOTES.md](NOTES.md) file refers to the “Sample Number” column of the
[series-metadata](https://docs.google.com/spreadsheets/d/1iYgng9ZmW95ZhTGLd5pIjTHrWg2wePe5_rDSxgdr9P0/edit?usp=sharing)
Google Sheets file.

## Series Metadata

The
[series-metadata](https://docs.google.com/spreadsheets/d/1iYgng9ZmW95ZhTGLd5pIjTHrWg2wePe5_rDSxgdr9P0/edit?usp=sharing)
Google Sheets file provides information about all
[GEO](https://www.ncbi.nlm.nih.gov/geo/) Series that are or will be made
available through the
[tuberculosis](https://bioconductor.org/packages/tuberculosis/)
R/Bioconductor package. The sheet can be updated with a single function
call as follows.

``` r
tuberculosis.pipeline:::update_series_metadata()
```

This function call will query [GEO](https://www.ncbi.nlm.nih.gov/geo/)
using the following syntax and obtain metadata about each Series. If no
new Series have been published since the
[series-metadata](https://docs.google.com/spreadsheets/d/1iYgng9ZmW95ZhTGLd5pIjTHrWg2wePe5_rDSxgdr9P0/edit?usp=sharing)
Google Sheets file was last updated, the function will give a message as
such.

> “Tuberculosis”\[MeSH Terms\] AND “Homo sapiens”\[Organism\] AND
> “gse”\[Filter\] AND (“Expression profiling by array”\[Filter\] OR
> “Expression profiling by high throughput sequencing”\[Filter\])

Note that the “Sample Number” reported for a Series in the
[series-metadata](https://docs.google.com/spreadsheets/d/1iYgng9ZmW95ZhTGLd5pIjTHrWg2wePe5_rDSxgdr9P0/edit?usp=sharing)
Google Sheets file may be slightly higher than what is available through
the [tuberculosis](https://bioconductor.org/packages/tuberculosis/)
R/Bioconductor package because of filtering that occurs during data
processing.

## Gene Annotation

The gene names used by the pipeline are HGNC-approved GRCh38 gene names
from the [genenames.org](https://www.genenames.org/) REST API. To update
the gene names, the `sysdata.R` file can be sourced as follows; however
this is somewhat discouraged because it necessitates updating microarray
annotation and reprocessing of both microarray and sequencing data.

``` r
source("data-raw/sysdata.R")
```

When gene names have been updated, microarray annotation must also be
updated to reflect the changes. To update probe to gene mappings, there
is a R file for each [GEO](https://www.ncbi.nlm.nih.gov/geo/) Platform
in the `data-raw` directory, all of which can be sourced as follows.

``` r
source("data-raw/data-GPL10558.R")
source("data-raw/data-GPL13497.R")
source("data-raw/data-GPL1352.R")
source("data-raw/data-GPL15207.R")
source("data-raw/data-GPL17077.R")
source("data-raw/data-GPL1708.R")
source("data-raw/data-GPL17586.R")
source("data-raw/data-GPL17692.R")
source("data-raw/data-GPL21185.R")
source("data-raw/data-GPL23126.R")
source("data-raw/data-GPL4133.R")
source("data-raw/data-GPL5175.R")
source("data-raw/data-GPL570.R")
source("data-raw/data-GPL6102.R")
source("data-raw/data-GPL6244.R")
source("data-raw/data-GPL6254.R")
source("data-raw/data-GPL6480.R")
source("data-raw/data-GPL6848.R")
source("data-raw/data-GPL6884.R")
source("data-raw/data-GPL6947.R")
source("data-raw/data-GPL96.R")
source("data-raw/data-HG-U133_Plus_2.R")
source("data-raw/data-HG-U133A.R")
source("data-raw/data-PrimeView.R")
source("data-raw/data-U133_X3P.R")
```

The process of updating probe to gene mappings is computationally
intensive because of the number of regex matches that must be made. To
speed up the process where multiple cores are available, the following
command can be issued to take advantage of parallel processing before
sourcing the microarray annotation files above.

``` r
future::plan(strategy = future::multisession())
```

When gene names and probe to gene mappings have been updated, both
microarray and sequencing data should be reprocessed. If the genome
build has changed, the `write_sh` function should be revised to reflect
the change.

## Microarray Data

Microarray data from each [GEO](https://www.ncbi.nlm.nih.gov/geo/)
Series that is or will be made available through the
[tuberculosis](https://bioconductor.org/packages/tuberculosis/)
R/Bioconductor package has a R file that was used in data processing.
The source of the `data-raw/GSE102459.R` file is shown below for
reference.

``` r
tuberculosis.pipeline:::get_sample_metadata("GSE102459") |>
    tuberculosis.pipeline:::tidyup_sample_metadata() |>
    tuberculosis.pipeline:::review_sample_metadata() |>
    purrr::imap(tuberculosis.pipeline:::upload_sample_metadata) |>
    purrr::imap(tuberculosis.pipeline:::get_microarray_data) |>
    purrr::imap(tuberculosis.pipeline:::upload_microarray_data)
```

First, the `get_sample_metadata` function is used to retrieve sample
metadata from the [GEO](https://www.ncbi.nlm.nih.gov/geo/) Series Matrix
File(s). Then, the `tidyup_sample_metadata` function is used to clean
the sample metadata and filter out samples based on exclusion criteria.
After that, the `review_sample_metadata` function checks that sample
metadata from at least one sample remains for further processing. If so,
the `upload_sample_metadata` function is used to upload the sample
metadata to Google Drive; the function simply returns the same sample
metadata that was uploaded for further use. The `get_microarray_data`
function then uses the sample metadata to download raw per sample
microarray data from [GEO](https://www.ncbi.nlm.nih.gov/geo/)
(e.g. `CEL` files) and constructs a gene expression matrix that is
finally uploaded to Google Drive as a `CSV` file by the
`upload_microarray_data` function.

## Sequencing Data

Sequencing data from each [GEO](https://www.ncbi.nlm.nih.gov/geo/)
Series that is or will be made available through the
[tuberculosis](https://bioconductor.org/packages/tuberculosis/)
R/Bioconductor package has a R file that was used in data processing.
The source of the `data-raw/GSE101705.R` file is shown below for
reference.

``` r
tuberculosis.pipeline:::get_sample_metadata("GSE101705") |>
    tuberculosis.pipeline:::tidyup_sample_metadata() |>
    tuberculosis.pipeline:::review_sample_metadata() |>
    purrr::map(tuberculosis.pipeline:::translate_geo_rownames) |>
    purrr::imap(tuberculosis.pipeline:::upload_sample_metadata) |>
    purrr::imap(tuberculosis.pipeline:::write_sh)
```

Most of the functions are identical to those used to process microarray
data described above, but two other functions are used here. The
`translate_geo_rownames` function is used to translate
[GEO](https://www.ncbi.nlm.nih.gov/geo/) Sample accession numbers to
[SRA](https://www.ncbi.nlm.nih.gov/sra) Run accession numbers because
they are needed to download raw per sample sequencing data (i.e. `fastq`
files). The `write_sh` function writes a shell script to
`exec/GSE101705/GSE101705.sh` which uses `sratoolkit` and `nextflow` to
process `fastq` files into gene expression measurements. On SGE or
SGE-like clusters the script can be submitted with the `qsub` command.

``` sh
qsub GSE101705.sh
```

The shell script will create an array job with one task per sample and
uses the [nf-core/rnaseq](https://nf-co.re/rnaseq/1.4.2) pipeline inside
a Singularity container to process data in a reproducible manner. When
the job has finished, to check that all samples were processed
successfully use `grep -L "Succeeded   : 13" GSE101705/*.log`; no output
indicates success. If there are samples that were not processed
correctly, read the log file and repeat the `qsub` command if necessary
– only the unsuccessful samples will be reprocessed. Then the
`upload_sequencing_data` function is used to construct a gene expression
matrix that is uploaded to Google Drive as a `CSV` file; the `GSE101705`
argument in the following example is the path to the directory where the
shell script was run.

``` r
tuberculosis.pipeline:::upload_sequencing_data("GSE101705")
```

The `upload_sequencing_data` function is also computationally intensive
because of the number of regex matches that must be made. To speed up
the process where multiple cores are available, the following command
can be issued to take advantage of parallel processing before the
function call above.

``` r
future::plan(strategy = future::multisession())
```

Finally, while some of the syntax of the shell script is specific to the
Boston University Shared Computing Cluster, where sequencing data for
the [tuberculosis](https://bioconductor.org/packages/tuberculosis/)
R/Bioconductor package were prepared, only minor modifications would be
required for submission on a different cluster.

## Expression Data

To prepare expression data to be made available through the
[tuberculosis](https://bioconductor.org/packages/tuberculosis/)
R/Bioconductor package, a few additional steps are required. Microarray
and sequencing data that have been uploaded to Google Drive as `CSV`
files must be downloaded and saved as R matrix objects as follows.

``` r
tuberculosis.pipeline:::dowload_expression_data() |>
  tuberculosis.pipeline:::write_expression_matrix() |>
  tuberculosis.pipeline:::write_metadata_csv_file()
```

The `dowload_expression_data` function is used to download expression
data from Google Drive and will create a directory of `CSV` files at
`~/expression-data`. The directory is used by the
`write_expression_matrix` function, which reads in the `CSV` files and
writes R matrix objects to the `~/aws-upload-data` directory. Then, the
`write_metadata_csv_file` function is used to write a `CSV` file
describing the R matrix objects for
[ExperimentHub](https://bioconductor.org/packages/ExperimentHub/) to the
`~/eh-csv-metadata` directory; it will be used by a Bioconductor core
team member to insert records into the
[ExperimentHub](https://bioconductor.org/packages/ExperimentHub/)
database. The R matrix objects should be uploaded to Amazon S3, as
follows, before the records are inserted into the
[ExperimentHub](https://bioconductor.org/packages/ExperimentHub/)
database.

``` sh
aws s3 cp 2021-09-15 s3://annotation-contributor/tuberculosis/2021-09-15 --acl public-read --recursive
```

The command above requires the correct credentials from Bioconductor and
assumes the current working directory to be `~/aws-upload-data`; the
data would also be different depending on the date the pipeline was run.
