#!/bin/sh




awk 'BEGIN {print "salmonella:"}; (FS="\t") {if($10 == "Salmonella enterica" && $2 >= 1000000 && $16 <= 500 ) print "- " $1 }' QC_summary.txt

awk 'BEGIN {print "listeria:"}; (FS="\t") {if($10 ~/Listeria/ && $2 >= 1000000 && $16 <= 500 ) print "- " $1 }' QC_summary.txt

awk 'BEGIN {print "gonorrhoeae:"}; (FS="\t") {if($10 == "Neisseria gonorrhoeae" && $2 >= 800000 && $16 <= 500 ) print "- " $1 }'  QC_summary.txt

awk 'BEGIN {print "spneumoniae:"}; (FS="\t") {if($0 ~/spneumoniae/ && $2 >= 800000 && $16 <= 500 ) print "- " $1 }' QC_summary.txt | sed 's,filtered_contigs/,,g' | cut -f 1 -d "." 

awk 'BEGIN {print "spyogenes:"}; (FS="\t") {if($10 == "Streptococcus pyogenes" && $2 >= 800000 && $16 <= 500 ) print "- " $1 }' QC_summary.txt

awk 'BEGIN {print "shigella:"}; (FS="\t") {if($10 ~/Shigella/ || $12 ~/Shigella/ && $2 >= 1000000 && $16 <= 500 ) print "- " $1  }' QC_summary.txt

awk 'BEGIN {print "Ssonnei:"}; (FS="\t") {if($10 == "Shigella sonnei" && $2 >= 1000000 && $16 <= 500 || $12 == "Shigella sonnei" && $2 >= 1000000 && $16 <= 500 ) print "- " $1  }' QC_summary.txt

awk 'BEGIN {print "ecoli:"}; (FS="\t") {if($10 == "Escherichia coli" && $12 !~/Shigella/ && $2 >= 1000000 && $16 <= 500 ) print "- " $1 }' QC_summary.txt

awk 'BEGIN {print "meningitidis:"}; (FS="\t") {if($10 == "Neisseria meningitidis" && $2 >= 800000 && $16 <= 500 ) print "- " $1 }' QC_summary.txt

awk 'BEGIN {print "tuberculosis:"}; (FS="\t") {if($10 == "Mycobacterium tuberculosis" && $2 >= 1000000 && $16 <= 500 ) print "- " $1 }' QC_summary.txt 

awk 'BEGIN {print "legionella:"}; (FS="\t") {if($10 ~/Legionella/ && $2 >= 1000000 && $16 <= 500 ) print "- " $1 }' QC_summary.txt



