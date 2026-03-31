#!/bin/sh

# PHET Version 31/03/2025

VERSION="v5.1.0"
# VERSION=$(git ls-remote --tags https://github.com/SAP-PHE-Bioinformatics/PHET.git | tail -n 1 | cut -f 3 -d "/")

##########################################################################################
# Check for -v or --version BEFORE processing the input
if [[ "$1" == "-v" || "$1" == "--version" ]]; then
    echo "PHET: $VERSION"
    exit 0
fi

# -----------------------------------------
# Parse inputs
# -----------------------------------------
## Print usage message if user uses --help/-h flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 Required: Requires path to the phet.yaml file. | Optional: [organism]"
    echo "Optional organism argument allows you to run typing tools for specific pathogen."
    echo "Use '--list' to see all valid organisms."
    exit 0
fi

# Print valid organism list available to run for typing tools if user uses --list/-l flag.
# -----------------------------------------
# List of valid organisms
# -----------------------------------------
valid_organisms=(
    Ecoli Hinflu Kleb 
    Lmono Lpneumo MABS
    MAIC MTB Ngono
    Nmeningo Paeru Sagalac
    Salm Saureus Shig
    Spneumo Spyo Vchol
    NTM_Nocardia
      
)

# Bash associative array mapping short names to full forms
declare -A organism_fullnames=(
    [Ecoli]="Escherichia coli - ECTyper and ClermonTyping"
    [Hinflu]="Haemophilus influenzae - HiCap"
    [Kleb]="Klebsiella species - Kleborate"
    [Lmono]="Listeria monocytogenes - Lissero"
    [Lpneumo]="Legionella pneumophila - Legsta"
    [MABS]="Mycobacterium abscessus - MASH"
    [MAIC]="Mycobacterium intracellulare - MASH"
    [MTB]="Mycobacterium tuberculosis - TBProfiler"
    [Ngono]="Neisseria gonorrhoeae - NGmaster and PyngStar"
    [Nmeningo]="Neisseria meningitidis - Meningotype and Capsular typing"
    [Paeru]="Pseudomonas aeruginosa - Pasty"
    [Sagalac]="Streptococcus agalactiae - GBS typing with Abricate"
    [Salm]="Salmonella species - sistr and SeqSero2"
    [Saureus]="Staphylococcus aureus - sccmec"
    [Shig]="Shigella species - Mykrobe_SonneiTyping, ShigaTyper and ShigeiFinder"
    [Spneumo]="Streptococcus pneumoniae - SeroBA and SeroCall"
    [Spyo]="Streptococcus pyogenes - EmmTyper"
    [Vchol]="Vibrio cholerae - choleraetyper with abricate"
    [NTM_Nocardia]="Non-TB Mycobacteriums and Nocardia - species ID using 16S_rpoB_hsp_NCBI"
)

# Flag to list valid organisms.
if [[ "$1" == "--list" || "$1" == "-l" ]]; then
    echo "Available organisms for typing tools:"
    for shortname in "${valid_organisms[@]}"; do
        full="${organism_fullnames[$shortname]}"
        printf "  %-15s : %s\n" "$shortname" "$full"
    done
    exit 0
fi

# Using '$#' is bash variable that stores number of positional arguments passed to the script
# -lt 1 - checks if the user passed less than one positional arguments i.e. no input.
if [[ $# -lt 1 ]]; then 
    echo "Usage: $0 Required: Requires path to the phet.yaml file. | Optional: [organism]" #$0 refers to the script name being executed.
	echo "Optional organism argument allows you to run typing tools for specific pathogen."
    echo "$0 --list     # Print all valid organisms and exit"
    exit 1
fi

############################################################################################
# storing the first positional argument as input i.e. path to the MID output folder
phetfile=$1
organism=$2

# Ensuring the file path provided exists
if [[ ! -e "$phetfile" ]]; then
    echo "ERROR: Input file '$phetfile' does not exist."
    exit 1
fi

############################################################################################

# Activating phetype environment to run typing tools below.
source /phe/tools/miniconda3/etc/profile.d/conda.sh
conda activate phetype

# Accessing the run path and storing the folder name if needed
scratchdir=$(dirname $(dirname $phetfile))
folder=$(basename $scratchdir)

cd $scratchdir
echo "Processing typing for run folder: $scratchdir"

# -----------------------------------------
# Validating organism input if provided
# -----------------------------------------
if [[ -n "$organism" ]]; then
    valid=false
    for o in "${valid_organisms[@]}"; do
        if [[ "$organism" == "$o" ]]; then
            valid=true
            break
        fi
    done
    if [[ "$valid" == false ]]; then
        echo "ERROR: Unknown organism: $organism"
        echo "Valid options are:"
        for shortname in "${valid_organisms[@]}"; do
            full="${organism_fullnames[$shortname]}"
            printf "  %-15s : %s\n" "$shortname" "$full"
        done
        exit 1
    fi
fi

#############################################################################################
# DEFINING FUNCTIONS FOR EACH PATHOGEN SPECIFIC TYPING TOOL TO RUN INDEPENDENTLY IF NEEDED. #
#############################################################################################

# SUBMITTING TYPING TOOL SCRIPTS TO SLURM

# Escherichia coli
run_Ecoli() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name ecoli -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_Ecoli --use-conda --nolock --printshellcmds"
}

# NGmaster and PyngStar for N.Gonorrhoeae typing
run_Ngono() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name ngono -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_ngono --use-conda --nolock --printshellcmds"
}

