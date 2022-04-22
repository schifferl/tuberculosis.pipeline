#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-18

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR15912283 SRR15912284 SRR15912285 SRR15912286 SRR15912287 SRR15912288 SRR15912289 SRR15912290 SRR15912291 SRR15912292 SRR15912293 SRR15912294 SRR15912277 SRR15912278 SRR15912279 SRR15912280 SRR15912281 SRR15912282)
SRRID=${INPUT[$INDEX]}

SERIES_LIBRARY_LAYOUT=(PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED)
SAMPLE_LIBRARY_LAYOUT=${SERIES_LIBRARY_LAYOUT[$INDEX]}

if [[ -e "$SRRID.tsv.gz" ]]; then
  exit
fi

prefetch --output-directory "/scratch/$USER" $SRRID | grep "\S" &> "$SRRID.log"

if [[ -d $SRRID ]]; then
  mv $SRRID/* "/scratch/$USER/$SRRID" && rm -rf $SRRID
fi

(cd "/scratch/$USER" && fasterq-dump --outdir $SRRID --temp $SRRID --threads 16 $SRRID) &>> "$SRRID.log"

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

