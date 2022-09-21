#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-231

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR17661631 SRR17661630 SRR17661629 SRR17661628 SRR17661627 SRR17661626 SRR17661625 SRR17661624 SRR17661623 SRR17661622 SRR17661621 SRR17661620 SRR17661619 SRR17661618 SRR17661617 SRR17661616 SRR17661615 SRR17661614 SRR17661613 SRR17661612 SRR17661611 SRR17661610 SRR17661609 SRR17661608 SRR17661579 SRR17661578 SRR17661577 SRR17661576 SRR17661575 SRR17661574 SRR17661573 SRR17661572 SRR17661571 SRR17661570 SRR17661569 SRR17661568 SRR17661567 SRR17661566 SRR17661565 SRR17661564 SRR17661563 SRR17661562 SRR17661561 SRR17661560 SRR17661559 SRR17661558 SRR17661557 SRR17661556 SRR17661607 SRR17661606 SRR17661604 SRR17661603 SRR17661602 SRR17661601 SRR17661600 SRR17661599 SRR17661598 SRR17661597 SRR17661596 SRR17661595 SRR17661594 SRR17661593 SRR17661592 SRR17661591 SRR17661590 SRR17661589 SRR17661588 SRR17661587 SRR17661586 SRR17661585 SRR17661584 SRR17661531 SRR17661530 SRR17661529 SRR17661528 SRR17661527 SRR17661526 SRR17661525 SRR17661524 SRR17661523 SRR17661522 SRR17661521 SRR17661520 SRR17661519 SRR17661518 SRR17661517 SRR17661516 SRR17661515 SRR17661514 SRR17661513 SRR17661512 SRR17661511 SRR17661510 SRR17661509 SRR17661508 SRR17661507 SRR17661506 SRR17661505 SRR17661503 SRR17661502 SRR17661501 SRR17661500 SRR17661499 SRR17661498 SRR17661497 SRR17661496 SRR17661494 SRR17661493 SRR17661492 SRR17661491 SRR17661490 SRR17661489 SRR17661488 SRR17661487 SRR17661486 SRR17661485 SRR17661484 SRR17661555 SRR17661554 SRR17661553 SRR17661552 SRR17661550 SRR17661549 SRR17661548 SRR17661547 SRR17661546 SRR17661545 SRR17661544 SRR17661543 SRR17661542 SRR17661541 SRR17661540 SRR17661539 SRR17661538 SRR17661537 SRR17661536 SRR17661535 SRR17661534 SRR17661533 SRR17661532 SRR17661583 SRR17661582 SRR17661581 SRR17661580 SRR19664245 SRR19664244 SRR19664243 SRR19664242 SRR19664241 SRR19664240 SRR19664239 SRR19664238 SRR19664237 SRR19664236 SRR19664235 SRR19664234 SRR19664233 SRR19664232 SRR19664231 SRR19664230 SRR19664229 SRR19664228 SRR19664227 SRR19664226 SRR19664225 SRR19664224 SRR19664223 SRR19664222 SRR19664221 SRR19664220 SRR19664219 SRR19664218 SRR19664217 SRR19664216 SRR19664215 SRR19664214 SRR19664213 SRR19664212 SRR19664211 SRR19664210 SRR19664209 SRR19664208 SRR19664207 SRR19664206 SRR19664205 SRR19664204 SRR19664203 SRR19664202 SRR19664201 SRR19664200 SRR19664199 SRR19664198 SRR19664197 SRR19664196 SRR19664195 SRR19664194 SRR19664193 SRR19664192 SRR19664191 SRR19664190 SRR19664189 SRR19664188 SRR19664187 SRR19664186 SRR19664185 SRR19664184 SRR19664183 SRR19664182 SRR19664181 SRR19664180 SRR19664179 SRR19664178 SRR19664177 SRR19664176 SRR19664175 SRR19664174 SRR19664173 SRR19664172 SRR19664171 SRR19664170 SRR19664169 SRR19664168 SRR19664167 SRR19664166 SRR19664165 SRR19664164 SRR19664163 SRR19664162 SRR19664161 SRR19664160 SRR19664159)
SRRID=${INPUT[$INDEX]}

SERIES_LIBRARY_LAYOUT=(SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE)
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

