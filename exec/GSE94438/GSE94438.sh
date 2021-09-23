#!/bin/bash -l

#$ -e /dev/null
#$ -o /dev/null
#$ -P tuberculosis
#$ -pe omp 16
#$ -t 1-434

module load sratoolkit/2.10.5
module load nextflow/19.10.0

INDEX=$(($SGE_TASK_ID-1))

INPUT=(SRR5225314 SRR5225315 SRR5225316 SRR5225317 SRR5225318 SRR5225319 SRR5225320 SRR5225321 SRR5225322 SRR5225323 SRR5225324 SRR5225325 SRR5225326 SRR5225327 SRR5225328 SRR5225329 SRR5225330 SRR5225331 SRR5225332 SRR5225333 SRR5225334 SRR5225335 SRR5225336 SRR5225337 SRR5225338 SRR5225339 SRR5225340 SRR5225341 SRR5225342 SRR5225343 SRR5225344 SRR5225345 SRR5225346 SRR5225347 SRR5225348 SRR5225349 SRR5225350 SRR5225351 SRR5225352 SRR5225353 SRR5225354 SRR5225355 SRR5225356 SRR5225357 SRR5225358 SRR5225359 SRR5225360 SRR5225361 SRR5225362 SRR5225363 SRR5225364 SRR5225365 SRR5225366 SRR5225367 SRR5225368 SRR5225369 SRR5225370 SRR5225371 SRR5225372 SRR5225373 SRR5225374 SRR5225375 SRR5225376 SRR5225377 SRR5225378 SRR5225379 SRR5225380 SRR5225381 SRR5225382 SRR5225383 SRR5225384 SRR5225385 SRR5225386 SRR5225387 SRR5225388 SRR5225389 SRR5225390 SRR5225391 SRR5225392 SRR5225393 SRR5225394 SRR5225395 SRR5225396 SRR5225397 SRR5225398 SRR5225399 SRR5225400 SRR5225401 SRR5225402 SRR5225403 SRR5225404 SRR5225405 SRR5225406 SRR5225407 SRR5225408 SRR5225409 SRR5225410 SRR5225411 SRR5225412 SRR5225413 SRR5225414 SRR5225415 SRR5225416 SRR5225417 SRR5225418 SRR5225419 SRR5225420 SRR5225421 SRR5225422 SRR5225423 SRR5225424 SRR5225425 SRR5225426 SRR5225427 SRR5225428 SRR5225429 SRR5225430 SRR5225431 SRR5225432 SRR5225433 SRR5225434 SRR5225435 SRR5225436 SRR5225437 SRR5225438 SRR5225439 SRR5225440 SRR5225441 SRR5225442 SRR5225443 SRR5225444 SRR5225445 SRR5225446 SRR5225447 SRR5225448 SRR5225449 SRR5225450 SRR5225451 SRR5225452 SRR5225453 SRR5225454 SRR5225455 SRR5225456 SRR5225457 SRR5225458 SRR5225459 SRR5225460 SRR5225461 SRR5225462 SRR5225463 SRR5225464 SRR5225465 SRR5225466 SRR5225467 SRR5225468 SRR5225469 SRR5225470 SRR5225471 SRR5225472 SRR5225473 SRR5225474 SRR5225475 SRR5225476 SRR5225477 SRR5225478 SRR5225479 SRR5225480 SRR5225481 SRR5225482 SRR5225483 SRR5225484 SRR5225485 SRR5225486 SRR5225487 SRR5225488 SRR5225489 SRR5225490 SRR5225491 SRR5225492 SRR5225493 SRR5225494 SRR5225495 SRR5225496 SRR5225497 SRR5225498 SRR5225499 SRR5225500 SRR5225501 SRR5225502 SRR5225503 SRR5225504 SRR5225505 SRR5225506 SRR5225507 SRR5225508 SRR5225509 SRR5225510 SRR5225511 SRR5225512 SRR5225513 SRR5225514 SRR5225515 SRR5225516 SRR5225517 SRR5225518 SRR5225519 SRR5225520 SRR5225521 SRR5225522 SRR5225523 SRR5225524 SRR5225525 SRR5225526 SRR5225527 SRR5225528 SRR5225529 SRR5225530 SRR5225531 SRR5225532 SRR5225533 SRR5225534 SRR5225535 SRR5225536 SRR5225537 SRR5225538 SRR5225539 SRR5225540 SRR5225541 SRR5225542 SRR5225543 SRR5225544 SRR5225545 SRR5225546 SRR5225547 SRR5225548 SRR5225549 SRR5225550 SRR5225551 SRR5225552 SRR5225553 SRR5225554 SRR5225555 SRR5225556 SRR5225557 SRR5225558 SRR5225559 SRR5225560 SRR5225561 SRR5225562 SRR5225563 SRR5225564 SRR5225565 SRR5225566 SRR5225567 SRR5225568 SRR5225569 SRR5225570 SRR5225571 SRR5225572 SRR5225573 SRR5225574 SRR5225575 SRR5225576 SRR5225577 SRR5225578 SRR5225579 SRR5225580 SRR5225581 SRR5225582 SRR5225583 SRR5225584 SRR5225585 SRR5225586 SRR5225587 SRR5225588 SRR5225589 SRR5225590 SRR5225591 SRR5225592 SRR5225593 SRR5225594 SRR5225595 SRR5225596 SRR5225597 SRR5225598 SRR5225599 SRR5225600 SRR5225601 SRR5225602 SRR5225603 SRR5225604 SRR5225605 SRR5225606 SRR5225607 SRR5225608 SRR5225609 SRR5225610 SRR5225611 SRR5225612 SRR5225613 SRR5225614 SRR5225615 SRR5225616 SRR5225617 SRR5225618 SRR5225619 SRR5225620 SRR5225621 SRR5225622 SRR5225623 SRR5225624 SRR5225625 SRR5225626 SRR5225627 SRR5225628 SRR5225629 SRR5225630 SRR5225631 SRR5225632 SRR5225633 SRR5225634 SRR5225635 SRR5225636 SRR5225637 SRR5225638 SRR5225639 SRR5225640 SRR5225641 SRR5225642 SRR5225643 SRR5225644 SRR5225645 SRR5225646 SRR5225647 SRR5225648 SRR5225649 SRR5225650 SRR5225651 SRR5225652 SRR5225653 SRR5225654 SRR5225655 SRR5225656 SRR5225657 SRR5225658 SRR5225659 SRR5225660 SRR5225661 SRR5225662 SRR5225663 SRR5225664 SRR5225665 SRR5225666 SRR5225667 SRR5225668 SRR5225669 SRR5225670 SRR5225671 SRR5225672 SRR5225673 SRR5225674 SRR5225675 SRR5225676 SRR5225677 SRR5225678 SRR5225679 SRR5225680 SRR5225681 SRR5225682 SRR5225683 SRR5225684 SRR5225685 SRR5225686 SRR5225687 SRR5225688 SRR5225689 SRR5225690 SRR5225691 SRR5225692 SRR5225693 SRR5225694 SRR5225695 SRR5225696 SRR5225697 SRR5225698 SRR5225699 SRR5225700 SRR5225701 SRR5225702 SRR5225703 SRR5225704 SRR5225705 SRR5225706 SRR5225707 SRR5225708 SRR5225709 SRR5225710 SRR5225711 SRR5225712 SRR5225713 SRR5225714 SRR5225715 SRR5225716 SRR5225717 SRR5225718 SRR5225719 SRR5225720 SRR5225721 SRR5225722 SRR5225723 SRR5225724 SRR5225725 SRR5225726 SRR5225727 SRR5225728 SRR5225729 SRR5225730 SRR5225731 SRR5225732 SRR5225733 SRR5225734 SRR5225735 SRR5225736 SRR5225737 SRR5225738 SRR5225739 SRR5225740 SRR5225741 SRR5225742 SRR5225743 SRR5225744 SRR5225745 SRR5225746 SRR5225747)
SRRID=${INPUT[$INDEX]}

SERIES_LIBRARY_LAYOUT=(PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED PAIRED)
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
