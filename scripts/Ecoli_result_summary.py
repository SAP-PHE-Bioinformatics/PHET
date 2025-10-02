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
from pandas import ExcelWriter

# Defining ANSI escape sequences for colors for print messages
class bcolors:
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    OKYELLOW = '\033[93m'
    OKRED = '\033[91m'
    OKPINK = '\033[95m'  
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
parser.add_argument('--routine', '-r', action='store_true', help='If routine analysis, data is appended to ongoing record of E.coli sequence results')


args = parser.parse_args()
print(args)

##################################################################
# READING INPUT FILES, SELECTING AND FORMATTING DATA FOR REPORTING
##################################################################

### Read QC file, select and rename specific columns
QC_sum = pd.read_csv(args.qc, sep='\t')
QC_sum = QC_sum.loc[:,['SeqID', 'Reads', 'AvgQual', 'no', '#1 Match', '%1', '#2 Match', '%2', '#3 Match', '%3', 'scheme', 'ST']]
QC_sum = QC_sum.rename({'SeqID': 'Seq_ID', 'no': 'contigs', 'ST':'MLST'}, axis =1)

### Selecting ALL E. coli results from QC_summary
QC_sum_ec = QC_sum[QC_sum['#1 Match'].str.contains('Escherichia', case=False)]

# Removing any NEG or POS control if they got selected due to E. coli being the top match
QC_sum_ec = QC_sum_ec[~QC_sum_ec['Seq_ID'].str.contains('NEG|POS', case=False)]

print(f"{bcolors.BOLD} {bcolors.UNDERLINE}\nE. coli results found in {args.mid}: {bcolors.ENDC}\n {QC_sum_ec} ")

### Read Virulome file
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

### Read Ectyper output, select and rename columns
EC = pd.read_csv(args.ec, sep='\t')
EC = EC.loc[:,['Name', 'O-type', 'H-type', 'Serotype']]
EC = EC.rename({'Name': 'Seq_ID'}, axis =1)


### Read Clermont typing output and write column headers (Based on github read.me page of the tool)
# Removing string from file name and selecting columns of interest
CL_colnames = ['Seq_ID', 'genes detected', 
    'presence(+)/absence(-) for 4 genes arpA, chuA, yjaA and TspE4.C2', 
    'alleles specific for groups C and E', 'Phylogroup', 'mash file']
CL = pd.read_csv(args.cl, sep='\t', names=CL_colnames)
CL['Seq_ID'] = CL['Seq_ID'].str.replace(r'.fna', '')
# print(CL)
CL = CL.loc[:,['Seq_ID', 'Phylogroup']]
# print(CL)

########################################################################################################
# Compiling results from multiple inputs into one dataframe and formatting- first stage of output table
########################################################################################################

# Join QC summary and Ectyper output first - changed to left instead of inner to retain the qc fail as well.
compiled_EC_results_df = pd.merge(QC_sum_ec, EC, on='Seq_ID', how='left')

# Joining remaining files
CL_vir_files = [CL, virulence]
for i in CL_vir_files:
    compiled_EC_results_df = pd.merge(compiled_EC_results_df, i, on='Seq_ID', how='left')

# Changing contig number values to whole numbers            
# compilgs_EC_results_df['contigs'] = compiled_EC_results_df['contigs'].apply(lambda x: int(round(x, 0)))
compiled_EC_results_df['contigs'] = compiled_EC_results_df['contigs'].astype('Int32')

# Adding Accession ID column to be extracted from seq_IDs
# Function to format the 'Accession ID' with hyphens
def format_accession_id(seq_id):
    accession_id = seq_id[:10]
    return f"{accession_id[:2]}-{accession_id[2:5]}-{accession_id[5:]}"

# compilgs_EC_results_df['Accession ID'] = compiled_EC_results_df['Seq_ID'].apply(lambda x: x[:10]) <<-- if Accession number is required without hyphens

# Populating accession from seq_ID with hyphens.
compiled_EC_results_df.insert(0, 'Accession ID', '')
compiled_EC_results_df['Accession ID'] = compiled_EC_results_df['Seq_ID'].apply(lambda x: format_accession_id(x))


###########################################################
# Extracting results of POS and NEG controls in the WGS run
# Applying QC checks to Pass/Fail/Review the controls.       
###########################################################

