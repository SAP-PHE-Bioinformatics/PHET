#!/bin/sh

## change directory to the run folder in scratch
cd /scratch/phesiqcal/$folder

## getting current date and time for the log file
current_DateTime=$(date +'%d/%m/%Y  %R')


###PATHWAYS TO THE SYMLINKS FOR EACH PATHOGEN

# #1 Ecoli
input_Ecoli_O157=/phe/sequencing_data/input/ecoli/O157
input_Ecoli_O26=/phe/sequencing_data/input/ecoli/O26

# #2 Klebsiella pneumoniae
input_Kleb_ST29=/phe/sequencing_data/input/klebsiella/pneumoniae/st29
input_Kleb_ST36=/phe/sequencing_data/input/klebsiella/pneumoniae/st36

# #3 Neisseria gonorrhoeae
input_Ngono_7827=/phe/sequencing_data/input/neisseria/gonorrhoeae/ST-7827

# #4 Mycobacterium
input_MABS=/phe/sequencing_data/input/mycobacterium/abscessus
input_MTBC=/phe/sequencing_data/input/mycobacterium/tuberculosis
input_MAIC=/phe/sequencing_data/input/mycobacterium/intracellulare
input_MAVI=/phe/sequencing_data/input/mycobacterium/avium
input_MCHEL=/phe/sequencing_data/input/mycobacterium/chelonae
input_MMUCO=/phe/sequencing_data/input/mycobacterium/mucogenicum

# #5 Salmonella
input_Sentr=/phe/sequencing_data/input/salmonella/enteritidis
input_Styphm=/phe/sequencing_data/input/salmonella/typhimurium
input_Svirch=/phe/sequencing_data/input/salmonella/virchow
input_Smono=/phe/sequencing_data/input/salmonella/monophasic
input_Shessk=/phe/sequencing_data/input/salmonella/hessarek
input_Sbovis=/phe/sequencing_data/input/salmonella/bovismorbificans
input_Ssaint=/phe/sequencing_data/input/salmonella/saintpaul

# #6 Shigella
input_Ssonn=/phe/sequencing_data/input/shigella/sonnei


# waiting for QC_summary.txt and sistr.csv to be created using until loop

until [[ -e /scratch/phesiqcal/$folder/QC_summary.txt ]]
do
   sleep 300
done 


## Filtering for pathogens based on QC criteria, species id and/or MLST, Piping into while loop to create symlinks
## and record into a log file with details of date and time, run ID, sample number, pathogen name and pathway to folders containing symlinks.

## Escherichia coli : MLST 11 (O-Antigen: O157)
awk '(FS="\t") {if($10 == "Escherichia coli" && $2 >= 1000000 && $16 <= 500 && $26 == "11") print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"*_R1_001.fastq.gz $input_Ecoli_O157/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"*_R2_001.fastq.gz $input_Ecoli_O157/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Escherichia coli O157 Fastq files symlinked to > $input_Ecoli_O157" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done 


# Escherichia coli : MLST 21 (O-Antigen: O26)
awk '(FS="\t") {if($10 == "Escherichia coli" && $2 >= 1000000 && $16 <= 500 && $26 == "21") print $1 } ' QC_summary.txt | 
while read line;
do
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Ecoli_O26/"$line"_R1.fastq.gz
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Ecoli_O26/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Escherichia coli O26 Fastq files symlinked to > $input_Ecoli_O26" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
done


## Klebsiella pneumoniae MLST 29
awk '(FS="\t") {if($10 == "Klebsiella pneumoniae" && $2 >= 1000000 && $16 <= 500 && $26 == "29") print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Kleb_ST29/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Kleb_ST29/"$line"_R2.fastq.gz; 
   echo "$current_DateTime -- $folder - "$line" - Klebsiella pneumoniae MLST 29 Fastq files symlinked to > $input_Kleb_ST29" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
done


## Klebsiella pneumoniae MLST 36
awk '(FS="\t") {if($10 == "Klebsiella pneumoniae" && $2 >= 1000000 && $16 <= 500 && $26 == "36") print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Kleb_ST36/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Kleb_ST36/"$line"_R2.fastq.gz;
      echo "$current_DateTime -- $folder - "$line" - Klebsiella pneumoniae MLST 36 Fastq files symlinked to > $input_Kleb_ST36" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
 
done


## Neisseria gonorrhoeae MLST 7827
awk '(FS="\t") {if($10 == "Neisseria gonorrhoeae" && $2 >= 800000 && $16 <= 500 && $26 == "7827") print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Ngono_7827/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Ngono_7827/"$line"_R2.fastq.gz; 
   echo "$current_DateTime -- $folder - "$line" - Neisseria gonorrhoeae 7827 Fastq files symlinked to > $input_Ngono_7827" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
