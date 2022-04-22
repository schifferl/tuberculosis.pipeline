#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-20

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR17223841 SRR17223839 SRR17223837 SRR17223835 SRR17223833 SRR17223831 SRR17223829 SRR17223827 SRR17223825 SRR17223823 SRR17223821 SRR17223819 SRR17223817 SRR17223815 SRR17223813 SRR17223811 SRR17223809 SRR17223807 SRR17223805 SRR17223803)
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

