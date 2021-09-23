#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-44

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR5935074 SRR5935076 SRR5935078 SRR5935080 SRR5935082 SRR5935084 SRR5935086 SRR5935088 SRR5935090 SRR5935092 SRR5935093 SRR5935094 SRR5935095 SRR5935096 SRR5935097 SRR5935098 SRR5935099 SRR5935100 SRR5935101 SRR5935102 SRR5935103 SRR5935104 SRR5935105 SRR5935106 SRR5935107 SRR5935108 SRR5935109 SRR5935110 SRR5935111 SRR5935112 SRR5935113 SRR5935114 SRR5935115 SRR5935116 SRR5935117 SRR5935118 SRR5935119 SRR5935120 SRR5935121 SRR5935122 SRR5935123 SRR5935124 SRR5935125 SRR5935126)
SRRID=${INPUT[$INDEX]}

SERIES_LIBRARY_LAYOUT=(PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED)
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

