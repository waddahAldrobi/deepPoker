from xml.etree import ElementTree
import math
import cv2

import pandas as pd
import os.path

# Might be useful for refrence
#names = {0:"Ca", 1:"C2", 2:"C3",3:"C4",4:"C5",5:"C6",6:"C7", 7:"C8", 8:"C9", 9:"C10",10:"Cj", 11:"Cq", 12:"Ck", 13:"Da", 14:"D2", 15:"D3",16:"D4",17:"D5",18:"D6",19:"D7", 20:"D8", 21:"D9", 22:"D10",23:"Dj", 24:"Dq", 25:"Dk"}


def convertToCSV(fpath, fname):

    tree = ElementTree.parse(fpath+fname+".xml")
    root = tree.getroot()
    biglist = []
    
    id = 0
    for child in root.findall('object'):
        name = child.find('name').text

        id += 1
    
        for subchild in child.findall('bndbox'):
            xmin = subchild.find('xmin').text
            xmax = subchild.find('xmax').text

            ymin = subchild.find('ymin').text
            ymax = subchild.find('ymax').text

        xmin = int(xmin)
        xmax = int(xmax)
        ymin = int(ymin)
        ymax = int(ymax)

        mylist = [fname+".jpg", id, name, xmin, xmax, ymin, ymax]
        biglist.append(mylist)


    
    df=pd.DataFrame(biglist,columns=['image','id','name','xMin','xMax', 'yMin', 'yMax'])

    df.to_csv('/Users/waddahaldrobi/Desktop/Cards/foldedCsv/'+fname+'.csv', index=False, header=True)

from os import listdir
from os.path import isfile, join
mypath = '/Users/waddahaldrobi/Desktop/Cards/foldedData/'
files = [f for f in listdir(mypath) if isfile(join(mypath, f))]

for i in files:
    if i != ".DS_Store" and i[-4:] == ".xml" :
        print("Done page: "  + str(i))
        convertToCSV(mypath, i[:-4])
