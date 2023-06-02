#!/bin/sh


source /phe/tools/miniconda3/etc/profile.d/conda.sh

conda activate phesiqcal


current_DateTime=$(date +'%d/%m/%Y  %R')

echo $current_DateTime 

echo '
BACTERIAL WGS RUN ID :' $folder 
  


echo '
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                                                                                    '

echo '######   PHEsiQCal - QC TOOLS and DATABASES ######
                                 
                                 '
echo '## KRAKEN ##'
kraken2 --version 

echo '--------------------------------------------------------------------------------'

echo '## SHOVILL ##'
shovill --version 

echo '--------------------------------------------------------------------------------'

echo '## PROKKA ##'
prokka_Version=$(grep -e 'my $VERSION' /phe/tools/miniconda3/envs/phesiqcal/bin/prokka | awk -F "$" '{print $2}' | awk -v FS=';' '{print "prokka " $1}')
echo $prokka_Version

echo '--------------------------------------------------------------------------------'

echo '## ABRICATE ##'
abricate --version 

echo '               '

echo '## ABRICATE DATABASE LIST AND LAST UPDATE DATE ##'
# abricate --list 

#getting last updated dates of databases from date stamp of sequences file for three databases used through abricate.
card_dbupdt=$(stat -c %y /phe/tools/miniconda3/envs/phesiqcal/db/card/sequences | cut -d' ' -f 1)
vfdb_dbupdt=$(stat -c %y /phe/tools/miniconda3/envs/phesiqcal/db/vfdb/sequences | cut -d' ' -f 1)
plasmidfinder_dbupdt=$(stat -c %y /phe/tools/miniconda3/envs/phesiqcal/db/plasmidfinder/sequences | cut -d' ' -f 1)


echo Last update of CARD database for ABRICATE: $card_dbupdt
echo Last update of VFDB database for ABRICATE: $vfdb_dbupdt
echo Last update of PlasmidFinder database for ABRICATE: $plasmidfinder_dbupdt


echo '--------------------------------------------------------------------------------'

conda activate amrfinder

echo ' ## AMRFinderPlus ## '
amrfinder --version

echo '--------------------------------------------------------------------------------'

conda activate mlst

echo '## MLST ##'
mlst --version 

echo '
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                                                                                    '

# activating conda environment for programs in phetype conda environment'
conda activate phetype

echo '###### PHET - TYPING TOOLS and DATABASES ######
                                                      '

echo '## SISTR for Salmonella enterica ##'
sistr --version 

echo '--------------------------------------------------------------------------------'

echo '## NGMASTER for Neisseria gonorrhoeae ##'
ngmaster --version 

echo '--------------------------------------------------------------------------------'

echo '## PYNGSTAR database version/date for Neisseria gonorrhoeae' 

lastupdtdate=$(stat -c %y /phe/tools/pyngSTar/pyngSTar.py | cut -d' ' -f1)
pyngSTarDB=$( basename /phe/tools/pyngSTar/pyngSTarDB_100522/)

echo Last modified date of pyngSTar script: $lastupdtdate
echo current database: $pyngSTarDB

echo '--------------------------------------------------------------------------------'

echo '## LISSERO for Listeria ##'
lissero --version 

echo '--------------------------------------------------------------------------------'

echo '## MENINGOTYPE for Neisseria meningitidis ##'
meningotype --version 

echo '--------------------------------------------------------------------------------'

echo '## LEGSTA for Legionella ##'
legsta --version 

echo '--------------------------------------------------------------------------------'

echo '## ECTYPER for Escherichia coli ##'
ectyper --version 

echo '--------------------------------------------------------------------------------'

echo '## ClermonTyping for Escherichia genus ##'
/phe/tools/ClermonTyping/clermonTyping.sh -v | head -n 1

echo '--------------------------------------------------------------------------------'

echo '## EmmTyper for Streptococcus pyogenes ##'
emmtyper --version 

echo '--------------------------------------------------------------------------------'

conda activate seroba

echo '## SEROBA for Streptococcus pneumoniae ##'
echo 'seroba version'; seroba version

echo '--------------------------------------------------------------------------------'

echo '## SEROCALL for Streptococcus pneumoniae ##'
serocallversion=$(grep -n SeroCallv /phe/tools/SeroCall/serocall.py | cut -d "=" -f 2 | awk -v FS='\' '{print $1}')
echo $serocallversion

echo '--------------------------------------------------------------------------------'

conda activate shigatyperV2

echo '## SHIGATYPER for Shigella sp. ##'
shigatyper --version 

echo '--------------------------------------------------------------------------------'

conda activate shigeifinder

echo '## SHIGEIFINDER for Shigella sp. ##'
shigeifinderV=$(grep -e Name -e Version /phe/tools/miniconda3/envs/shigeifinder/lib/python3.11/site-packages/shigeifinder-1.3.2.dist-info/METADATA | grep -v Metadata)
echo $shigeifinderV

echo '--------------------------------------------------------------------------------'


conda activate pheamr

echo '## MYKROBE PREDICT for Shigella sonnei AMR predictions ##'
mykrobe --version 


alleles_txt=$(basename /phe/tools/sonneityping/versions/alleles_20210201.txt)
echo '
Last updated version/date of alleles.txt used for lineage name in 
mykrobe sonneityping:' $alleles_txt

echo '--------------------------------------------------------------------------------'

conda activate tbprofiler

echo '## TB-PROFILER for Mycobacterium tuberculosis ##'
tb-profiler version 

echo '
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                                                                                  '
