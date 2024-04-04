#!/bin/sh

input=${1?Error:no PHETools version csv file given}


dir=$(awk -F ',' 'FNR == 2 {print $2}' $input)

folder=$(awk -F ',' 'FNR == 3 {print $2}' $input)

## change directory to the run folder in scratch
cd /scratch/phesiqcal/$folder

## getting current date and time for the log file
current_DateTime=$(date +'%d/%m/%Y  %R')


source /phe/tools/miniconda3/etc/profile.d/conda.sh

conda activate phesnp

###PATHWAYS TO THE SYMLINKS FOR EACH PATHOGEN

# #1 Ecoli
input_Ecoli_O157=/phe/sequencing_data/input/enterobacteriaceae/STEC/O157
input_Ecoli_O26=/phe/sequencing_data/input/enterobacteriaceae/STEC/O26

# #2 Klebsiella pneumoniae
input_Kleb_ST29=/phe/sequencing_data/input/klebsiella/pneumoniae/st29
input_Kleb_ST36=/phe/sequencing_data/input/klebsiella/pneumoniae/st36

# #3 Neisseria gonorrhoeae
input_Ngono_7827=/phe/sequencing_data/input/neisseria/gonorrhoeae/ST-7827

# #4 Mycobacterium

## M.tuberculosis
input_MTBC=/phe/sequencing_data/input/mycobacterium/tuberculosis
ref_MTBC=/phe/micro/References/Mycobacterium_tuberculosis/Mtuberculosis_H37Rv.fna
scr_dir_MTBC=/scratch/bacterial_pathogens/Mycobacterium/tuberculosis
phe_dir_MTBC=/phe/micro/Mycobacterium/tuberculosis/snippy


## Other Mycobacterium
input_MABS=/phe/sequencing_data/input/mycobacterium/abscessus
input_MAIC=/phe/sequencing_data/input/mycobacterium/intracellulare
input_MAVI=/phe/sequencing_data/input/mycobacterium/avium
input_MCHEL=/phe/sequencing_data/input/mycobacterium/chelonae
input_MMUCO=/phe/sequencing_data/input/mycobacterium/mucogenicum


# #5 Salmonella Enteritidis
input_sen=/phe/sequencing_data/input/salmonella/enteritidis/ST11
ref_sen=/phe/micro/References/Salmonella_enterica/Enteritidis/GCF_000009505.1_ASM950v1_genomic.fna
scr_dir_sen=/scratch/bacterial_pathogens/Salmonella/Enteritidis/ST11
phe_dir_sen=/phe/micro/Salmonella/Enteritidis/ST11/snippy

# #6 Salmonella Saintpaul
input_ssp=/phe/sequencing_data/input/salmonella/saintpaul/ST50
ref_ssp=/phe/micro/References/Salmonella_enterica/Saintpaul/Saintpaul_CFSAN004175.fna
scr_dir_ssp=/scratch/bacterial_pathogens/Salmonella/Saintpaul/ST50
phe_dir_ssp=/phe/micro/Salmonella/SaintPaul/ST50/snippy_CFSAN004175

# #7 Salmonella Hessarek
input_shes=/phe/sequencing_data/input/salmonella/hessarek/ST255
ref_shes=/phe/micro/References/Salmonella_enterica/Hessarek/2107512094C_published_genome.fasta
scr_dir_shes=/scratch/bacterial_pathogens/Salmonella/Hessarek/ST255
phe_dir_shes=/phe/micro/Salmonella/Hessarek/ST255/snippy

# #8 Salmonella Typhimurium
input_stm=/phe/sequencing_data/input/salmonella/typhimurium/ST19
ref_stm=/phe/micro/References/Salmonella_enterica/Typhimurium/STyphimurium_LT2.fna
scr_dir_stm=/scratch/bacterial_pathogens/Salmonella/Typhimurium/ST19
phe_dir_stm=/phe/micro/Salmonella/Typhimurium/ST19/snippy

# #9 Salmonella Virchow
input_svir=/phe/sequencing_data/input/salmonella/virchow

# #10 Salmonella Monophasic
input_smon=/phe/sequencing_data/input/salmonella/monophasic

