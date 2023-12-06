### *The pipeline currently is specific for the pathogen genomics workflow at PHE lab, SA Pathology. Under development for public use*
# PHEsiQCal2PHET
Microbial genomics pipeline for downstream processing of whole genome sequenced (WGS) bacterial isolates including QC assessment and bacterial subtyping, used by Pathogen genomics in Public Health and Epidemiology, South Australia. Automated using Snakemake and Slurm for processing on HPC cluster. It is a similar workflow as Nullarbor, but it only runs isolate specific analysis. No phylogenetic tree and pangenome analysis will be generated. 

Initiated by input of a Sample Sheet to a shell script, followed by a snakemake workflow that process fastq files of bacterial pathogens to produce the following outputs:

1) Sequencing yield (fq),

2) Species identification (Kraken2 using K2plus and gtdb database),

3) de novo assemblies (shovill) and their qc (fa)

4) Subtyping (MLST)

5) Antimicrobial resistance profile (abricate + amrfinder + ARIBA)

6) Gene annotations (Prokka)

7) Plasmid detection (abricate using plasmidfinder db)

8) Virulence factor detection (abricate using VFDB)

## Produces following summary files:

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

## Two main summary files
1) QC_summary.txt - concatenated seq_data.tab, species_identification.tab, denovo.tab and mlst.tab
2) gene_summary.txt - concatenated resistome.tab, plasmid.tab and virulome.tab

![Objectives and Tools](https://github.com/SAP-PHE-Bioinformatics/PHET/assets/112604261/bc670521-d8fd-4892-9c2c-dece01746f95)

# Citations
Acknowledgments to all the authors of tools used in the pipeline.

1. Pipeline inspired and customised from [Nullarbor](https://github.com/tseemann/nullarbor) workflow.
   Sequence quality stats (Fq) and assembly quality stats (Fa) analysed using scripts within Nullarbor.
   Seemann T, Goncalves da Silva A, Bulach DM, Schultz MB, Kwong JC, Howden BP. Nullarbor Github https://github.com/tseemann/nullarbor

2. kraken2
   Taxonomic sequence classifier that assigns taxonomic labels to DNA sequences Wood, D.E., Lu, J. & Langmead, B. Improved metagenomic analysis with Kraken 2 Genome Biol 20, 257 (2019)