### Selecting QC sum of neg and pos control sequences
QC_sum_controls = QC_sum[QC_sum['Seq_ID'].str.contains('NEG|POS', case=False)]
# Strip whitespace from all string/object columns in the DataFrame
QC_sum_controls = QC_sum_controls.applymap(lambda x: x.strip() if isinstance(x, str) else x)

# print(f" \n {bcolors.BOLD} {bcolors.UNDERLINE} NTC and POS control samples included in {args.mid}: {bcolors.ENDC}\n {QC_sum_controls}")

# Inserting a genomic QC column to populate qc results for controls
QC_sum_controls.insert(1, 'Genomic QC', '')


####################################################################################
## Selecting NEG controls and applying specific QC crtieria specific to NEG controls
####################################################################################

select_neg_controls = QC_sum_controls['Seq_ID'].str.contains("neg", case=False)
## Setting conditions for two scenarios that can fail NEG control
###### 1 - Reads >5000, and top match is E.coli
QC_sum_controls.loc[select_neg_controls, 'Genomic QC'] = np.where(
    (QC_sum_controls.loc[select_neg_controls, 'Reads'] > 5000) &
    (QC_sum_controls.loc[select_neg_controls, '#1 Match'] == "Escherichia coli") |
###### 2 - OR - Reads >5000, 2nd Match is Escherichia coli and >10%
    (QC_sum_controls.loc[select_neg_controls, 'Reads'] > 5000) &
    (QC_sum_controls.loc[select_neg_controls, '#2 Match'] == "Escherichia coli") &
    (QC_sum_controls.loc[select_neg_controls, '%2'] >= 10.0),
    'FAIL',
    'PASS'
)

####################################################
## Selecting POS controls and applying QC criteria
####################################################

select_pos_controls = QC_sum_controls['Seq_ID'].str.contains("pos", case=False)

# Conditions to Fail POS control
species_id_columns = ['#1 Match', '#2 Match', '#3 Match']

# Defining conditions for Pos control Fail below: 
# - If first match is E. coli (regardless of read count)
# - If second or third match are E.coli at or greater than 10% (regardless of read count)

pos_species_check = (
    (QC_sum_controls['#1 Match'] == 'Escherichia coli')
) | (
    (QC_sum_controls['#2 Match'] == 'Escherichia coli') & (QC_sum_controls['%2'] >= 10.0)
) | (
    (QC_sum_controls['#3 Match'] == 'Escherichia coli') & (QC_sum_controls['%3'] >= 10.0) 
)

# Combining 'FAIL' conditions with 'REVIEW' conditions into a list
# REVIEW - if Pos does not match the minimum read count or has higher than 500 contig
conditions = [
    pos_species_check,
    ((QC_sum_controls['Reads'] < 1000000) | (QC_sum_controls['contigs'] > 500))
]

choices = ['FAIL', 'REVIEW with PHE']

## Determining genomic QC for POS controls as FAIL or REVIEW based on above conditions; default is 'PASS'
QC_sum_controls.loc[select_pos_controls, 'Genomic QC'] = np.select(
    [c[select_pos_controls] for c in conditions],
    choices,
    default='PASS'
)

## Add comments relevant to the QC criteria
qc_criteria_comments = {'FAIL' : "E.coli detected in top 3 species match", 
                        'REVIEW with PHE' : "Low read count or high contig count"}
QC_sum_controls.insert(2, 'QC_Comments', '')

QC_sum_controls['QC_Comments'] = QC_sum_controls['Genomic QC'].map(qc_criteria_comments).fillna('')

print(f"\n{bcolors.BOLD} {bcolors.UNDERLINE}QC assessed NTC and POS controls included in {args.mid}: {bcolors.ENDC}\n {QC_sum_controls}")

#####################################################################################################
# Adding RunQC column to E.coli sample results; FAIL is any of the controls fail or review, else PASS
#####################################################################################################

## Selecting SeqID of any control if it is NOT PASS.
failed_controls = QC_sum_controls.loc[QC_sum_controls['Genomic QC'] != 'PASS', 'Seq_ID']
## If no control failed, Run QC is marked as PASS. else FAIL with a comment referencing SEQID of failed control.
compiled_EC_results_df.insert(2, 'Run QC', '')
if failed_controls.empty:
    compiled_EC_results_df['Run QC'] = 'PASS'
else:
    fail_message = 'FAIL; Check ' + ', '.join(failed_controls)
    compiled_EC_results_df['Run QC'] = fail_message

# print(compiled_EC_results_df)

