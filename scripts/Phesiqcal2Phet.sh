#!/bin/sh

input=${1?Error:no path to MID folder given}

folder=$(basename $input)

cd $input

source /phe/tools/miniconda3/etc/profile.d/conda.sh

conda activate phesiqcal

### Running phesiqcal on slurm
phesiqcal=$(sbatch --job-name phesiqcal -o slurm-%x-%j.out --mem 100G --ntasks 32 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 32 --configfile /scratch/phesiqcal/$folder/config.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_phesiqcal --use-conda")

# Identifying job_id of phesiqcal on slurm
array=(${phesiqcal// / })
JOBID_phesiqcal=${array[3]}

# path to the Phet shell script with all the typing tools
source /phe/tools/PHET/scripts/Start_TypingTools.sh

# Running shell script to record versions of QC and typing tools + Databases in PHET.
source /phe/tools/PHET/scripts/VersionRecord_PHETools.sh >> $input/PHETools_Versions_$folder.csv &

# path to the shell script to create symlinks of Fastq files to selected pathogen folders
source /phe/tools/PHET/scripts/Symlinks_runner.sh &