done


### Mycobacterium abscessus
awk '(FS="\t") {if($10 ~/Mycobacteroides abscessus/ && $2 >= 1000000 && $16 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_MABS/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_MABS/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Mycobacterium abscessus Fastq files symlinked to > $input_MABS" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done


### Mycobacterium tuberculosis
awk '(FS="\t") {if($10  ~/Mycobacterium tuberculosis/ && $2 >= 1000000 && $16 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_MTBC/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_MTBC/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Mycobacterium tuberculosis Fastq files symlinked to > $input_MTBC" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done


### Mycobacterium intracellulare 
awk '(FS="\t") {if($10 ~/Mycobacterium intracellulare/ && $2 >= 1000000 && $16 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_MAIC/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_MAIC/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Mycobacterium intracellulare Fastq files symlinked to > $input_MAIC" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
done


### Mycobacterium chimaera
awk '(FS="\t") {if($10 ~/Mycobacterium chimaera/ && $2 >= 1000000 && $16 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_MAIC/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_MAIC/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Mycobacterium chimaera Fastq files symlinked to > $input_MAIC" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
done


### Mycobacterium avium
awk '(FS="\t") {if($10  ~/Mycobacterium avium/ && $2 >= 1000000 && $16 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_MAVI/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_MAVI/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Mycobacterium avium Fastq files symlinked to > $input_MAVI" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done


### Mycobacterium chelonae
awk '(FS="\t") {if($10  ~/Mycobacterium chelonae/ && $2 >= 1000000 && $16 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_MCHEL/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_MCHEL/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Mycobacterium chelonae Fastq files symlinked to > $input_MCHEL" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done


### Mycobacterium mucogenicum 
awk '(FS="\t") {if($10  ~/Mycobacterium mucogenicum/ && $2 >= 1000000 && $16 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_MMUCO/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_MMUCO/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Mycobacterium mucogenicum Fastq files symlinked to > $input_MMUCO" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done


## Shigella sonnei
awk '(FS="\t") {if($10 == "Shigella sonnei" || $12 "Shigella sonnei" && $2 >= 1000000 && $16 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Ssonn/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Ssonn/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Shigella sonnei Fastq files symlinked to > $input_Ssonn" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done




### Waiting for SISTR output files to filter for Salmonella serovars for symlinks


#until [[ -e /scratch/phesiqcal/$folder/sistr.csv ]] ## << original condition, modified below with a timer 10/01/2023 fhiakau
#do
 #  sleep 300
#done 

### Until condition waiting for sistr.csv and a timer for 6 hours if sistr.csv is not created.

# i for counter
i=0
#until condition with counter/timer
until [[ -e /scratch/phesiqcal/$folder/sistr.csv ]]
do
   sleep 300
   if [[ $i -eq 21600 ]]
   then 
      echo "$current_DateTime -- $folder - waited for sistr.csv for 6 hours ($i secs), no sistr.csv found" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
      break
   fi
   ((i++))
done 

(
### Salmonella enteritidis
awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Enteritidis/) print $8}' sistr.csv |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Sentr/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Sentr/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Salmonella enteritidis Fastq files symlinked to > $input_Sentr" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done


### Salmonella typhimurium
awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Typhimurium/) print $8}' sistr.csv |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Styphm/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Styphm/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Salmonella typhimurium Fastq files symlinked to > $input_Styphm" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done


### Salmonella virchow
awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Virchow/) print $8}' sistr.csv |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Svirch/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Svirch/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Salmonella virchow Fastq files symlinked to > $input_Svirch" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done


### Salmonella monophasic
awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Monophasic/) print $8}' sistr.csv |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Smono/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Smono/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Salmonella monophasic Fastq files symlinked to > $input_Smono" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done


### Salmonella hessarek
awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Hessarek/) print $8}' sistr.csv |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Shessk/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Shessk/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Salmonella hessarek Fastq files symlinked to > $input_Shessk" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done


### Salmonella bovismorbificans
awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Bovismorbificans/) print $8}' sistr.csv |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Sbovis/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Sbovis/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Salmonella bovismorbificans Fastq files symlinked to > $input_Sbovis" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done

### Salmonella saintpaul
awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Saintpaul/) print $8}' sistr.csv |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Ssaint/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Ssaint/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Salmonella saintpaul Fastq files symlinked to > $input_Ssaint" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done
)  2>/dev/null