#############################################################################################
## Adding 'Genomic QC' column for E.coli results, populating as PASS/FAIL based on conditions
#############################################################################################

# PASS if Reads > 1 million, contigs < 500, AvgQual >30, 2nd species match <10%.
compiled_EC_results_df.insert(3, 'Sample QC', '')
compiled_EC_results_df['Sample QC']=np.where((compiled_EC_results_df['Reads']>= 1000000) & (compiled_EC_results_df['contigs']<= 500) 
                                 & (compiled_EC_results_df['AvgQual'] >= 30) & (compiled_EC_results_df['%2'] < 10), 'PASS', 'FAIL')

## Add MID run and Date of analysis 
current_date = datetime.datetime.today().strftime('%Y-%m-%d')

## Insert the two columns last
compiled_EC_results_df.loc[:, 'Run ID'] = args.mid
compiled_EC_results_df.loc[:, 'Analysis Date'] = current_date

print(f"\n{bcolors.BOLD} {bcolors.UNDERLINE}QC checked results for E.coli {args.mid}: {bcolors.ENDC}\n {compiled_EC_results_df}")


###################################################################################################
# Separate the QC FAILED & PASSED samples from the compiled_EC_results into two separate dataframes
###################################################################################################

## QC FAILED
failed_ecoli_seqs = compiled_EC_results_df.loc[compiled_EC_results_df['Sample QC'] != 'PASS']
### Function to set up corresponding comments for each QC criteria if there are any failed ecoli.
# Define the fail conditions and corresponding comments

def qc_comment(row):
    reasons = []
    if pd.isna(row['Reads']) or row['Reads'] < 1000000:
        reasons.append('Low read count')
    if pd.isna(row['contigs']) or row['contigs'] > 500:
        reasons.append('High contig count or missing')
    if pd.isna(row['AvgQual']) or row['AvgQual'] < 30:
        reasons.append('Low average quality')
    if pd.isna(row['%2']) or row['%2'] > 10:
        reasons.append('High % of 2nd species match - Potential contamination')
    return ', '.join(reasons) if reasons else ''

# Adding genomic comment and only selecting relevant final columns.
failed_ecoli_seqs.insert(4, 'Sample QC Comments', '')
failed_ecoli_seqs = failed_ecoli_seqs.copy() # creating a copy of the dataframe to avoid setwithcopy warning
failed_ecoli_seqs['Sample QC Comments'] = failed_ecoli_seqs.apply(qc_comment, axis=1)
failed_ecoli_seqs = failed_ecoli_seqs[["Accession ID", "Seq_ID", "Run QC", "Sample QC", "Sample QC Comments", "Reads", "AvgQual", "contigs", "#1 Match", "%1", "#2 Match", "%2", "#3 Match", "%3"]]

print(f"\n{bcolors.OKRED}{bcolors.BOLD}{bcolors.UNDERLINE}QC FAILED E.coli in {args.mid}:{bcolors.ENDC}\n {bcolors.OKRED}{bcolors.BOLD}{failed_ecoli_seqs} {bcolors.ENDC}")

## QC PASSED
passed_ecoli_seqs = compiled_EC_results_df[compiled_EC_results_df['Sample QC'] == 'PASS']
print(f"\n{bcolors.BOLD}{bcolors.OKGREEN}{bcolors.UNDERLINE}QC PASSED E.coli in {args.mid}:{bcolors.ENDC}\n{bcolors.BOLD} {bcolors.OKGREEN}{passed_ecoli_seqs} {bcolors.ENDC}")

#####################################################################################
### FORMATTING THE DATAFRAME TO CREATE PER RUN REPORT SUMMARY
### KEEPING ONE VALID RESULT FROM EACH SAMPLE IF DUPLICATE ISOLATES EXIST.
#####################################################################################

# Copying the dataframe to a new one to format for per run summary
QcPass_EC_report_df = passed_ecoli_seqs.copy()

## Listing the stx gene columns
stx_columns = ['stx1A', 'stx1B', 'stx2A', 'stx2B', 'stxA']

# Creating an exta column to annotate which rows have all stx columns with nil value.
QcPass_EC_report_df['all_stx_nil'] = QcPass_EC_report_df[stx_columns].apply(lambda row: all(val == '.' for val in row), axis=1)

# Sorting the dataframe so that rows with all stx columns as "." come last within each Accession ID group
QcPass_EC_report_df = QcPass_EC_report_df.sort_values(by=['Accession ID', 'all_stx_nil'])
print("Printing True/False for whether an Accession has no stx genes: ")
print(QcPass_EC_report_df[['Accession ID', 'all_stx_nil']])