# #11 Salmonella Bovismorbificans
input_sbov=/phe/sequencing_data/input/salmonella/bovismorbificans

# #12 Shigella sonnei
input_Sson=/phe/sequencing_data/input/shigella/sonnei
ref_Sson=/phe/micro/References/Shigella_sonnei/Ssonnei_Ss046.fna
scr_dir_Sson=/scratch/bacterial_pathogens/Shigella/sonnei
phe_dir_Sson=/phe/micro/Shigella/sonnei/snippy_all

# #13 Shigella flexneri
input_Sflex=/phe/sequencing_data/input/shigella/flexneri/ST245
ref_Sflex=/phe/micro/References/Shigella_flexneri/SF2/GCF_000006925.2_ASM692v2_genomic.fna
scr_dir_Sflex=/scratch/bacterial_pathogens/Shigella/flexneri/ST245
phe_dir_Sflex=/phe/micro/Shigella/flexneri/ST245/snippy


## Filtering for pathogens based on QC criteria, species id and/or MLST, Piping into while loop to create symlinks
## and record into a log file with details of date and time, run ID, sample number, pathogen name and pathway to folders containing symlinks.


## Escherichia coli : MLST 11 (O-Antigen: O157)
awk '(FS="\t") {if($9 == "Escherichia coli" && $2 >= 1000000 && $15 <= 500 && $25 == "11") print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"*_R1_001.fastq.gz $input_Ecoli_O157/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"*_R2_001.fastq.gz $input_Ecoli_O157/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Escherichia coli O157 Fastq files symlinked to > $input_Ecoli_O157" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done 


# Escherichia coli : MLST 21 (O-Antigen: O26)
awk '(FS="\t") {if($9 == "Escherichia coli" && $2 >= 1000000 && $15 <= 500 && $25 == "21") print $1 } ' QC_summary.txt | 
while read line;
do
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Ecoli_O26/"$line"_R1.fastq.gz
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Ecoli_O26/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Escherichia coli O26 Fastq files symlinked to > $input_Ecoli_O26" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
done


## Klebsiella pneumoniae MLST 29
awk '(FS="\t") {if($9 == "Klebsiella pneumoniae" && $2 >= 1000000 && $15 <= 500 && $25 == "29") print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Kleb_ST29/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Kleb_ST29/"$line"_R2.fastq.gz; 
   echo "$current_DateTime -- $folder - "$line" - Klebsiella pneumoniae MLST 29 Fastq files symlinked to > $input_Kleb_ST29" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
done


## Klebsiella pneumoniae MLST 36
awk '(FS="\t") {if($9 == "Klebsiella pneumoniae" && $2 >= 1000000 && $15 <= 500 && $25 == "36") print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Kleb_ST36/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Kleb_ST36/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Klebsiella pneumoniae MLST 36 Fastq files symlinked to > $input_Kleb_ST36" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
 
done


## Neisseria gonorrhoeae MLST 7827
awk '(FS="\t") {if($9 == "Neisseria gonorrhoeae" && $2 >= 800000 && $15 <= 500 && $25 == "7827") print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Ngono_7827/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Ngono_7827/"$line"_R2.fastq.gz; 
   echo "$current_DateTime -- $folder - "$line" - Neisseria gonorrhoeae 7827 Fastq files symlinked to > $input_Ngono_7827" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
done


### Mycobacterium abscessus
awk '(FS="\t") {if($9 ~/abscessus/ && $2 >= 1000000 && $15 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_MABS/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_MABS/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Mycobacterium abscessus Fastq files symlinked to > $input_MABS" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done


### Mycobacterium tuberculosis
# adding to ongoing config
awk '(FS="\t") {if($9  ~/tuberculosis/ && $2 >= 1000000 && $15 <= 500) print "- " $1 } ' QC_summary.txt >> $scr_dir_MTBC/ongoing_MTBC_config.yaml
# symlinking and running snippy
awk '(FS="\t") {if($9  ~/tuberculosis/ && $2 >= 1000000 && $15 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_MTBC/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_MTBC/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Mycobacterium tuberculosis Fastq files symlinked to > $input_MTBC" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
   snippy --cpus 16 --ram 16 --outdir $scr_dir_MTBC/snippy/"$line" --reference $ref_MTBC --R1 $input_MTBC/"$line"_R1.fastq.gz --R2 $input_MTBC/"$line"_R2.fastq.gz
   mv $scr_dir_MTBC/snippy/"$line" $phe_dir_MTBC
   cp -asr $phe_dir_MTBC/"$line" $scr_dir_MTBC/snippy/
