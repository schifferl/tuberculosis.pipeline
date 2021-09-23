#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-92

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR6914496 SRR6914497 SRR6914498 SRR6914499 SRR6914500 SRR6914501 SRR6914502 SRR6914503 SRR6914504 SRR6914505 SRR6914506 SRR6914507 SRR6914508 SRR6914509 SRR6914510 SRR6914511 SRR6914512 SRR6914513 SRR6914514 SRR6914515 SRR6914516 SRR6914517 SRR6914518 SRR6914519 SRR6914520 SRR6914521 SRR6914522 SRR6914523 SRR6914524 SRR6914525 SRR6914526 SRR6914527 SRR6914528 SRR6914529 SRR6914530 SRR6914531 SRR6914532 SRR6914533 SRR6914534 SRR6914535 SRR6914536 SRR6914537 SRR6914538 SRR6914539 SRR6914540 SRR6914541 SRR6914542 SRR6914543 SRR6914544 SRR6914545 SRR6914546 SRR6914547 SRR6914548 SRR6914549 SRR6914550 SRR6914551 SRR6914552 SRR6914553 SRR6914554 SRR6914555 SRR6914556 SRR6914557 SRR6914558 SRR6914559 SRR6914560 SRR6914561 SRR6914562 SRR6914563 SRR6914564 SRR6914565 SRR6914566 SRR6914567 SRR6914568 SRR6914569 SRR6914570 SRR6914571 SRR6914572 SRR6914573 SRR6914574 SRR6914575 SRR6914576 SRR6914577 SRR6914578 SRR6914579 SRR6914580 SRR6914581 SRR6914582 SRR6914583 SRR6914584 SRR6914585 SRR6914586 SRR6914587)
SRRID=${INPUT[$INDEX]}

SERIES_LIBRARY_LAYOUT=(PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED)
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

