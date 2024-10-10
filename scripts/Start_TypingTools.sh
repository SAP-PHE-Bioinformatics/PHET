#!/bin/sh

scratchdir=${1?Error: Require path to the MID folder}

source /phe/tools/miniconda3/etc/profile.d/conda.sh

# Activating phetype environment to run typing tools below.
conda activate phetype

cd $scratchdir

folder=$(basename $scratchdir)


# Sistr for Salmonella typing
sistr=$(sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name sistr -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_sistr --use-conda --nolock")

#identifying job id for sistr to set dependency for snippy runner in parent runner script
array=(${sistr// / })
export JOBID_sistr=${array[3]}

# Escherichia coli
sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name ecoli -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_Ecoli --use-conda --nolock"

# NGmaster and PyngStar for N.Gonorrhoeae typing
sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name ngono -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_ngono --use-conda --nolock"

# SeroBA and SeroCall for Streptoccocus pneumoniae typing
sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name spneum -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_spneum --latency-wait 1160 --use-conda --nolock"

# Lissero for Listeria typing
sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name lissero -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_lissero --use-conda --nolock"

# MeningoType for N.meningitidis
sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name meningotype -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_meningo --use-conda --nolock"

# Ectyper for E.coli - Run in the new Snakefile_Ecoli. AK 01/07/2024.
# sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name ectyper -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_ectyper --use-conda --nolock"

# TB-Profiler for Mycobacterium tuberculosis
sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name tbprofiler -o slurm-%x-%j.out --mem 100G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_tbprofiler --use-conda --nolock --latency-wait 300"

# Legsta for Legionella 
sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name legsta -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_legsta --use-conda --nolock"

# EmmTyper for Streptococcus pyogenes
sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name emmtyper -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_emmtyper --use-conda --nolock"

# Pasty for Pseudomonas aeruginosa
sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name pasty -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_pasty --use-conda --nolock"

# ClermonTyping for Escherichia genus - Clermont included in the new Snakefile_ecoli. AK 01/07/2024
# sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name clermonT -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 01:00:00 -D /scratch/phesiqcal/$folder/ --wrap "/phe/tools/PHET/scripts/Clermont_runner.sh"

# ShigeiFinder and Shigatyper for Shigella
shigella=$(sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name shigella -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_shigella --latency-wait 120 --use-conda --nolock")

#identifying job number of shigatyper/shigeifinder, to set Sonneityping tools as its dependency.
array=(${shigella// / })
JOBID_shigella=${array[3]}

# Mykrobe Sonneityping
sbatch --dependency=afterok:${JOBID_shigella} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name sonneityping -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_sonneityping --latency-wait 120 --use-conda --nolock"

# Staphylococcus aureus
sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name saureus -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_saureus --use-conda --nolock"

## RUNNING SNIPPY RUNNER - Symlinks and runs snippy for selected pathogens - dependent on completion of sistr for Salmonella.
# sbatch --dependency=afterok:${JOBID_sistr} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name snippy -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "/phe/tools/PHET/scripts/Snippy_runner.sh /scratch/phesiqcal/$folder/PHETools_Versions_$folder.csv"

# MASH for Mycobacterium abscessus
sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name mash_mabs -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_mash_mabs --use-conda --nolock"

# MASH for Mycobacterium intracellulare
sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name mash_maic -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_mash_maic --use-conda --nolock"

# HiCap for Haemophilus Influenzae
sbatch --dependency=afterok:${JOBID_phesiqcal} --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name hicap -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_hicap --use-conda --nolock"
