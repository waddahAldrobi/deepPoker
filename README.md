# DeepPoker


This repository has been made to help anyone who is trying to build a CoreML model for an iOS app. <br/>
In this project I have labelled a set of card images using RectLabel on a mac and have provided a script in ``` xmlTOcsv.py``` to parse Rectlabel's output to the expected TuriCreate format<br/>
<br/>

## Getting started

If you have not already labelled your image to build a model, this is the first thing I would do. (Or use a labelled public set if this is just for experimentation)<br/>
<br/>
Then convert them to the csv format that TuriCreate is expecting.<br/>
You can use ``` combineCsv.py``` if you have a collection of CSV annotaitions.<br/>

Finally in ```prep.py``` change  ```IMAGES_DIR``` and  ```csv_path``` to meet your data setup.<br/>
And then run ```prep.py```<br/>
<br/>

```prep.py``` will export a  ```.sframe``` file. <br/>
In ```train.py``` change the directory of the  ```data``` variable to point to your  ```.sframe``` file. <br/>
Finally, run ```train.py```

## Demo of the DeepPoker App


