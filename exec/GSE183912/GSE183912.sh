#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-20

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR15841182 SRR15841183 SRR15841184 SRR15841185 SRR15841187 SRR15841188 SRR15841189 SRR15841190 SRR15841192 SRR15841193 SRR15841194 SRR15841195 SRR15841197 SRR15841198 SRR15841199 SRR15841200 SRR15841201 SRR15841203 SRR15841204 SRR15841205)
SRRID=${INPUT[$INDEX]}

SERIES_LIBRARY_LAYOUT=(SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE)
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

