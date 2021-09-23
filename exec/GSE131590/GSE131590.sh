#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-138

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR9104714 SRR9104715 SRR9104716 SRR9104717 SRR9104718 SRR9104719 SRR9104720 SRR9104721 SRR9104722 SRR9104723 SRR9104724 SRR9104725 SRR9104726 SRR9104727 SRR9104728 SRR9104729 SRR9104730 SRR9104731 SRR9104732 SRR9104733 SRR9104734 SRR9104735 SRR9104736 SRR9104737 SRR9104738 SRR9104739 SRR9104740 SRR9104741 SRR9104742 SRR9104743 SRR9104744 SRR9104745 SRR9104746 SRR9104747 SRR9104748 SRR9104749 SRR9104750 SRR9104751 SRR9104752 SRR9104753 SRR9104754 SRR9104755 SRR9104756 SRR9104757 SRR9104758 SRR9104759 SRR9104760 SRR9104761 SRR9104762 SRR9104763 SRR9104764 SRR9104765 SRR9104766 SRR9104767 SRR9104768 SRR9104769 SRR9104770 SRR9104771 SRR9104772 SRR9104773 SRR9104774 SRR9104775 SRR9104776 SRR9104777 SRR9104778 SRR9104779 SRR9104780 SRR9104781 SRR9104782 SRR9104783 SRR9104784 SRR9104785 SRR9104786 SRR9104787 SRR9104788 SRR9104789 SRR9104790 SRR9104791 SRR9104792 SRR9104793 SRR9104794 SRR9104795 SRR9104796 SRR9104797 SRR9104798 SRR9104799 SRR9104800 SRR9104801 SRR9104802 SRR9104803 SRR9104804 SRR9104805 SRR9104806 SRR9104807 SRR9104808 SRR9104809 SRR9104810 SRR9104811 SRR9104812 SRR9104813 SRR9104814 SRR9104815 SRR9104816 SRR9104817 SRR9104818 SRR9104819 SRR9104820 SRR9104821 SRR9104822 SRR9104823 SRR9104824 SRR9104825 SRR9104826 SRR9104827 SRR9104828 SRR9104829 SRR9104830 SRR9104831 SRR9104832 SRR9104833 SRR9104834 SRR9104835 SRR9104836 SRR9104837 SRR9104838 SRR9104839 SRR9104840 SRR9104841 SRR9104842 SRR9104843 SRR9104844 SRR9104845 SRR9104846 SRR9104847 SRR9104848 SRR9104849 SRR9104850 SRR9104851)
SRRID=${INPUT[$INDEX]}

SERIES_LIBRARY_LAYOUT=(SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE)
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

