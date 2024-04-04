#!/bin/sh

## This script to run if pipeline crashed after completion of the basecalling process. 
# To avoid repeating the basecalling process, run this script, overrides the existing output directories and results if the pipeline previously crashed. 

# requires the full path to the MID output folder in scratch as input. 


input=${1?Error:no path to MID folder given}

folder=$(basename $input)

cd $input

source /phe/tools/miniconda3/etc/profile.d/conda.sh

conda activate phesiqcal

### Running phesiqcal on slurm
phesiqcal=$(sbatch -w frgeneseq03 --job-name phesiqcal -o slurm-%x-%j.out --mem 100G --ntasks 64 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 32 --configfile /scratch/phesiqcal/$folder/config.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_phesiqcal --use-conda")

# Identifying job_id of phesiqcal on slurm
array=(${phesiqcal// / })
JOBID_phesiqcal=${array[3]}

# path to the Phet shell script with all the typing tools
source /phe/tools/PHET/scripts/Start_TypingTools.sh

# Running shell script to record versions of QC and typing tools + Databases in PHET.
source /phe/tools/PHET/scripts/VersionRecord_PHETools.sh >> $input/PHETools_Versions_$folder.csv &

# removed the symlink runner, snippy_runner gets executed instead through typing tools. 


