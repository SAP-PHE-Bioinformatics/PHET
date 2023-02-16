#!/bin/sh

source /phe/tools/miniconda3/etc/profile.d/conda.sh

# Activating environment to run AMRFinderPlus
conda activate amrfinder

# make directory to store the output in.
mkdir AMRFinderPlus

## Running amrfinder for each organism

# Burkholderia cepacia complex
awk '(FS="\t") {if($10 ~/Burkholderia cepacia/ || $10 ~/Burkholderia cenocepacia/ || $10 ~/Burkholderia multivorans/ || 
$10 ~/Burkholderia vietnamiensis/ || $10 ~/Burkholderia dolosa/ || $10 ~/Burkholderia ambifaria/ || $10 ~/Burkholderia anthina/ || 
$10 ~/Burkholderia pyrrocinia/ || $10 ~/Burkholderia stabilis/ || $10 ~/Burkholderia ubonensis/ ) print $1,$10 }' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Burkholderia_cepacia --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

# Campylobacter
awk '(FS="\t") {if($10 ~/Campylobacter/ ) print $1,$10 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Campylobacter --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

# Cdiff
awk '(FS="\t") {if($10 ~/Clostridioides difficile/) print $1,$10 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Clostridioides_difficile --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

# Escherichia and Shigella spp.
awk '(FS="\t") {if($10 ~/Escherichia/ || $10 ~/Shigella/) print $1,$10 }' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Escherichia --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

# Neisseria gono
awk '(FS="\t") {if($10 ~/Neisseria gonorrhoeae/ ) print $1,$10 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Neisseria_gonorrhoeae --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

#Neisseria meningitidis
awk '(FS="\t") {if($10 ~/Neisseria meningitidis/ ) print $1,$10 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Neisseria_meningitidis --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

#Pseudomonas aeruginosa
awk '(FS="\t") {if($10 ~/Pseudomonas aeruginosa/ ) print $1,$10 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Pseudomonas_aeruginosa --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

#Salmonella spp.
awk '(FS="\t") {if($10 ~/Salmonella/ ) print $1,$10 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Salmonella --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

#Staphylococcus aureus
awk '(FS="\t") {if($10 ~/Staphylococcus aureus/ ) print $1,$10 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Staphylococcus_aureus --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

# Streptococcus pneumoniae and S.mitis
awk '(FS="\t") {if($10 ~/Streptococcus pneumoniae/ || $10 ~/Streptococcus mitis/ ) print $1,$10 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Streptococcus_pneumoniae --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done

# Streptococcus pyogenes
awk '(FS="\t") {if($10 ~/Streptococcus pyogenes/ ) print $1,$10 } ' QC_summary.txt |
while read -r sample species; do amrfinder -n filtered_contigs/"$sample".fna -O Streptococcus_pyogenes --output AMRFinderPlus/"$sample"_amrfinder.tsv --name "$sample"_"$species" --threads 8 --log amrfinder_log.txt; done
