#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-94

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR13202310 SRR13202312 SRR13202314 SRR13202316 SRR13202318 SRR13202320 SRR13202322 SRR13202324 SRR13202326 SRR13202328 SRR13202330 SRR13202332 SRR13202334 SRR13202336 SRR13202338 SRR13202340 SRR13202342 SRR13202344 SRR13202346 SRR13202348 SRR13202350 SRR13202352 SRR13202354 SRR13202356 SRR13202358 SRR13202360 SRR13202362 SRR13202364 SRR13202366 SRR13202368 SRR13202370 SRR13202372 SRR13202374 SRR13202376 SRR13202378 SRR13202380 SRR13202382 SRR13202384 SRR13202386 SRR13202388 SRR13202390 SRR13202392 SRR13202394 SRR13202396 SRR13202398 SRR13202400 SRR13202402 SRR13202404 SRR13202406 SRR13202408 SRR13202410 SRR13202412 SRR13202414 SRR13202416 SRR13202418 SRR13202420 SRR13202422 SRR13202424 SRR13202426 SRR13202428 SRR13202430 SRR13202432 SRR13202434 SRR13202436 SRR13202438 SRR13202440 SRR13202442 SRR13202444 SRR13202446 SRR13202448 SRR13202450 SRR13202452 SRR13202454 SRR13202456 SRR13202458 SRR13202460 SRR13202462 SRR13202464 SRR13202466 SRR13202468 SRR13202470 SRR13202472 SRR13202474 SRR13202476 SRR13202478 SRR13202480 SRR13202482 SRR13202484 SRR13202486 SRR13202488 SRR13202490 SRR13202492 SRR13202494 SRR13202496)
SRRID=${INPUT[$INDEX]}

SERIES_LIBRARY_LAYOUT=(PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED)
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

