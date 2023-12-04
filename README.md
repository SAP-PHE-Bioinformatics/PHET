# *Under development for public use*
# PHET
Microbial genomics pipeline for downstream processing of whole genome sequenced bacterial isolates including QC assessment and bacterial subtyping, used by Pathogen genomics in Public Health and Epidemiology, South Australia. Automated using Snakemake and Slurm for processing on HPC cluster. It is a similar workflow as Nullarbor, but it only runs isolate specific analysis. No phylogenetic tree and pangenome analysis will be generated. 
A snakemake workflow that process fastq files of bacterial pathogens to produce the following outputs:

1) Sequencing yield (fq),

2) Species identification (Kraken2 using K2plus and gtdb database),

3) de novo assemblies (shovill) and their qc (fa)

4) Subtyping (MLST)

5) Antimicrobial resistance profile (abricate + amrfinder + ARIBA)

6) Gene annotations (Prokka)

7) Plasmid detection (abricate using plasmidfinder db)

8) Virulence factor detection (abricate using VFDB)

# Produces following summary files:

1) seq_data.tab - Sequencing quality
2) species_identification.tab
3) gtdb_species_id.tab
4) denovo.tab
5) mlst.tab
6) resitome.tab
7) plasmid.tab
8) virulome.tab
9) ariba_summary.csv
10) amrfinder_summary.tsv

# Two main summary files
1) QC_summary.txt - concatenated seq_data.tab, species_identification.tab, denovo.tab and mlst.tab
2) gene_summary.txt - concatenated resistome.tab, plasmid.tab and virulome.tab

![Objectives and Tools](https://github.com/SAP-PHE-Bioinformatics/PHET/assets/112604261/bc670521-d8fd-4892-9c2c-dece01746f95)


