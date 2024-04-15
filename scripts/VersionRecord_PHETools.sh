#!/bin/sh

source /phe/tools/miniconda3/etc/profile.d/conda.sh

# TYPING TOOLS

echo "TYPING TOOLS"

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
meningotype --version | tr " " ","

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
echo SeroBA,$SEROBA

# SEROCALL - Streptococcus pneumoniae
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
conda activate tbprofiler
TBPROFILER=$(tb-profiler version | cut -f 3 -d " ")
TB_DB=$(tb-profiler list_db | awk '{print $2}')
echo TBProfiler,$TBPROFILER,Tb-profiler_DB,$TB_DB\n

# PASTY - Pseudomonas aeruginosa
conda activate pasty
pasty --version 