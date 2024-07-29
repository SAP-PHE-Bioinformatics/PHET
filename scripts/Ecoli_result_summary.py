#!/usr/bin/env python

# Import libraries
import pandas as pd
import pathlib
import subprocess
import os
import glob
import numpy as np
import datetime
import argparse

# Defining ANSI escape sequences for colors for print messages
class bcolors:
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# Required Arguments
parser = argparse.ArgumentParser(description="Summarises results for E. coli for STEC reporting. See Usage")
parser.add_argument('--mid', required=True, help="MID run ID: MIDYYXXX, e.g. MID24001")
parser.add_argument('--qc', required=True, help="Path to the QC summary file")
parser.add_argument('--vir', required=True, help="Path to the virulome.tab file")
parser.add_argument('--ec', required=True, help="Path to the output.tsv file from EcTyper")
parser.add_argument('--cl', required=True, help="Path to the ClermonTyping_YYYYMMDD_phylogroups.txt file")
parser.add_argument('--out', required=True, help="Name of the report summary file per run")

args = parser.parse_args()
print(args)
    
# Read QC file, select and rename specific columns
QC_sum = pd.read_csv(args.qc, sep='\t')
QC_sum = QC_sum.loc[:,['#Accession', 'Reads', 'AvgQual', 'no', '#1 Match', '%1', '#2 Match', '%2', '#3 Match', '%3', 'scheme', 'ST']]
QC_sum = QC_sum.rename({'#Accession': 'Seq_ID', 'no': 'contigs', 'ST':'MLST'}, axis =1)
print(QC_sum)


# Read virulome file
virulence = pd.read_csv(args.vir, sep='\t')
# Replace the value in the '#FILE' column and rename it to 'Seq_ID'
virulence['#FILE'] = virulence['#FILE'].str.replace(r'/vfdb.tab', '')
virulence = virulence.rename({'#FILE': 'Seq_ID'}, axis=1)
# List of virulence gene columns
stec_virulence_genes = ['Seq_ID', 'stx1A', 'stx1B', 'stx2A', 'stx2B', 'stxA', 'eae', 'hlyA', 'east1', 'espK', 'espM1', 'espN', 'espV']
# If any gene column not found, create missing columns and fill '.' value 
for col in stec_virulence_genes:
    if col not in virulence.columns:
        virulence[col] = '.'
# Reorder columns and select only the desired ones
virulence = virulence[stec_virulence_genes]
print(virulence)


# Read Ectyper output, select and rename columns
EC = pd.read_csv(args.ec, sep='\t')
EC = EC.loc[:,['Name', 'O-type', 'H-type', 'Serotype']]
EC = EC.rename({'Name': 'Seq_ID'}, axis =1)
print(EC)


# Read Clermont typing output and write column headers (Based on github read.me page of the tool)
# Removing string from file name and selecting columns of interest
CL_colnames = ['Seq_ID', 'genes detected', 
    'presence(+)/absence(-) for 4 genes arpA, chuA, yjaA and TspE4.C2', 
    'alleles specific for groups C and E', 'Phylogroup', 'mash file']
CL = pd.read_csv(args.cl, sep='\t', names=CL_colnames)
CL['Seq_ID'] = CL['Seq_ID'].str.replace(r'.fna', '')
print(CL)
CL = CL.loc[:,['Seq_ID', 'Phylogroup']]
# print(CL)


# Join QC summary and Ectyper output first
Output_df = pd.merge(QC_sum, EC, on='Seq_ID', how='inner')

# Joining remaining files
CL_vir_files = [CL, virulence]
for i in CL_vir_files:
    Output_df = pd.merge(Output_df, i, on='Seq_ID', how='inner')

# Changing contig number values to whole numbers            
Output_df['contigs'] = Output_df['contigs'].apply(lambda x: int(round(x, 0)))

