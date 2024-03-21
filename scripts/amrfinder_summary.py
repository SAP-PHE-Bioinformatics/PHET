#!/usr/bin/env python

#import libraries

import os
import sys
import pandas as pd
import numpy as np
from datetime import datetime
from pathlib import Path

# passing the location of files from the parent amrfinder.sh script
files_dir=sys.argv[1]

#listing name of the files
files = os.listdir(files_dir)

#empty list to store the path to files

path_to_files = []

for file in files:
    path_to_files.append(files_dir + file)

#using loop to read each file using pandas

all_files = []

for f in path_to_files:
    df = pd.read_csv(f, sep ="\t")
    df.columns = df.columns.str.strip()
    all_files.append(df)


#removing empty dataframes from the list

for i in range(len(all_files) -1, 0, -1):
    if all_files[i].empty:
        del all_files[i]

print(all_files)

# filtering data

selected_data = []

for data in all_files:
    d = data.loc[:,['Name', 'Gene symbol', 'Class', '% Coverage of reference sequence']]
    d['Name'] = d['Name'].astype(str)    
    d['Name'] = data['Name'].str.split('_').str[0]
    d.rename(columns={"% Coverage of reference sequence":"Coverage", "Gene symbol":"Gene"}, inplace = True)
    selected_data.append(d)

# transposing the data by setting index and unstacking

transposed_df = []

# for df in selected_data:
#     df2 = df.set_index(['Name', 'Gene'], append=False).Coverage.unstack()
#     transposed_df.append(df2)

# for df in selected_data:
#     df2 = df.pivot_table(index = 'Name', columns='Gene', values='Coverage')
#     transposed_df.append(df2)

for df in selected_data:
    df2 = df.pivot_table(index = 'Name', columns='Gene', values='Coverage', aggfunc='first')
    df2.insert(0, "Gene_count", df2.count(axis=1), True)
    transposed_df.append(df2)
    print(transposed_df)
    
# creating one big summary
transposed_df = [df for df in transposed_df if df is not None and not df.empty]


concatdf = pd.DataFrame()
concatdf = concatdf.append(transposed_df, ignore_index=False)
concatdf = concatdf.fillna('-', axis=1)


sorteddf = concatdf.sort_index().sort_index(axis=1)


# writing to a file

# dateToday = datetime.now().strftime('%Y%m%d')
# filename = f'amrfinder_summary_{dateToday}.tsv'

filename = 'amrfinder_summary.tsv'


sorteddf.to_csv((filename), sep = "\t", index = True)