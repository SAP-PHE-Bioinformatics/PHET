#!/bin/sh

# Using the Version file as input so the dirname can be used to obtain path to contig files (whether in phe or scratch)
input=${1?Error:no PHETools version csv file given}

# Directory path of input file
input_dir=$(dirname $input)

# Run ID from the input file
folder=$(awk -F ',' 'FNR == 3 {print $2}' $input)

## getting current date and time for the log file
current_DateTime=$(date +'%d/%m/%Y  %R')
current_Date=$(date +'%d/%m/%Y')
DateToday=$(date +'%Y%m%d')

# Directory paths for contig files required for cgMLST by chewbbaca
contigPath_Senterica=/phe/sequencing_data/input/salmonella/cgMLST/Senterica_contigs
contigPath_Ecoli=/phe/sequencing_data/input/escherichia/cgMLST/Ecoli_contigs
contigPath_Kpneumo=/phe/sequencing_data/input/klebsiella/pneumoniae/cgMLST/Kpneumoniae_contigs


# Printing file headers
logfile=cgMLST_cp_contigs_log.csv

echo "Date,RunID,SeqID,Species,MLST,Path_to_cgMLST_dataset" >> "$DateToday"_"$logfile"

## Senterica - all serovars and STs
awk 'BEGIN { OFS="\t" } (FS="\t") {if($9 == "Salmonella enterica" && $2 >= 1000000 && $15 <= 300) print $1, $9, $25} ' QC_summary.txt |
while IFS=$'\t' read -r seqid spp st; 
do 
    echo -e " $current_Date,$folder,$seqid,$spp,$st,$contigPath_Senterica " >> "$DateToday"_"$logfile"
    cp $input_dir/filtered_contigs/"$seqid".fna $contigPath_Senterica/
done


## Escherichia species - all Serotypes and STs
awk 'BEGIN { OFS="\t" } (FS="\t") {if($9 == "Escherichia coli" && $2 >= 1000000 && $15 <= 300) print $1, $9, $25} ' QC_summary.txt |
while IFS=$'\t' read -r seqid spp st; 
do 
    echo -e " $current_Date,$folder,$seqid,$spp,$st,$contigPath_Ecoli " >> "$DateToday"_"$logfile"
    cp $input_dir/filtered_contigs/"$seqid".fna $contigPath_Ecoli/
done


## Klebsiella penumoniae - all Serotypes and STs
awk 'BEGIN { OFS="\t" } (FS="\t") {if($9 == "Klebsiella pneumoniae" && $2 >= 1000000 && $15 <= 300) print $1, $9, $25} ' QC_summary.txt |
while IFS=$'\t' read -r seqid spp st; 
do 
    echo -e " $current_Date,$folder,$seqid,$spp,$st,$contigPath_Kpneumo " >> "$DateToday"_"$logfile"
    cp $input_dir/filtered_contigs/"$seqid".fna $contigPath_Kpneumo/
done