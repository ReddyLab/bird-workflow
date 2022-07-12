#!/bin/bash

bird.py \
BIRD-1.1 \
1.25 \
count_files/sczps_merged_counts_for_bird_no_header.txt \
stan_files/${NAME}_stan_${NUMBER}.txt \
1000 \
${RANGE} > BIRD_outputs/outputs/sczps_no_peaks_BIRD_output_${NUMBER}.txt
