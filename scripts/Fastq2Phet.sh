#!/bin/sh

## storing the input 'fastq' directory in variable $input
input=${1?Error:no fastq folder given as input}


## storing the path to the fastq folder in variable $dir
dir=$(dirname $input)

## storing the last directory name (i.e. directory containing data from jurisdictions to process) from $dir in variable $folder  
folder=$(basename $dir)


## making directory with folder name for output and also input directory for fastq symlinks
mkdir -p /scratch/phesiqcal/$folder/input


## change to input directory and create symlinks from input fastq directory to $folder/input
cd /scratch/phesiqcal/$folder/input


# creating symlinks of Fastq file in working directory
ls $input/ | cut -f 1 -d "_" |
while read line;
do
   ln -fs $input"$line"*1*.gz /scratch/phesiqcal/$folder/input/"$line"_R1.fastq.gz
   ln -fs $input"$line"*2*.gz /scratch/phesiqcal/$folder/input/"$line"_R2.fastq.gz;
done

cd /scratch/phesiqcal/$folder/ 

##creating config file for PHEsiQCal snakemake pipeline

ls $input | cut -f 1 -d "_" | awk 'BEGIN{print "samples:"}; {IGNORECASE=1}; {if($0 !~/NEG/) print "- " $line | "sort -u"}' > /scratch/phesiqcal/$folder/config.yaml

ls $input | cut -f 1 -d "_" | awk 'BEGIN {print "negative:"}; {IGNORECASE=1}; {if( $0 ~/NEG/ ) print "- " $line }' >> /scratch/phesiqcal/$folder/config.yaml



### Pausing following jobs until above processes completed.

secs=$((15))
while [ $secs -gt 0 ]; do
   echo -ne "Waiting $secs\033[0K\r"
   sleep 1
   : $((secs--))
done


## Load phesiqcal module
source /phe/tools/miniconda3/etc/profile.d/conda.sh

conda activate phesiqcal

### Running QC for Negative controls
sbatch --job-name NTC_QC --mem 10G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/config.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_NTC"


### Running phesiqcal on slurm
phesiqcal=$(sbatch --job-name phesiqcal --mem 100G --ntasks 32 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 32 --configfile /scratch/phesiqcal/$folder/config.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_phesiqcal --use-conda")


# Identifying job_id of phesiqcal on slurm
array=(${phesiqcal// / })
JOBID_phesiqcal=${array[3]}


# path to the Phet shell script with all the typing tools
source /phe/tools/PHET/scripts/Start_TypingTools.sh

# Running shell script to record versions of QC and typing tools + Databases in PHET.
source /phe/tools/PHET/scripts/VersionRecord_PHETools.sh >> /scratch/phesiqcal/$folder/PHETools_Versions_$folder.txt &