done


### Mycobacterium intracellulare 
awk '(FS="\t") {if($9 ~/intracellulare/ && $2 >= 1000000 && $15 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_MAIC/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_MAIC/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Mycobacterium intracellulare Fastq files symlinked to > $input_MAIC" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
done


### Mycobacterium chimaera
awk '(FS="\t") {if($9 ~/chimaera/ && $2 >= 1000000 && $15 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_MAIC/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_MAIC/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Mycobacterium chimaera Fastq files symlinked to > $input_MAIC" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
done


### Mycobacterium avium
awk '(FS="\t") {if($9  ~/avium/ && $2 >= 1000000 && $15 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_MAVI/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_MAVI/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Mycobacterium avium Fastq files symlinked to > $input_MAVI" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done


### Mycobacterium chelonae
awk '(FS="\t") {if($9  ~/chelonae/ && $2 >= 1000000 && $15 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_MCHEL/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_MCHEL/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Mycobacterium chelonae Fastq files symlinked to > $input_MCHEL" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done


### Mycobacterium mucogenicum 
awk '(FS="\t") {if($9  ~/mucogenicum/ && $2 >= 1000000 && $15 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_MMUCO/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_MMUCO/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Mycobacterium mucogenicum Fastq files symlinked to > $input_MMUCO" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
done


## Shigella  #3/4/23 Fixed the filtering bug for Shigella sonnei symlink.
# adding to ongoing config
awk '(FS="\t") {if($9 == "Shigella sonnei" && $2 >= 1000000 && $15 <= 500 || $11 == "Shigella sonnei" && $2 >= 1000000 && $15 <= 500) print "- " $1 } ' QC_summary.txt >> $scr_dir_Sson/ongoing_12mo_sson_config.yaml
#symlinking and running snippy
awk '(FS="\t") {if($9 == "Shigella sonnei" && $2 >= 1000000 && $15 <= 500 || $11 == "Shigella sonnei" && $2 >= 1000000 && $15 <= 500) print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Sson/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Sson/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Shigella sonnei Fastq files symlinked to > $input_Sson" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
   snippy --cpus 16 --ram 16 --outdir $scr_dir_Sson/snippy_all/"$line" --reference $ref_Sson --R1 $input_Sson/"$line"_R1.fastq.gz --R2 $input_Sson/"$line"_R2.fastq.gz
   mv $scr_dir_Sson/snippy_all/"$line" $phe_dir_Sson
   cp -asr $phe_dir_Sson/"$line" $scr_dir_Sson/snippy_all
done


# Shigella flexneri ST245
#adding to ongoing config
awk '(FS="\t") {if($9 == "Shigella flexneri" && $2 >= 1000000 && $15 <= 500 && $25 == "245") print "- " $1 } ' QC_summary.txt >> $scr_dir_Sflex/ongoing_12mo_SFL_config.yaml
#symlinking and running snippy
awk '(FS="\t") {if($9 == "Shigella flexneri" && $2 >= 1000000 && $15 <= 500 && $25 == "245") print $1 } ' QC_summary.txt |
while read line; 
do 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_Sflex/"$line"_R1.fastq.gz 
   ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_Sflex/"$line"_R2.fastq.gz;
   echo "$current_DateTime -- $folder - "$line" - Shigella flexneri Fastq files symlinked to > $input_Sflex" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
   snippy --cpus 16 --ram 16 --outdir $scr_dir_Sflex/snippy/"$line" --reference $ref_Sflex --R1 $input_Sflex/"$line"_R1.fastq.gz --R2 $input_Sflex/"$line"_R2.fastq.gz 
   mv $scr_dir_Sflex/snippy/"$line" $phe_dir_Sflex
   cp -asr $phe_dir_Sflex/"$line" $scr_dir_Sflex/snippy/
