#!/bin/sh




awk 'BEGIN {print "salmonella:"}; (FS="\t") {if($9 == "Salmonella enterica" && $2 >= 1000000 && $15 <= 500 ) print "- " $1 }' QC_summary.txt

awk 'BEGIN {print "listeria:"}; (FS="\t") {if($9 ~/Listeria/ && $2 >= 1000000 && $15 <= 500 ) print "- " $1 }' QC_summary.txt

awk 'BEGIN {print "gonorrhoeae:"}; (FS="\t") {if($9 == "Neisseria gonorrhoeae" && $2 >= 800000 && $15 <= 500 ) print "- " $1 }'  QC_summary.txt

awk 'BEGIN {print "spneumoniae:"}; (FS="\t") {if($0 ~/spneumoniae/ && $2 >= 800000 && $15 <= 500 ) print "- " $1 }' QC_summary.txt | sed 's,filtered_contigs/,,g' | cut -f 1 -d "." 

awk 'BEGIN {print "spyogenes:"}; (FS="\t") {if($9 == "Streptococcus pyogenes" && $2 >= 800000 && $15 <= 500 ) print "- " $1 }' QC_summary.txt

awk 'BEGIN {print "shigella:"}; (FS="\t") {if($9 ~/Shigella/ || $11 ~/Shigella/ && $2 >= 1000000 && $15 <= 500 ) print "- " $1  }' QC_summary.txt

awk 'BEGIN {print "Ssonnei:"}; (FS="\t") {if($9 == "Shigella sonnei" && $2 >= 1000000 && $15 <= 500 || $11 == "Shigella sonnei" && $2 >= 1000000 && $15 <= 500 ) print "- " $1  }' QC_summary.txt

awk 'BEGIN {print "ecoli:"}; (FS="\t") {if($9 == "Escherichia coli" && $11 !~/Shigella/ && $2 >= 1000000 && $15 <= 500 ) print "- " $1 }' QC_summary.txt

awk 'BEGIN {print "meningitidis:"}; (FS="\t") {if($9 == "Neisseria meningitidis" && $2 >= 800000 && $15 <= 500 ) print "- " $1 }' QC_summary.txt

awk 'BEGIN {print "tuberculosis:"}; (FS="\t") {if($9 == "Mycobacterium tuberculosis" && $2 >= 1000000 && $15 <= 500 ) print "- " $1 }' QC_summary.txt 

awk 'BEGIN {print "legionella:"}; (FS="\t") {if($9 ~/Legionella/ && $2 >= 1000000 && $15 <= 500 ) print "- " $1 }' QC_summary.txt

awk 'BEGIN {print "paeruginosa:"}; (FS="\t") {if($9 == "Pseudomonas aeruginosa" && $2 >= 1000000 && $15 <= 500 ) print "- " $1 }' QC_summary.txt

awk 'BEGIN {print "saureus:"}; (FS="\t") {if($9 == "Staphylococcus aureus" && $2 >= 1000000 && $15 <= 500 ) print "- " $1 }' QC_summary.txt


