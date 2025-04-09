#!/bin/sh

# PHET Version 31/03/2025

VERSION="v5.0.1"
# VERSION=$(git ls-remote --tags https://github.com/SAP-PHE-Bioinformatics/PHET.git | tail -n 1 | cut -f 3 -d "/")

##########################################################################################
# Check for -v or --version BEFORE processing the input
if [[ "$1" == "-v" || "$1" == "--version" ]]; then
    echo "PHET: $VERSION"
    exit 0
fi

# Checking that only one positional argument (the input folder)
if [[ $# -ne 1 ]]; then
    echo "Error: Requires path to the Run folder containing PHEsiQCal results."
    echo "Usage: $0 [-v] <RunFolderPath>"
    exit 1
fi

# scratchdir=${1?Error: Requires path to the MID output folder}

# storing the first positional argument as input i.e. path to the MID output folder
scratchdir=$1

echo "Processing typing for run folder: $scratchdir"

############################################################################################

# Activating phetype environment to run typing tools below.
source /phe/tools/miniconda3/etc/profile.d/conda.sh
conda activate phetype

cd $scratchdir

# Storing the folder name if needed
folder=$(basename $scratchdir)


# SUBMITTING TYPING TOOL SCRIPTS TO SLURM

# Escherichia coli
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name ecoli -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_Ecoli --use-conda --nolock --printshellcmds"

# NGmaster and PyngStar for N.Gonorrhoeae typing
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name ngono -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_ngono --use-conda --nolock --printshellcmds"

# SeroBA and SeroCall for Streptoccocus pneumoniae typing
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name spneum -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_spneum --latency-wait 1160 --use-conda --nolock --printshellcmds"

# Lissero for Listeria typing
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name lissero -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_lissero --use-conda --nolock --printshellcmds"

# MeningoType for N.meningitidis
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name meningotype -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_meningo --use-conda --nolock --printshellcmds"

# Ectyper for E.coli - Run in the new Snakefile_Ecoli. AK 01/07/2024.
# sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name ectyper -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_ectyper --use-conda --nolock --printshellcmds"

# TB-Profiler for Mycobacterium tuberculosis
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name tbprofiler -o slurm-%x-%j.out --mem 100G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_tbprofiler --use-conda --nolock --printshellcmds --latency-wait 300"

# Legsta for Legionella 
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name legsta -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_legsta --use-conda --nolock --printshellcmds"

# EmmTyper for Streptococcus pyogenes
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name emmtyper -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_emmtyper --use-conda --nolock --printshellcmds"

# Pasty for Pseudomonas aeruginosa
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name pasty -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_pasty --use-conda --nolock --printshellcmds"

# ClermonTyping for Escherichia genus - Clermont included in the new Snakefile_ecoli. AK 01/07/2024
# sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name clermonT -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 01:00:00 -D $scratchdir/ --wrap "/phe/tools/PHET/scripts/Clermont_runner.sh"

# ShigeiFinder and Shigatyper for Shigella
shigella=$(sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name shigella -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_shigella --latency-wait 120 --use-conda --nolock --printshellcmds")

#identifying job number of shigatyper/shigeifinder, to set Sonneityping tools as its dependency.
array=(${shigella// / })
JOBID_shigella=${array[3]}

# Mykrobe Sonneityping
sbatch --dependency=afterok:${JOBID_shigella} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name sonneityping -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_sonneityping --latency-wait 120 --use-conda --nolock --printshellcmds"

# Staphylococcus aureus
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name saureus -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_saureus --use-conda --nolock --printshellcmds"

# MASH for Mycobacterium abscessus
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name mash_mabs -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_mash_mabs --use-conda --nolock --printshellcmds"

# MASH for Mycobacterium intracellulare
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name mash_maic -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_mash_maic --use-conda --nolock --printshellcmds"

# Hi-Cap for Haemophilus_influenzae
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name hicap -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_hicap --use-conda --nolock --printshellcmds"

# GBS for Stretococcus agalactiae
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name gbs -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_gbs --use-conda --nolock --printshellcmds"

# Choleraetyper - Abricate for Vibrio cholerae
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name choleraetyper -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_choleraetyper --use-conda --nolock --printshellcmds"

# Kleborate - for Klebsiella species 
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name kleborate -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_kleborate --use-conda --nolock --printshellcmds"

# Sistr for Salmonella typing
sistr=$(sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name sistr -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $scratchdir/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_sistr --use-conda --nolock --printshellcmds")


### EXCLUDED
#identifying job id for sistr to set dependency for snippy runner in parent runner script
# array=(${sistr// / })
# export JOBID_sistr=${array[3]}


## 19/03/2025 - sniPHEy execution moved out of 
# # Check if JOBID_sistr is set
# if [ -n "$JOBID_sistr" ]; then
#     # Launch Snippy_runner.sh to symlink and run Snippy for selected pathogens, with dependency on the sistr job
#     sbatch --dependency=afterok:${JOBID_sistr} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name snippy -o slurm-%x-%j.out --mem 80G \
#     --ntasks 32 --time 960:00:00 -D $scratchdir/ \
#     --wrap "/phe/tools/sniPHEy/scripts/Snippy_runner.sh $scratchdir/Version_record_$folder.csv"
# else
#     echo "Error: JOBID_sistr not found, launching Snippy_runner anyways"
#     # Launch Snippy_runner.sh to symlink and run Snippy for selected pathogens, with dependency on the sistr job
#     sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name snippy -o slurm-%x-%j.out --mem 80G \
#     --ntasks 32 --time 960:00:00 -D $scratchdir/ \
#     --wrap "/phe/tools/sniPHEy/scripts/Snippy_runner.sh $scratchdir/Version_record_$folder.csv"
# fi
