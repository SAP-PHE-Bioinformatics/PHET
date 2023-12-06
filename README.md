##### NOTE: *Currently, the pipeline is specific to the pathogen genomics workflow at Public Health lab, SA Pathology. Under development for public use.*
# PHEsiQCal2PHET 
*This pipeline is an extension of the original pipeline [PHEsiQCal](https://github.com/SAP-PHE-Bioinformatics/PHEsiQCal_-Eyre-) by Pathogen Genomic Lead, Lex Leong, at SA Pathology, with addition of automation of selective bacterial subtyping tools and reduced run time.*

## Introduction
Microbial genomics pipeline for downstream processing of whole genome sequenced (WGS) bacterial isolates including QC assessment and bacterial subtyping, used by Pathogen genomics in Public Health and Epidemiology, South Australia. Automated using Snakemake and Slurm for processing on HPC cluster. It is a similar workflow as Nullarbor, but it only runs isolate specific analysis. Has a sub-workflow to process No Template Control (NTC). No phylogenetic tree and pangenome analysis will be generated. 

Initiated by input of a Sample Sheet to a shell script as: <br>
`/path/to/the/Bcl2Phet.sh /path/to/the/SampleSheet.csv/` , <br>
followed by a snakemake workflow that processes fastq files of bacterial pathogens to produce the following outputs:

1) Sequencing yield (fq),

2) Species identification (Kraken2 using K2plus and gtdb database),

3) de novo assemblies (shovill) and their qc (fa)

4) Subtyping (MLST)

5) Antimicrobial resistance profile (ABRicate + AMRFinderPlus + ARIBA)

6) Gene annotations (Prokka)

7) Plasmid detection (abricate using plasmidfinder db)

8) Virulence factor detection (abricate using VFDB)


#### No template control (NTC) workflow
The pipeline includes the sub-workflow for No Template Controls (NTC) is determined by the NTC sample ID given as "NEG" in the sample sheet input. 
Only runs sequencing quality and kraken2 on NTCs to check for any potential contamination in a bacterial agnostic WGS run.


### Produces following summary files:

1) seq_data.tab - Sequencing quality
2) species_identification.tab
3) gtdb_species_id.tab
4) assembled_kraken_species.tab
5) denovo.tab
6) mlst.tab
7) resitome.tab
8) plasmid.tab
9) virulome.tab
10) ariba_summary.csv
11) amrfinder_summary.tsv

### Two main summary files
1) QC_summary.txt - concatenated seq_data.tab, species_identification.tab, denovo.tab and mlst.tab
2) gene_summary.txt - concatenated resistome.tab, plasmid.tab and virulome.tab

![Objectives and Tools](https://github.com/SAP-PHE-Bioinformatics/PHET/assets/112604261/bc670521-d8fd-4892-9c2c-dece01746f95)

## Citations
Acknowledgments to all the authors of tools used in the pipeline.

1. [Nullarbor](https://github.com/tseemann/nullarbor) <br>
   Pipeline inspired and customised from workflow. <br>
   **Sequence quality stats (Fq)** and **assembly quality stats (Fa)** analysed using scripts within Nullarbor. <br>
   Seemann T, Goncalves da Silva A, Bulach DM, Schultz MB, Kwong JC, Howden BP. Nullarbor Github https://github.com/tseemann/nullarbor

3. [kraken2](https://github.com/DerrickWood/kraken2) <br>
   Taxonomic sequence classifier that assigns taxonomic labels to DNA sequences Wood, D.E., Lu, J. & Langmead, B. Improved metagenomic analysis with Kraken 2 
   Genome Biol 20, 257 (2019)

4. [Shovill](https://github.com/tseemann/shovill) <br>
   Assemble bacterial isolate genomes from Illumina paired-end reads <br>
   Seemann T, Shovill Github https://github.com/tseemann/shovill

5. [MLST](https://github.com/tseemann/mlst) <br>
   For Multi-Locus sequence typing of contigs using [PubMLST](https://pubmlst.org/bigsdb?db=pubmlst_mlst_seqdef) typing schemes. <br>
   Seemann T, mlst Github https://github.com/tseemann/mlst

6. [ABRicate](https://github.com/tseemann/abricate) <br>
   Mass screening of contigs for antimicrobial resistance, virulence genes and plasmids. <br>
   Seemann T, Abricate, Github https://github.com/tseemann/abricate

   Databases used with this tool in the pipeline: <br>
   - AMR - [CARD](https://card.mcmaster.ca/) <br>
   - Virulence genes - [VFDB](http://www.mgc.ac.cn/VFs/) <br>
   - Plasmids - [PlasmidFinder](https://pubmed.ncbi.nlm.nih.gov/24777092/)
  
7. [AMRFinderPlus](https://github.com/ncbi/amr) <br>
   Used to identify acquired antimicrobial resistance genes in bacterial assembled nucleotide sequences as well as known resistance-associated point mutations for 
   several taxa. <br>
   Feldgarden M, Brover V, Gonzalez-Escalona N, Frye JG, Haendiges J, Haft DH, Hoffmann M, Pettengill JB, Prasad AB, Tillman GE, Tyson GH, Klimke W. AMRFinderPlus 
   and the Reference Gene Catalog facilitate examination of the genomic links among antimicrobial resistance, stress response, and virulence. Sci Rep. 2021 Jun 
   16;11(1):12728. doi: 10.1038/s41598-021-91456-0. PMID: 34135355; PMCID: PMC8208984.

8. [ARIBA](https://github.com/sanger-pathogens/ariba) with [CARD](https://card.mcmaster.ca/) database. <br>
   For identifying antimicrobial resistance genes from raw reads. <br>
   ARIBA: rapid antimicrobial resistance genotyping directly from sequencing reads Hunt M, Mather AE, Sánchez-Busó L, Page AJ, Parkhill J , Keane JA, Harris SR. 
   Microbial Genomics 2017. doi: 110.1099/mgen.0.000131

9. [PROKKA](https://github.com/tseemann/prokka) <br>
   For gene annotations <br>
   Seemann T. Prokka: rapid prokaryotic genome annotation <br>
   Bioinformatics 2014 Jul 15;30(14):2068-9. [PMID:24642063](https://pubmed.ncbi.nlm.nih.gov/24642063/)

10. [SNAKEMAKE](https://snakemake.github.io/) <br>
    Main Pipeline workflow written in Snakemake for streamlining analysis. <br>
    Mölder, F., Jablonski, K.P., Letcher, B., Hall, M.B., Tomkins-Tinch, C.H., Sochat, V., Forster, J., Lee, S., Twardziok, S.O., Kanitz, A., Wilm, A., Holtgrewe, 
    M., Rahmann, S., Nahnsen, S., Köster, J., 2021. Sustainable data analysis with Snakemake. F1000Res 10, 33.

11. [SLURM](https://github.com/SchedMD/slurm) <br>
    For automation and resource management of the pipeline to run on HPC cluster. <br>
    Yoo, A.B., Jette, M.A., Grondona, M. (2003). SLURM: Simple Linux Utility for Resource Management. In: Feitelson, D., Rudolph, L., Schwiegelshohn, U. (eds) Job 
    Scheduling Strategies for Parallel Processing. JSSPP 2003. Lecture Notes in Computer Science, vol 2862. Springer, Berlin, Heidelberg. 
    https://doi.org/10.1007/10968987_3







