#!/bin/sh

source /phe/tools/miniconda3/etc/profile.d/conda.sh

# TYPING TOOLS

# echo "TYPING TOOLS"

conda activate phetype

# SISTR - SALMONELLA
sistr --version | tr " " ","

# NGMASTER - NEISSERIA GONORRHOEAE
ngmaster --version | tr " " ","


# PYNGSTAR - NEISSERIA GONORRHOEAE
PYNGSTAR=$(stat -c %y /phe/tools/pyngSTar/pyngSTar.py | cut -d' ' -f1)
pyngSTarDB=$(grep -rn /phe/tools/PHET/scripts/Snakefile_ngono -e pyngSTarDB | cut -f 9 -d "/")
echo "PyngSTar (Last modified date of script)",v"$PYNGSTAR",ngstar_DB,$pyngSTarDB

# LISSERO - Listeria
lissero --version | tr " " ","

# MENINGOTYPE - Neisseria meningitidis
MENINGO=$(meningotype --version | tr " " ",")
MENINGODB=$(stat -c %y /phe/tools/miniconda3/envs/phetype/lib/python3.6/site-packages/meningotype/db/ | cut -f1 -d " ")
echo $MENINGO,allele_db_pubMLST,$MENINGODB

# LEGSTA - Legionella
legsta --version | tr " " ","

# ECTYPER - Escherichia coli
ECTYPER=$(ectyper --version | cut -f 2 -d " ")
ECTYPER_DB=$(ectyper --version | cut -f 6 -d " ")
echo ECTyper,$ECTYPER,"ECTyper_DB (in-built)",v"$ECTYPER_DB"

# CLERMONTYPING - Escherichia coli
CLERMONT=$(/phe/tools/ClermonTyping/clermonTyping.sh -v | head -n 1 | cut -f 2 -d ":")
echo ClermonTyping,$CLERMONT

# EMMTYPER - Streptococcus pyogenes
emmtyper --version | tr " " ","

# SEROBA - Streptococcus pneumoniae
conda activate seroba
SEROBA=$(seroba version)
serobdb=$(basename /phe/tools/seroba/database_20240709/)
echo SeroBA,$SEROBA,ctvdb,$serobdb

# SEROCALL - Streptococcus pneumoniae
conda activate serocall
SEROCALL=$(grep -n SeroCallv /phe/tools/SeroCall/serocall.py | cut -d "=" -f 2 | awk -v FS='\' '{print $1}')
echo SeroCall,$SEROCALL

# SHIGATYPER - Shigella spp.
conda activate shigatyperV2
shigatyper --version | tr " " ","

# SHIGEIFINDER - Shigella spp.
conda activate shigeifinder
SHIGEIFINDER=$(grep -e Name -e Version /phe/tools/miniconda3/envs/shigeifinder/lib/python3.11/site-packages/shigeifinder-1.3.2.dist-info/METADATA | grep -v Metadata | sed -n '2 p' | cut -f 2 -d ":")
echo ShigEiFinder,$SHIGEIFINDER

# MYKROBE - Shigella sonnei
conda activate pheamr
MYKROBE=$(mykrobe --version | cut -f 2 -d " ")
ALLELES_DB=$(basename /phe/tools/sonneityping/versions/alleles_20210201.txt | cut -f 1 -d ".")
echo Mykrobe,$MYKROBE,Sonneityping_alleles_DB,$ALLELES_DB

# TBPROFILER - Mycobacterium tuberuclosis
conda activate tbprofiler_v6.2
TBPROFILER=$(tb-profiler version | cut -f 3 -d " ")
TB_DB=$(tb-profiler list_db | awk '{print $2}')
echo TBProfiler,$TBPROFILER,Tb-profiler_DB,$TB_DB\n

# PASTY - Pseudomonas aeruginosa
conda activate pasty
pasty --version 

# sccmec - Staphylococcus aureus
conda activate sccmec
sccmec_v=$(sccmec --version 2>&1)
echo "$sccmec_v" | awk '{gsub(/ schema /,"\nschema "); print}'

# Mash - MABS and MAIC
conda activate phesiqcal
MASH=$(mash --version )
echo Mash,$MASH

# Choleraetyper for Vibrio cholerae
ABRICATE=$(abricate --version | cut -f 2 -d " ")
cholerae_dbupdt=$(stat -c %y /phe/tools/miniconda3/envs/phesiqcal/db/choleraetyper/sequences | cut -d' ' -f 1)
echo "ABRicate,$ABRICATE,CholeraeTyper,$cholerae_dbupdt"

# Hi-Cap for Haemophilus Influenzae
conda activate hicap
hicap=$(hicap -v | tr " " ",")
echo $hicap

# Kleborate for Klebsiella species
conda activate test
Kleborate=$(kleborate --version | tr " " ",")
echo $Kleborate
