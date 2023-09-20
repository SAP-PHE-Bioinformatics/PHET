#!/bin/sh

source /phe/tools/miniconda3/etc/profile.d/conda.sh


# Activating phetype environment to run typing tools below.
conda activate phetype

cd /scratch/phesiqcal/$folder

# Running amrfinderplus as dependency of phesiqcal for AMR analysis
amr=$(sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name amr -o slurm-%x-%j.out --mem 50G --ntasks 24 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "/phe/tools/PHET/scripts/amrfinder.sh")

#identifying job number of amrfinderplus, to set Shigella typing tools as its dependency.
array=(${amr// / })
JOBID_amr=${array[3]}

# NGmaster and PyngStar for N.Gonorrhoeae typing
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name ngono -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_ngono --use-conda --nolock"

# SeroBA and SeroCall for Streptoccocus pneumoniae typing
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name spneum -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_spneum --latency-wait 180 --use-conda --nolock"

# Lissero for Listeria typing
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name lissero -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_lissero --use-conda --nolock"

# Sistr for Salmonella typing
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name sistr -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_sistr --use-conda --nolock"

# MeningoType for N.meningitidis
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name meningotype -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_meningo --use-conda --nolock"

# Ectyper for E.coli
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name ectyper -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_ectyper --use-conda --nolock"

# TB-Profiler for Mycobacterium tuberculosis
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name tbprofiler -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_tbprofiler --use-conda --nolock --latency-wait 300"

# Legsta for Legionella 
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name legsta -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_legsta --use-conda --nolock"

# EmmTyper for Streptococcus pyogenes
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name emmtyper -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_emmtyper --use-conda --nolock"

# Pasty for Pseudomonas aeruginosa
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name pasty -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_pasty --use-conda --nolock"

# ClermonTyping for Escherichia genus
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name clermonT -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 01:00:00 -D /scratch/phesiqcal/$folder/ --wrap "/phe/tools/PHET/scripts/Clermont_runner.sh"

# ShigeiFinder and Shigatyper for Shigella
shigella=$(sbatch --dependency=afterok:${JOBID_amr} --job-name shigella -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_shigella --latency-wait 120 --use-conda --nolock")

#identifying job number of shigatyper/shigeifinder, to set Sonneityping tools as its dependency.
array=(${shigella// / })
JOBID_shigella=${array[3]}

# Mykrobe Sonneityping
sbatch --dependency=afterok:${JOBID_shigella} --job-name sonneityping -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/PHET/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_sonneityping --latency-wait 120 --use-conda --nolock"

