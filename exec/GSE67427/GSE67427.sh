#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-156

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR1947489 SRR1947490 SRR1947491 SRR1947492 SRR1947493 SRR1947494 SRR1947495 SRR1947496 SRR1947497 SRR1947498 SRR1947499 SRR1947500 SRR1947501 SRR1947502 SRR1947503 SRR1947504 SRR1947505 SRR1947506 SRR1947507 SRR1947508 SRR1947509 SRR1947510 SRR1947511 SRR1947512 SRR1947513 SRR1947514 SRR1947515 SRR1947516 SRR1947517 SRR1947518 SRR1947519 SRR1947520 SRR1947521 SRR1947522 SRR1947523 SRR1947524 SRR1947525 SRR1947526 SRR1947527 SRR1947528 SRR1947529 SRR1947530 SRR1947531 SRR1947532 SRR1947533 SRR1947534 SRR1947535 SRR1947536 SRR1947537 SRR1947538 SRR1947539 SRR1947540 SRR1947541 SRR1947542 SRR1947543 SRR1947544 SRR1947545 SRR1947546 SRR1947547 SRR1947548 SRR1947549 SRR1947550 SRR1947551 SRR1947552 SRR1947553 SRR1947554 SRR1947555 SRR1947556 SRR1947557 SRR1947558 SRR1947559 SRR1947560 SRR1947561 SRR1947562 SRR1947563 SRR1947564 SRR1947565 SRR1947566 SRR1947567 SRR1947568 SRR1947569 SRR1947570 SRR1947571 SRR1947572 SRR1947573 SRR1947574 SRR1947575 SRR1947576 SRR1947577 SRR1947578 SRR1947579 SRR1947580 SRR1947581 SRR1947582 SRR1947583 SRR1947584 SRR1947585 SRR1947586 SRR1947587 SRR1947588 SRR1947589 SRR1947590 SRR1947591 SRR1947592 SRR1947593 SRR1947594 SRR1947595 SRR1947596 SRR1947597 SRR1947598 SRR1947599 SRR1947600 SRR1947601 SRR1947602 SRR1947603 SRR1947604 SRR1947605 SRR1947606 SRR1947607 SRR1947608 SRR1947609 SRR1947610 SRR1947611 SRR1947612 SRR1947613 SRR1947614 SRR1947615 SRR1947616 SRR1947617 SRR1947618 SRR1947619 SRR1947620 SRR1947621 SRR1947622 SRR1947623 SRR1947624 SRR1947625 SRR1947626 SRR1947627 SRR1947628 SRR1947629 SRR1947630 SRR1947631 SRR1947632 SRR1947633 SRR1947634 SRR1947635 SRR1947636 SRR1947637 SRR1947638 SRR1947639 SRR1947640 SRR1947641 SRR1947642 SRR1947643 SRR1947644)
SRRID=${INPUT[$INDEX]}

SERIES_LIBRARY_LAYOUT=(SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE)
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