# Adding Accession ID column to be extracted from seq_IDs
# Function to format the 'Accession ID' with hyphens
def format_accession_id(seq_id):
    accession_id = seq_id[:10]
    return f"{accession_id[:2]}-{accession_id[2:5]}-{accession_id[5:]}"

## Populate the 'Accession ID' column with the first 10 characters from the 'SeqID' values
# Output_df['Accession ID'] = Output_df['Seq_ID'].apply(lambda x: x[:10]) <<-- if Accession number is required without hyphens

# Populating accession from seq_ID with hyphens.
Output_df.insert(0, 'Accession ID', '')
Output_df['Accession ID'] = Output_df['Seq_ID'].apply(lambda x: format_accession_id(x))

# Adding QC check column. Passes if Reads > 1 million, contigs < 500, AvgQual >30, 2nd species match <10%.
Output_df.insert(2, 'Genomic QC', '')
Output_df['Genomic QC']=np.where((Output_df['Reads']>= 1000000) & (Output_df['contigs']<= 500) & (Output_df['AvgQual'] >= 30) & (Output_df['%2'] <= 10), 'PASS', 'FAIL' )

## Add MID run and Date of analysis 
current_date = datetime.datetime.today().strftime('%Y-%m-%d')

# Insert the two columns last
Output_df.loc[:, 'Run ID'] = args.mid
Output_df.loc[:, 'Analysis Date'] = current_date

print(Output_df)

## Adding the results to the ongoing result record for E.coli
ongoing_file = '/phe/micro/Escherichia/SAP_Ongoing_Ecoli_compiled_WGS_results.tsv'

## If the ongoing file exists, data is appended, with no repetitive header. If it does not exist, then it creates a new one with header.
if os.path.isfile(ongoing_file):
    Output_df.to_csv(ongoing_file, sep="\t", mode='a', header=False, index=False)
    print(f"{bcolors.OKGREEN}Data from this MID run successfully appended to ongoing file:'{ongoing_file}'{bcolors.ENDC}")
else:
    Output_df.to_csv(ongoing_file, sep="\t", header=True, index=False)
    print(f"'{bcolors.OKGREEN}{ongoing_file}' does not exist. Created it with new data{bcolors.ENDC}")


# Copying the dataframe to a new one to format for per run summary
report_df = Output_df.copy()

## ********************************************************************************************************
### FORMATTING THE DATAFRAME TO CREATE PER RUN REPORT SUMMARY, KEEPING ONE VALID RESULT FROM EACH SAMPLE IF DUPLICATE ISOLATES EXIST.

## Listing the stx gene columns
stx_columns = ['stx1A', 'stx1B', 'stx2A', 'stx2B', 'stxA']

# Creating an exta column to annotate which rows have all stx columns with nil value.
report_df['all_stx_nil'] = report_df[stx_columns].apply(lambda row: all(val == '.' for val in row), axis=1)

# Sorting the dataframe so that rows with all stx columns as "." come last within each Accession ID group
report_df = report_df.sort_values(by=['Accession ID', 'all_stx_nil'])
print("Printing True/False for whether an Accession has no stx genes: ")
print(report_df[['Accession ID', 'all_stx_nil']])

# Dropping duplicates based on Accession ID, keeping the first occurrence (which is NOT all nil i.e. ".")
# Then dropping the helper boolean column, adding analysis date and resetting the index of final dataframe
report_df = report_df.drop_duplicates(subset='Accession ID', keep='first')
report_df = report_df.drop(columns=['all_stx_nil'])
report_df = report_df.reset_index(drop=True)
# report_df.loc[;, 'Analysis Date'] = current_date
print("Final data for reporting (Without multiple isolates for an Accession)")
print(report_df)

## Saving summary for per run
report_df.to_csv(args.out, sep="\t", header=True, index=False)

print(f"{bcolors.OKGREEN}Final result summary for STEC reporting saved to '{args.out}'{bcolors.ENDC}")