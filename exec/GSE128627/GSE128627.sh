#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-62

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR8758000 SRR8758001 SRR8758002 SRR8758003 SRR8758004 SRR8758005 SRR8758006 SRR8758007 SRR8758008 SRR8758009 SRR8758010 SRR8758011 SRR8758012 SRR8758013 SRR8758014 SRR8758015 SRR8758016 SRR8758017 SRR8758018 SRR8758019 SRR8758020 SRR8758021 SRR8758022 SRR8758023 SRR8758024 SRR8758025 SRR8758026 SRR8758027 SRR8758028 SRR8758029 SRR8758030 SRR8758031 SRR8758032 SRR8758033 SRR8758034 SRR8758035 SRR8758036 SRR8758037 SRR8758038 SRR8758039 SRR8758040 SRR8758041 SRR8758042 SRR8758043 SRR8758044 SRR8758045 SRR8758046 SRR8758047 SRR8758048 SRR8758049 SRR8758050 SRR8758051 SRR8758052 SRR8758053 SRR8758054 SRR8758055 SRR8758056 SRR8758057 SRR8758058 SRR8758059 SRR8758060 SRR8758061)
SRRID=${INPUT[$INDEX]}

SERIES_LIBRARY_LAYOUT=(SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE)
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

