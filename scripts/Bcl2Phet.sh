#!/bin/sh

input=${1?Error:no SampleSheet.csv given}

dir=$( dirname $input)

### Load module

source /phe/tools/miniconda3/etc/profile.d/conda.sh

conda activate phesiqcal

### Running bcl2fastq

BCL=$(sbatch --job-name bcl2fastq --mem 100G --ntasks 32 --time 960:00:00 -D /phe/tools/phesiqcal/log/ --wrap "bcl2fastq --sample-sheet $input --runfolder-dir $dir --no-lane-splitting --ignore-missing-bcls --ignore-missing-filter --ignore-missing-positions --output-dir $dir/BaseCalls")

### Create folder
folder=$(awk -F ',' 'FNR == 4 {print $2}' $input)

mkdir -p /scratch/phesiqcal/$folder

cd /scratch/phesiqcal/$folder

### Creating config file

#awk -F ',' 'BEGIN{ print "samples:"}; FNR > 21 {if($0 !~/NEG/ && $0 !~/Metagenomic/ && $0 !~/FUNGAL/) print "- " $2|"sort -u"}' $input > config.yaml
#awk -F ',' 'BEGIN{ print "negative:"}; ( $0 ~/NEG/ ){print "- " $2 }' $input >> config.yaml

awk -F ',' 'BEGIN{ print "samples:"}; {IGNORECASE=1}; FNR > 21 {if($0 !~/NEG/ && $0 !~/Metagenomic/ && $0 !~/FUNGAL/) print "- " $2|"sort -u"}' $input > config.yaml
awk -F ',' 'BEGIN{ print "negative:"}; {IGNORECASE=1}; ( $0 ~/NEG/ ){print "- " $2 }' $input >> config.yaml

### Create input folder

mkdir -p /scratch/phesiqcal/$folder/input

cd /scratch/phesiqcal/$folder/input

### Pausing following jobs until bcl2fastq started properly

secs=$((30))
while [ $secs -gt 0 ]; do
   echo -ne "Waiting $secs\033[0K\r"
   sleep 1
   : $((secs--))
done

### Create symlinks

for i in `ls $dir/BaseCalls/$folder/*.fastq.gz | cut -f 8 -d "/" | cut -f 1 -d "_" | sort -u`
do 
	ln -fs $dir/BaseCalls/$folder/"$i"_*R1_001.fastq.gz /scratch/phesiqcal/$folder/input/"$i"_R1.fastq.gz
        ln -fs $dir/BaseCalls/$folder/"$i"_*R2_001.fastq.gz /scratch/phesiqcal/$folder/input/"$i"_R2.fastq.gz
done
 
### Load phesiqcal module

source /phe/tools/miniconda3/etc/profile.d/conda.sh

conda activate phesiqcal

## Identify job_id of bcl2fastq on slurm

array=(${BCL// / })
JOBID_BCL=${array[3]}

### Running QC for Negative controls via slurm
sbatch --dependency=afterok:${JOBID_BCL} --job-name NTC_QC -o slurm-%x-%j.out --mem 10G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/config.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_NTC --use-conda"


### Running phesiqcal on slurm
phesiqcal=$(sbatch --dependency=afterok:${JOBID_BCL} --job-name phesiqcal -o slurm-%x-%j.out --mem 100G --ntasks 32 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 32 --configfile /scratch/phesiqcal/$folder/config.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_phesiqcal --use-conda")


# Identifying job_id of phesiqcal on slurm
array=(${phesiqcal// / })
JOBID_phesiqcal=${array[3]}


# path to the Phet shell script with all the typing tools
source /phe/tools/PHET/scripts/Start_TypingTools.sh

# Running shell script to record versions of QC and typing tools + Databases in PHET.
source /phe/tools/PHET/scripts/VersionRecord_PHETools.sh >> /scratch/phesiqcal/$folder/PHETools_Versions_$folder.txt &

# path to the shell script to create symlinks of Fastq files to selected pathogen folders
source /phe/tools/PHET/scripts/Symlinks_runner.sh &