done


## Changing the filtering of the Salmonella serovars to also filter for MLST (Ak 15/02/2023)

sistr_file='/scratch/phesiqcal/$folder/PHET/Salmonella/sistr.csv'

if test -f /scratch/phesiqcal/$folder/PHET/Salmonella/sistr.csv; then
	### Salmonella enteritidis MLST 11

	#adding to ongoing snippy config
	awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Enteritidis/) print $8}' /scratch/phesiqcal/$folder/PHET/Salmonella/sistr.csv | 
	while read sample; do awk '(FS="\t") {if($1 ~ '$sample' && $25 == 11) print "- " $1}' /scratch/phesiqcal/$folder/QC_summary.txt ; done >> $scr_dir_sen/ongoing_12mo_SEN_config.yaml
	# symlinking and running snippy
	awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Enteritidis/) print $8}' /scratch/phesiqcal/$folder/PHET/Salmonella/sistr.csv | 
	while read sample; do awk '(FS="\t") {if($1 ~ '$sample' && $25 == 11) print $1}' /scratch/phesiqcal/$folder/QC_summary.txt ; done | 
	while read line; 
	do 
		ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_sen/"$line"_R1.fastq.gz 
		ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_sen/"$line"_R2.fastq.gz;
		echo "$current_DateTime -- $folder - "$line" - Salmonella enteritidis MLST 11 Fastq files symlinked to > $input_sen" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
		snippy --cpus 16 --ram 16 --outdir $scr_dir_sen/snippy/"$line" --reference $ref_sen --R1 $input_sen/"$line"_R1.fastq.gz --R2 $input_sen/"$line"_R2.fastq.gz 
		mv $scr_dir_sen/snippy/"$line" $phe_dir_sen
		cp -asr $phe_dir_sen/"$line" $scr_dir_sen/snippy/
	done

	### Salmonella typhimurium MLST 19
	# add to ongoing config
	awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Typhimurium/) print $8}' /scratch/phesiqcal/$folder/PHET/Salmonella/sistr.csv |
	while read sample; do awk '(FS="\t") {if($1 ~ '$sample' && $25 == 19) print "- " $1}' /scratch/phesiqcal/$folder/QC_summary.txt ; done >> $scr_dir_stm/ongoing_12mo_STM_config.yaml
	## Symlinking and running snippy
	awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Typhimurium/) print $8}' /scratch/phesiqcal/$folder/PHET/Salmonella/sistr.csv |
	while read sample; do awk '(FS="\t") {if($1 ~ '$sample' && $25 == 19) print $1}' /scratch/phesiqcal/$folder/QC_summary.txt ; done |
	while read line; 
	do 
		ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_stm/"$line"_R1.fastq.gz 
		ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_stm/"$line"_R2.fastq.gz;
		echo "$current_DateTime -- $folder - "$line" - Salmonella typhimurium MLST 19 Fastq files symlinked to > $input_stm" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
		snippy --cpus 16 --ram 16 --outdir $scr_dir_stm/snippy/"$line" --reference $ref_stm --R1 $input_stm/"$line"_R1.fastq.gz --R2 $input_stm/"$line"_R2.fastq.gz
		mv $scr_dir_stm/snippy/"$line" $phe_dir_stm
		cp -asr $phe_dir_stm/"$line" $scr_dir_stm/snippy/
	done


	### Salmonella virchow MLST 16
	awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Virchow/) print $8}' /scratch/phesiqcal/$folder/PHET/Salmonella/sistr.csv |
	while read sample; do awk '(FS="\t") {if($1 ~ '$sample' && $25 == 16) print $1}' /scratch/phesiqcal/$folder/QC_summary.txt ; done |
	while read line; 
	do 
		ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_svir/"$line"_R1.fastq.gz 
		ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_svir/"$line"_R2.fastq.gz;
		echo "$current_DateTime -- $folder - "$line" - Salmonella virchow MLST 16 Fastq files symlinked to > $input_svir" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
	done


	### Salmonella monophasic MLST 34
	awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Monophasic/) print $8}' /scratch/phesiqcal/$folder/PHET/Salmonella/sistr.csv |
	while read sample; do awk '(FS="\t") {if($1 ~ '$sample' && $25 == 34) print $1}' /scratch/phesiqcal/$folder/QC_summary.txt ; done |
	while read line; 
	do 
		ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_smon/"$line"_R1.fastq.gz 
		ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_smon/"$line"_R2.fastq.gz;
		echo "$current_DateTime -- $folder - "$line" - Salmonella monophasic MLST 34 Fastq files symlinked to > $input_smon" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
	done

	#4/4/23 Fixed the MLST number to 255
	### Salmonella hessarek MLST 255
	awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Hessarek/) print $8}' /scratch/phesiqcal/$folder/PHET/Salmonella/sistr.csv |
	while read sample; do awk '(FS="\t") {if($1 ~ '$sample' && $25 == 255) print $1}' /scratch/phesiqcal/$folder/QC_summary.txt ; done |
	while read line; 
	do 
		ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_shes/"$line"_R1.fastq.gz 
		ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_shes/"$line"_R2.fastq.gz;
		echo "$current_DateTime -- $folder - "$line" - Salmonella hessarek MLST 255 Fastq files symlinked to > $input_shes" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
		snippy --cpus 16 --ram 16 --outdir $scr_dir_shes/snippy/"$line" --reference $ref_shes --R1 $input_shes/"$line"_R1.fastq.gz --R2 $input_shes/"$line"_R2.fastq.gz
		mv $scr_dir_shes/snippy/"$line" $phe_dir_shes
		cp -asr $phe_dir_shes/"$line" $scr_dir_shes/snippy/
	done

	### Salmonella bovismorbificans (all MLST)
	awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Bovismorbificans/) print $8}' /scratch/phesiqcal/$folder/PHET/Salmonella/sistr.csv |
	while read line; 
	do 
		ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_sbov/"$line"_R1.fastq.gz 
		ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_sbov/"$line"_R2.fastq.gz;
		echo "$current_DateTime -- $folder - "$line" - Salmonella bovismorbificans Fastq files symlinked to > $input_sbov" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
	done

	### Salmonella saintpaul MLST 50
	# add to config 
	awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Saintpaul/) print $8}' /scratch/phesiqcal/$folder/PHET/Salmonella/sistr.csv |
	while read sample; do awk '(FS="\t") {if($1 ~ '$sample' && $25 == 50) print "- " $1}' /scratch/phesiqcal/$folder/QC_summary.txt ; done >> $scr_dir_ssp/ongoing_12mo_ssp_config.yaml

	#Create symlink and run snippy
	awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{IGNORECASE=1; if($15 ~/Saintpaul/) print $8}' /scratch/phesiqcal/$folder/PHET/Salmonella/sistr.csv |
	while read sample; do awk '(FS="\t") {if($1 ~ '$sample' && $25 == 50) print $1}' /scratch/phesiqcal/$folder/QC_summary.txt ; done |
	while read line; 
	do 
		ln -fs $dir/BaseCalls/$folder/"$line"_*R1_001.fastq.gz $input_ssp/"$line"_R1.fastq.gz 
		ln -fs $dir/BaseCalls/$folder/"$line"_*R2_001.fastq.gz $input_ssp/"$line"_R2.fastq.gz;
		echo "$current_DateTime -- $folder - "$line" - Salmonella saintpaul MLST 50 Fastq files symlinked to > $input_ssp" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt 
		snippy --cpus 16 --ram 16 --outdir $scr_dir_ssp/snippy/"$line" --reference $ref_ssp --R1 $input_ssp/"$line"_R1.fastq.gz --R2 $input_ssp/"$line"_R2.fastq.gz
		mv $scr_dir_ssp/snippy/"$line" $phe_dir_ssp
		cp -asr $phe_dir_ssp/"$line" $scr_dir_ssp/snippy/;
	done
else
# elif [! -f $sistr_file]; then
    echo "no sistr.csv found" >> /scratch/phesiqcal/$folder/Symlinks_logs_$folder.txt
fi
