#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-96

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR6914400 SRR6914401 SRR6914402 SRR6914403 SRR6914404 SRR6914405 SRR6914406 SRR6914407 SRR6914408 SRR6914409 SRR6914410 SRR6914411 SRR6914412 SRR6914413 SRR6914414 SRR6914415 SRR6914416 SRR6914417 SRR6914418 SRR6914419 SRR6914420 SRR6914421 SRR6914422 SRR6914423 SRR6914424 SRR6914425 SRR6914426 SRR6914427 SRR6914428 SRR6914429 SRR6914430 SRR6914431 SRR6914432 SRR6914433 SRR6914434 SRR6914435 SRR6914436 SRR6914437 SRR6914438 SRR6914439 SRR6914440 SRR6914441 SRR6914442 SRR6914443 SRR6914444 SRR6914445 SRR6914446 SRR6914447 SRR6914448 SRR6914449 SRR6914450 SRR6914451 SRR6914452 SRR6914453 SRR6914454 SRR6914455 SRR6914456 SRR6914457 SRR6914458 SRR6914459 SRR6914460 SRR6914461 SRR6914462 SRR6914463 SRR6914464 SRR6914465 SRR6914466 SRR6914467 SRR6914468 SRR6914469 SRR6914470 SRR6914471 SRR6914472 SRR6914473 SRR6914474 SRR6914475 SRR6914476 SRR6914477 SRR6914478 SRR6914479 SRR6914480 SRR6914481 SRR6914482 SRR6914483 SRR6914484 SRR6914485 SRR6914486 SRR6914487 SRR6914488 SRR6914489 SRR6914490 SRR6914491 SRR6914492 SRR6914493 SRR6914494 SRR6914495)
SRRID=${INPUT[$INDEX]}

SERIES_LIBRARY_LAYOUT=(PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED)
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
