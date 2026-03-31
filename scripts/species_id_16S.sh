#!/bin/sh

# runner version
VERSION="v20260324"

# Check for -v or --version BEFORE processing the input
if [[ "$1" == "-v" || "$1" == "--version" ]]; then
    echo "species_id_16S.sh: $VERSION"
    exit 0
fi

input=${1?Error:no path to the sample folder within a phesiqcal output given}
sample=$(basename $input)
mid_dir=$(dirname $input)

### Load module

source /phe/tools/miniconda3/etc/profile.d/conda.sh

conda activate phesiqcal

### Create folder
#folder=$(awk -F ',' 'FNR == 4 {print $2}' $input)

mkdir -p $mid_dir/PHET/16S_hsp65_rpoB/$sample
outdir="$mid_dir/PHET/16S_hsp65_rpoB/$sample"

# cd $input

## copy the taxonomy file to the folder (clean-up will delete this afterwards)
export BLASTDB="/scratch/databases/16S_ncbi/"


# Running gene identification on the main terminal as it is low intensity 

## extract each of the genes 
awk 'BEGIN {RS=">"} /16S ribosomal RNA/ {print ">"$0}' $input/prokka/$sample.ffn > $outdir/"$sample"_16S.fasta
#awk -v sq="'" 'BEGIN {RS=">"} /DNA-directed RNA polymerase subunit beta/ && !/DNA-directed RNA polymerase subunit beta$sq/ {print ">"$0}' prokka/$sample.ffn > "$sample"_rpoB.fasta
awk 'BEGIN {RS=">"} /DNA-directed RNA polymerase subunit beta/ {print ">"$0}' $input/prokka/$sample.ffn > $outdir/"$sample"_rpoB.fasta
awk 'BEGIN {RS=">"} /60 kDa chaperonin/ {print ">"$0}' $input/prokka/$sample.ffn > $outdir/"$sample"_hsp65.fasta


## run the 16S gene against the 16S local database and then format it correctly for reporting 
blastn -db /scratch/databases/16S_ncbi/16S_ribosomal_RNA -query $outdir/"$sample"_16S.fasta -out $outdir/"$sample"_16S_blast.tab -outfmt "6 delim=, qseqid sacc  scomnames  qcovs nident length pident"
sort -t',' -k7nr -k4nr -k6nr $outdir/"$sample"_16S_blast.tab -o $outdir/"$sample"_16S_blast.tab
sed -i 's/,/\t/g' $outdir/"$sample"_16S_blast.tab
sed -i '1iAccession\tBlastMatchID\tBlastMatchSciName\tQueryCov\tnum_ident\tBLASTMatchLen\tpct_ident' $outdir/"$sample"_16S_blast.tab



# Recording Run details, Pipeline details and tool versions.
# current_DateTime=$(date +'%d/%m/%Y  %R')
# smk_version=$(snakemake --version)
# echo -e "DATE, $current_DateTime
# Raw_data_path:,$dir
# BACTERIAL WGS RUN ID,$folder
# Pipeline(s):,metamorPHEsis,v1.1.0
# Workflow management system: Snakemake,$smk_version" >> /scratch/metamorphesis/$folder/Version_record_$folder.csv


# Running shell script to record versions of QC and typing tools + Databases in PHET.
# source /phe/tools/metamorphesis/VersionRecord_metamorphesis.sh >> /scratch/metamorphesis/$folder/Version_record_$folder.csv &
