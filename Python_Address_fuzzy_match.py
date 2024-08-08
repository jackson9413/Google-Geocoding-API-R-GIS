#pip install fuzzywuzzy
import pandas as pd
import numpy as np
import os
from fuzzywuzzy import fuzz

os.chdir("xxxxxx") # CHANGE TO YOUR WORKING DIRECTORY
df = pd.read_csv("xxxxxxx", encoding="latin-1") # CHANGE TO YOUR OWN FILE NAME WHICH CONTAINS THE ORIGINAL ADDRESS AND GOOGLE GEOCODED ADDRESS

# choose "set_ratio" to compare all the rows 
ratio = []
for i in range(len(df)):
    result = fuzz.token_set_ratio(df.iloc[i]["full_address"], df.iloc[i]["formatted_address"])
    ratio.append(result)
df["Ratio"] = ratio
df.to_csv('xxxxxxxxxxx', index=False) # NAME YOUR OWN FILE WHICH CONTAINS THE ORIGINAL ADDRESS, GOOGLE GEOCODED ADDRESS AND RATIO