# # Dropping duplicates based on Accession ID, keeping the first occurrence (which is NOT all nil i.e. ".")
# # Then dropping the helper boolean column, adding analysis date and resetting the index of final dataframe
# QcPass_EC_report_df = QcPass_EC_report_df.drop_duplicates(subset='Accession ID', keep='first')
QcPass_EC_report_df = QcPass_EC_report_df.drop(columns=['all_stx_nil'])
# QcPass_EC_report_df = QcPass_EC_report_df.reset_index(drop=True)

# Sorting the dataframe by length of string in Seq_ID column to keep non-STEC E.coli at the bottom of list for easy sorting
QcPass_EC_report_df.index = QcPass_EC_report_df['Seq_ID'].str.len()
QcPass_EC_report_df = QcPass_EC_report_df.sort_index(ascending=False).reset_index(drop=True)

# QcPass_EC_report_df.loc[;, 'Analysis Date'] = current_date
print(f"\n{bcolors.BOLD}{bcolors.UNDERLINE}{bcolors.OKGREEN}Final data for reporting (Without multiple isolates for an Accession){bcolors.ENDC}")
print(QcPass_EC_report_df)

################################
# ## Saving summary for per run
################################

## Highlighting if RUNQC failed in ecoli passed dataframe
# def highlight_rows_RunQcFail(val):
#     return 'background-color: #FF5C5C' if 'FAIL' in str(val) else ''
def highlight_rows_RunQcFail(row):
    if 'FAIL' in str(row['Run QC']):
        return ['background-color: #FF5C5C'] * len(row)
    else:
        return [''] * len(row)

# Apply only to the 'Run QC' column
styled_QcPass_EC_report = QcPass_EC_report_df.style.apply(highlight_rows_RunQcFail, axis = 1)

## FORMATTING FOR POS/NEG CONTROLS
def highlight_failed_controls(row):
    style = {}
    qc_val = str(row['Genomic QC'])
    
    if 'FAIL' in qc_val:
        color = 'background-color: #FF5C5C'  # red
    elif 'REVIEW' in qc_val:
        color = 'background-color: #FFFF8A'  # yellow
    else:
        color = ''
    
    # Applying color to both target columns
    style['Genomic QC'] = color
    style['QC_Comments'] = color
    return pd.Series(style)

# Applying row-wise styling
styled_QC_sum = QC_sum_controls.style.apply(highlight_failed_controls, axis=1, subset=['Genomic QC', 'QC_Comments'])

## Saving the report to excel
excel_report = args.out
with pd.ExcelWriter(excel_report) as writer:
    styled_QcPass_EC_report.to_excel(writer, sheet_name='Sample QC - PASS', index = False)
    failed_ecoli_seqs.style.applymap(lambda _: 'color: #e21b32').to_excel(writer, sheet_name='Sample QC - FAIL', index = False)
    styled_QC_sum.to_excel(writer, sheet_name='RUN QC (Pos_Neg Controls)', index = False)

print(f"{bcolors.OKYELLOW}Final result summary for STEC reporting saved to '{args.out}'{bcolors.ENDC}")

#********************************************************************************************************

#######################################################################################################
# Adding the results to the ongoing result record for E.coli if user runs the script in routine mode  #
#######################################################################################################
ongoing_file = '/phe/micro/Escherichia/SAP_Ongoing_Ecoli_compiled_WGS_results.tsv'

if args.routine:
    ## If the ongoing file exists, data is appended, with no repetitive header. If it does not exist, then it creates a new one with header.
    if os.path.isfile(ongoing_file):
        compiled_EC_results_df.to_csv(ongoing_file, sep="\t", mode='a', header=False, index=False)
        print(f"\n{bcolors.OKCYAN}Data from this MID run successfully appended to ongoing file: '{ongoing_file}'{bcolors.ENDC}")
    else:
        compiled_EC_results_df.to_csv(ongoing_file, sep="\t", header=True, index=False)
        print(f"'{bcolors.OKGREEN}{ongoing_file}' does not exist. Created it with new data{bcolors.ENDC}")
else:
    print(f"\n{bcolors.OKPINK}NOTE: User did not specify '--routine/-r' mode, therefore NOT appending results from {args.mid} to '{ongoing_file}' {bcolors.ENDC}")
#********************************************************************************************************
