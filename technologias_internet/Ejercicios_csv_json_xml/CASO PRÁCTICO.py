#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May 11 11:55:32 2020

@author: Pedro_Martínez
"""

import pandas as pd
from collections import Counter
from timeit import default_timer as timer

data = pd.read_csv('PitchingPost.csv')
freq_list = ['playerID', 'yearID']
def frequency(data,column):
    freq =pd.DataFrame.from_dict(Counter(data[column]),orient='index')
    
    start=timer()
    freq.index.names=[column.strip('ID')]
    end= timer()
    print('.index.names= ',end-start,' s')
    
    freq.rename_axis(column.strip('ID'), axis='index', inplace=True)
    end1= timer()
    print('.rename_axis(' '): ',end1-end,' s')
    freq.columns = ['Frequency']
    freq.to_csv(f'{column}_frequences.csv')
    
for elem in freq_list:
    frequency(data,elem)