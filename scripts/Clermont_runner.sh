#!/bin/sh

source /phe/tools/miniconda3/etc/profile.d/conda.sh
conda activate phetype

# Variable to store today's date
current_Date=$(date +'%Y%m%d')

# Variable to store output directory name with today's date.
outdir=ClermonTyping_$current_Date


# Selecting the assembled contigs for e.coli, filtered by quality and species match, and printing pathway to the contigs spearated by @ as per clermont tool requirement. 
fastafiles=$(awk '(FS="\t") {if($10 ~/Escherichia/ && $12 !~/Shigella/ && $2 >= 1000000 && $16 <= 500 ) print $1 } ' QC_summary.txt | while read line; do ls -p filtered_contigs/"$line".fna | tr '\n' '@' ; done | sed '1h;1!H;$!d;g;s/\(.*\)@/\1/')

## running ClermoTyping on above selected fasta files. 
/phe/tools/ClermonTyping/clermonTyping.sh --fasta $fastafiles --name $outdir


#Waiting for ClermontTyping to finish running and output results in directory as specified above
# until [[ -d $outdir ]]
# do
#   sleep 30
# done

# i for counter
# i=0
#until condition with counter/timer to exit if no Clermont output due to no Escherichia in the run, otherwise continue and move the output to PHET folder. 
# until [[ -d $outdir ]]
# do
#    sleep 300
#    if [[ $i -eq 1800 ]]
#    then
#       echo "$current_Date -- No Escherchia to process for ClermonTyping" >> Clermont_exit_log.txt
#       break
#    fi
#    ((i++))
# done

# Making the relevant directory
mkdir -p PHET/Escherichia/

# Moving the output folder 
mv $outdir PHET/Escherichia/ 