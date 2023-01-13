#!/bin/sh

source /phe/tools/miniconda3/etc/profile.d/conda.sh


# Activating phetype environment to run typing tools below.
conda activate phetype

cd /scratch/phesiqcal/$folder

# NGmaster and PyngStar for N.Gonorrhoeae typing
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name ngono --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_ngono --use-conda"

# SeroBA and SeroCall for Streptoccocus pneumoniae typing
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name spneum --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_spneum --latency-wait 180 --use-conda"

# Lissero for Listeria typing
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name lissero --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_lissero --use-conda"

# Sistr for Salmonella typing
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name sistr --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_sistr --use-conda"

# MeningoType for N.meningitidis
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name meningotype --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_meningo --use-conda"

# Ectyper for E.coli
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name ectyper --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_ectyper --use-conda"

# ShigeiFinder and Shigatyper for Shigella
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name shigella --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_shigella --latency-wait 120 --use-conda"

#Mykrobe Sonneityping
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name sonneityping --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 8 --configfile /scratch/phesiqcal/$folder/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_sonneityping --latency-wait 120 --use-conda"

# TB-Profiler for Mycobacterium tuberculosis
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name tbprofiler --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_tbprofiler --use-conda --latency-wait 300"

# Legsta for Legionella 
sbatch --dependency=afterok:${JOBID_phesiqcal} --job-name legsta --mem 50G --ntasks 16 --time 960:00:00 -D /scratch/phesiqcal/$folder/ --wrap "snakemake -j 16 --configfile /scratch/phesiqcal/$folder/phet.yaml --snakefile /phe/tools/PHET/scripts/Snakefile_legsta --use-conda"
