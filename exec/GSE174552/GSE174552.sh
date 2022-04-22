#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-36

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR14569150 SRR14569151 SRR14569152 SRR14569153 SRR14569154 SRR14569155 SRR14569156 SRR14569157 SRR14569158 SRR14569159 SRR14569160 SRR14569161 SRR14569162 SRR14569163 SRR14569164 SRR14569165 SRR14569166 SRR14569167 SRR14569168 SRR14569169 SRR14569170 SRR14569171 SRR14569172 SRR14569173 SRR14569174 SRR14569175 SRR14569176 SRR14569177 SRR14569178 SRR14569179 SRR14569180 SRR14569181 SRR14569182 SRR14569183 SRR14569184 SRR14569185)
SRRID=${INPUT[$INDEX]}

SERIES_LIBRARY_LAYOUT=(PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED)
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