# SeroBA and SeroCall for Streptoccocus pneumoniae typing
run_Spneumo() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name spneum -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_spneum --latency-wait 1160 --use-conda --nolock --printshellcmds"
}

# Lissero for Listeria typing
run_Lmono() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name lissero -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_lissero --use-conda --nolock --printshellcmds"
}

# MeningoType for N.meningitidis
run_Nmeningo() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name meningotype -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_meningo --use-conda --nolock --printshellcmds"
}

# Legsta for Legionella 
run_Lpneumo() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name legsta -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_legsta --use-conda --nolock --printshellcmds"
}

# EmmTyper for Streptococcus pyogenes
run_Spyo() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name emmtyper -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_emmtyper --use-conda --nolock --printshellcmds"
}

# Pasty for Pseudomonas aeruginosa
run_Paeru() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name pasty -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_pasty --use-conda --nolock --printshellcmds"
}

# ShigeiFinder and Shigatyper for Shigella
run_Shig() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name shigella -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_shigella --latency-wait 120 --use-conda --nolock --printshellcmds"
}

# Staphylococcus aureus
run_Saureus() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name saureus -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_saureus --use-conda --nolock --printshellcmds"
}

# MASH for Mycobacterium abscessus
run_MABS() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name mash_mabs -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_mash_mabs --use-conda --nolock --printshellcmds"
}

# MASH for Mycobacterium intracellulare
run_MAIC() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name mash_maic -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_mash_maic --use-conda --nolock --printshellcmds"
}

# Hi-Cap for Haemophilus_influenzae
run_Hinflu() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name hicap -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_hicap --use-conda --nolock --printshellcmds"
}

# GBS for Stretococcus agalactiae
run_Sagalac() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name gbs -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_gbs --use-conda --nolock --printshellcmds"
}

# Choleraetyper - Abricate for Vibrio cholerae
run_Vchol() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name choleraetyper -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_choleraetyper --use-conda --nolock --printshellcmds"
}

# Kleborate - for Klebsiella species 
run_Kleb() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name kleborate -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_kleborate --use-conda --nolock --printshellcmds"
}

# Sistr for Salmonella typing
run_Salm() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name salmonella -o slurm-%x-%j.out --mem 50G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_salmonella --use-conda --nolock --printshellcmds"
}

# TB-Profiler for Mycobacterium tuberculosis
run_MTB() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name tbprofiler -o slurm-%x-%j.out --mem 100G --ntasks 16 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_tbprofiler --use-conda --nolock --printshellcmds --latency-wait 300"
}

# SpeciesID using 16S_rpoB_hsp for NTMs and Nocardia
run_NTM_Nocardia() {
sbatch --exclude=frgeneseq-control --nodelist=frgeneseq03 --nodes=1 --job-name rpoB_16S_hsp -o slurm-%x-%j.out --mem 25G --ntasks 4 --time 960:00:00 -D $scratchdir/ --wrap "snakemake -j 16 --configfile $phetfile --snakefile /phe/tools/PHET/scripts/Snakefile_16S_hsp65_rpoB --use-conda --nolock --printshellcmds"
}

############# CONTROLLER LOGIC ##################
	# Call functions of ALL pathogens defined in the script if no organism specified, only phet input file provided.
	# Call functions of specific pathogen if pathogen specified by user as second input argument
#################################################

if [[ -z "$organism" ]]; then
    echo "Running typing tools for ALL pathogens detected in $folder..."
    run_Ecoli
    run_Salm
    run_MTB
    run_Shig
    run_Ngono
    run_Spneumo
    run_Lmono
    run_Nmeningo
    run_Lpneumo
    run_Spyo
    run_Paeru
    run_Saureus
    run_MABS
    run_MAIC
    run_Hinflu
    run_Sagalac
    run_Vchol
    run_Kleb
    run_NTM_Nocardia
else
    case "$organism" in
        Ecoli) run_Ecoli ;;
        Hinflu) run_Hinflu ;;
        Kleb) run_Kleb ;;
        Lmono) run_Lmono ;;
        Lpneumo) run_Lpneumo ;;
        MABS) run_MABS ;;
        MAIC) run_MAIC ;;
        MTB) run_MTB ;;
        Ngono) run_Ngono ;;
        Nmeningo) run_Nmeningo ;;
        Paeru) run_Paeru ;;
        Sagalac) run_Sagalac ;;
        Salm) run_Salm ;;
        Saureus) run_Saureus ;;
        Shig) run_Shig ;;
        Spneumo) run_Spneumo ;;
        Spyo) run_Spyo ;;
        Vchol) run_Vchol ;;
        NTM_Nocardia) run_NTM_Nocardia ;;
        *)
    esac
fi
