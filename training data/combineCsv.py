import pandas as pd
from os import listdir
from os.path import isfile, join
import sys


mypath = '/Users/waddahaldrobi/Desktop/Cards/xCSV/'
files = [f for f in listdir(mypath) if isfile(join(mypath, f))]

bigDf = []
id = 1
for i in files:
    if i != ".DS_Store": 
        df1 = pd.read_csv(mypath+i)
#        for c, j in enumerate(df1["name"]):
#            df1["name"][c] = names[j]
        for c, k in enumerate(df1["id"]):
            df1["id"][c] = id
            id += 1

        bigDf.append(df1)
        print("Done:", i)

df_combined = pd.concat(bigDf,axis=0)
df_combined.to_csv('annotations.csv', index=None)

