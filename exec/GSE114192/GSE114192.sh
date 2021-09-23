#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-249

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR7134662 SRR7134663 SRR7134664 SRR7134665 SRR7134666 SRR7134667 SRR7134668 SRR7134669 SRR7134670 SRR7134671 SRR7134672 SRR7134673 SRR7134674 SRR7134675 SRR7134676 SRR7134677 SRR7134678 SRR7134679 SRR7134680 SRR7134681 SRR7134682 SRR7134683 SRR7134684 SRR7134685 SRR7134686 SRR7134687 SRR7134688 SRR7134689 SRR7134690 SRR7134691 SRR7134692 SRR7134693 SRR7134694 SRR7134695 SRR7134696 SRR7134697 SRR7134698 SRR7134699 SRR7134700 SRR7134701 SRR7134702 SRR7134703 SRR7134704 SRR7134705 SRR7134706 SRR7134707 SRR7134708 SRR7134709 SRR7134710 SRR7134711 SRR7134712 SRR7134713 SRR7134714 SRR7134715 SRR7134716 SRR7134717 SRR7134718 SRR7134719 SRR7134720 SRR7134721 SRR7134722 SRR7134723 SRR7134724 SRR7134725 SRR7134726 SRR7134727 SRR7134728 SRR7134729 SRR7134730 SRR7134731 SRR7134732 SRR7134733 SRR7134734 SRR7134735 SRR7134736 SRR7134737 SRR7134738 SRR7134739 SRR7134740 SRR7134741 SRR7134742 SRR7134743 SRR7134744 SRR7134745 SRR7134746 SRR7134747 SRR7134748 SRR7134749 SRR7134750 SRR7134751 SRR7134752 SRR7134753 SRR7134754 SRR7134755 SRR7134756 SRR7134757 SRR7134758 SRR7134759 SRR7134760 SRR7134761 SRR7134762 SRR7134763 SRR7134764 SRR7134765 SRR7134766 SRR7134767 SRR7134768 SRR7134769 SRR7134770 SRR7134771 SRR7134772 SRR7134773 SRR7134774 SRR7134775 SRR7134776 SRR7134777 SRR7134778 SRR7134779 SRR7134780 SRR7134781 SRR7134782 SRR7134783 SRR7134784 SRR7134785 SRR7134786 SRR7134787 SRR7134788 SRR7134789 SRR7134790 SRR7134791 SRR7134792 SRR7134793 SRR7134794 SRR7134795 SRR7134796 SRR7134797 SRR7134798 SRR7134799 SRR7134800 SRR7134801 SRR7134802 SRR7134803 SRR7134804 SRR7134805 SRR7134806 SRR7134807 SRR7134808 SRR7134809 SRR7134810 SRR7134811 SRR7134812 SRR7134813 SRR7134814 SRR7134815 SRR7134816 SRR7134817 SRR7134818 SRR7134819 SRR7134820 SRR7134821 SRR7134822 SRR7134823 SRR7134824 SRR7134825 SRR7134826 SRR7134827 SRR7134828 SRR7134829 SRR7134830 SRR7134831 SRR7134832 SRR7134833 SRR7134834 SRR7134835 SRR7134836 SRR7134837 SRR7134838 SRR7134839 SRR7134840 SRR7134841 SRR7134842 SRR7134843 SRR7134844 SRR7134845 SRR7134846 SRR7134847 SRR7134848 SRR7134849 SRR7134850 SRR7134851 SRR7134852 SRR7134853 SRR7134854 SRR7134855 SRR7134856 SRR7134857 SRR7134858 SRR7134859 SRR7134860 SRR7134861 SRR7134862 SRR7134863 SRR7134864 SRR7134865 SRR7134866 SRR7134867 SRR7134868 SRR7134869 SRR7134870 SRR7134871 SRR7134872 SRR7134873 SRR7134874 SRR7134875 SRR7134876 SRR7134877 SRR7134878 SRR7134879 SRR7134880 SRR7134881 SRR7134882 SRR7134883 SRR7134884 SRR7134885 SRR7134886 SRR7134887 SRR7134888 SRR7134889 SRR7134890 SRR7134891 SRR7134892 SRR7134893 SRR7134894 SRR7134895 SRR7134896 SRR7134897 SRR7134898 SRR7134899 SRR7134900 SRR7134901 SRR7134902 SRR7134903 SRR7134904 SRR7134905 SRR7134906 SRR7134907 SRR7134908 SRR7134909 SRR7134910)
SRRID=${INPUT[$INDEX]}

SERIES_LIBRARY_LAYOUT=(SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE)
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
