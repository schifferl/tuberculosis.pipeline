#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-85

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR7545442 SRR7545443 SRR7545444 SRR7545445 SRR7545446 SRR7545447 SRR7545448 SRR7545449 SRR7545450 SRR7545451 SRR7545452 SRR7545453 SRR7545454 SRR7545455 SRR7545456 SRR7545457 SRR7545458 SRR7545459 SRR7545460 SRR7545461 SRR7545462 SRR7545463 SRR7545464 SRR7545465 SRR7545466 SRR7545467 SRR7545468 SRR7545469 SRR7545470 SRR7545471 SRR7545472 SRR7545473 SRR7545474 SRR7545475 SRR7545476 SRR7545477 SRR7545478 SRR7545479 SRR7545480 SRR7545481 SRR7545482 SRR7545483 SRR7545484 SRR7545485 SRR7545486 SRR7545487 SRR7545488 SRR7545489 SRR7545490 SRR7545491 SRR7545492 SRR7545493 SRR7545494 SRR7545495 SRR7545496 SRR7545497 SRR7545498 SRR7545499 SRR7545500 SRR7545501 SRR7545502 SRR7545503 SRR7545504 SRR7545505 SRR7545506 SRR7545507 SRR7545508 SRR7545509 SRR7545510 SRR7545511 SRR7545512 SRR7545513 SRR7545514 SRR7545515 SRR7545516 SRR7545517 SRR7545518 SRR7545519 SRR7545520 SRR7545521 SRR7545522 SRR7545523 SRR7545524 SRR7545525 SRR7545526)
SRRID=${INPUT[$INDEX]}

SERIES_LIBRARY_LAYOUT=(SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE)
SAMPLE_LIBRARY_LAYOUT=${SERIES_LIBRARY_LAYOUT[$INDEX]}

if [[ -e "$SRRID.tsv.gz" ]]; then
  exit
fi

prefetch --output-directory "/scratch/$USER" $SRRID | grep "\S" &> "$SRRID.log"
fasterq-dump --outdir "/scratch/$USER/$SRRID" --temp "/scratch/$USER/$SRRID" --threads 16 "/scratch/$USER/$SRRID" &>> "$SRRID.log"

if [[ $SAMPLE_LIBRARY_LAYOUT == "PAIRED" ]]; then
  nextflow run -profile singularity -revision 1.4.2 -work-dir "/scratch/$USER/$SRRID/work" nf-core/rnaseq --reads "/scratch/$USER/$SRRID/*{1,2}.fastq" --genome GRCh38 --skipBiotypeQC --outdir "/scratch/$USER/$SRRID/results" &>> "$SRRID.log"
fi

if [[ $SAMPLE_LIBRARY_LAYOUT == "SINGLE" ]]; then
  nextflow run -profile singularity -revision 1.4.2 -work-dir "/scratch/$USER/$SRRID/work" nf-core/rnaseq --reads "/scratch/$USER/$SRRID/*.fastq" --singleEnd --genome GRCh38 --skipBiotypeQC --outdir "/scratch/$USER/$SRRID/results" &>> "$SRRID.log"
fi

if [[ -n $(grep -l "Succeeded   : 13" "$SRRID.log") ]]; then
  gzip --stdout "/scratch/$USER/$SRRID/results/featureCounts/merged_gene_counts.txt" > "$SRRID.tsv.gz"
fi

rm -rf "/scratch/$USER/$SRRID"

