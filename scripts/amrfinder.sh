#!/bin/sh

source /phe/tools/miniconda3/etc/profile.d/conda.sh

# Activating environment to run AMRFinderPlus
conda activate amrfinder

# make directory to store the output in.
mkdir AMRFinderPlus

## Running amrfinder for each organism

# Burkholderia cepacia complex
awk '(FS="\t") {if($9 ~/Burkholderia cepacia/ || $9 ~/Burkholderia cenocepacia/ || $9 ~/Burkholderia multivorans/ || 
$9 ~/Burkholderia vietnamiensis/ || $9 ~/Burkholderia dolosa/ || $9 ~/Burkholderia ambifaria/ || $9 ~/Burkholderia anthina/ || 
$9 ~/Burkholderia pyrrocinia/ || $9 ~/Burkholderia stabilis/ || $9 ~/Burkholderia ubonensis/ && $1 !~/NEG/) print $1,$9 }' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Burkholderia_cepacia --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

# Campylobacter
awk '(FS="\t") {if($9 ~/Campylobacter/ && $1 !~/NEG/) print $1,$9 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Campylobacter --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

# Cdiff
awk '(FS="\t") {if($9 ~/Clostridioides difficile/ && $1 !~/NEG/) print $1,$9 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Clostridioides_difficile --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

# Escherichia and Shigella spp.
awk '(FS="\t") {if($9 ~/Escherichia/ || $9 ~/Shigella/ && $1 !~/NEG/) print $1,$9 }' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Escherichia --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

# Neisseria gono
awk '(FS="\t") {if($9 ~/Neisseria gonorrhoeae/ && $1 !~/NEG/) print $1,$9 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Neisseria_gonorrhoeae --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

#Neisseria meningitidis
awk '(FS="\t") {if($9 ~/Neisseria meningitidis/ && $1 !~/NEG/) print $1,$9 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Neisseria_meningitidis --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

#Pseudomonas aeruginosa
awk '(FS="\t") {if($9 ~/Pseudomonas aeruginosa/ && $1 !~/NEG/ ) print $1,$9 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Pseudomonas_aeruginosa --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

#Salmonella spp.
awk '(FS="\t") {if($9 ~/Salmonella/ && $1 !~/NEG/ ) print $1,$9 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Salmonella --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

#Staphylococcus aureus
awk '(FS="\t") {if($9 ~/Staphylococcus aureus/ && $1 !~/NEG/ ) print $1,$9 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Staphylococcus_aureus --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

# Streptococcus pneumoniae and S.mitis
awk '(FS="\t") {if($9 ~/Streptococcus pneumoniae/ && $1 !~/NEG/ || $9 ~/Streptococcus mitis/ && $1 !~/NEG/ ) print $1,$9 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Streptococcus_pneumoniae --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

# Streptococcus pyogenes
awk '(FS="\t") {if($9 ~/Streptococcus pyogenes/ && $1 !~/NEG/ ) print $1,$9 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Streptococcus_pyogenes --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

#creating summary file using python script
conda activate phesiqcal 

amr_dir='AMRFinderPlus/'

python /phe/tools/PHET/scripts/amrfinder_summary.py $amr_dir