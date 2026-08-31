# split-oligo-designer

## Overview

This repository is a fork of the project created by Tatsuya C. Murakami for designing oligonucleotides for [mFISH3D](https://github.com/tatz-murakami/split-oligo-designer). For the most up-to-date informations, databases generation, refer to the original project.

The modifications include a more comprehensive description of how to use the original project, a docker file so that it can more easily be used among different plateforms (arm macOS, and x86 machines) along with the added zebrafish transcriptome.

## Install Docker

This repository required Docker

### On Windows

To verify that Docker is installed, open 
```
$ 
```
### On macOS

To verify that Docker is installed, open a terminal (cmd+space barre, then type terminal and Enter). Write the next command and Enter:
'''
(base) User@MacBook path % docker --version
'''
If no version appear, follow the instruction on the Docker website to install it.

## Donwload and build

### On Windows

Download the project (click on the green <>Code button, then download ZIP), and unzip it. 

### On macOS

Download the project (click on the green <>Code button, then download ZIP), and unzip it. Open a terminal, the text should look like this:
'''
(base) User@MacBook ~ % 
'''

Enter this command to change the path the terminal has access to, change the path according to where the project folder is:
'''
(base) User@MacBook ~ % cd /Users/user/Downloads/split-oligo-designer
'''
The text shown in the terminal should change to 
'''
(base) User@MacBook split-oligo-designer % 
'''

Then enter:
'''
docker build --platform linux/amd64 -t split-oligo-designer .  
'''
Once the docker image is build, enter
'''
docker run --platform linux/amd64 -p 8888:8888 \
  -v "$(pwd)/data:/data" \
  split-oligo-designer
'''
A url appears (smiliar to http://127.0.0.1:8888/lab?token=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa), copy and paste it in a browser. Within Jupyter lab, double clisk on the OligoDesign.ipynb file. Execute each code cell (shift+Enter) while modifying the arguments according to your need. 

Once docker is not needed anymore, open the docker desktop dashboard, go to container, stop and delete the split-oligo-designer container. Know that the base image is still present on your machine.

## Parameters
The example of the parameters are shown below.
```python
mFISH3D_param = {
    'fasta':'/home/tmurakami/src/split-oligo-designer/data/slc17a7/slc17a7_hs.fasta',
    'database':'/home/tmurakami/src/split-oligo-designer/data/human_transcriptome/human_transcriptome_db',
    'minimum_offtarget_gap':100,
    'hcr_seqs':{
            'seq_even_l':'GAGGAGGGCAGCAAACGGaa',
            'seq_odd_r':'atGAAGAGTCTTCCTTTACG',
            'seq_even_r':'',
            'seq_odd_l':''
        },
    'self_remove': True # set this True if your template sequence appears in database.
}
```

`minimum_offtarget_gap`
If the gap between two non-specific binding is more than minimum_offtarget_gap, the pair is not regarded to cause a off-target signal. Recommended value: 100.

`hcr_seqs`
The sequences of HCR fragments. The example design can be found in `./oligodesigner/parameters.py`

`self_remove` 
Set self_remove True if you want to remove the template sequence from
off-target analysis. Otherwise, the gene of your interest could be regarded as an off-target product.
Turn this to False when your template is not found in database (e.g. GFP).



The code requires the parameters for OligoMiner. The example is below.
```python
oligominer_param = {
    'l':20,
    'L':20,
    'gcPercent':25,
    'GCPercent':75,
    'tm':20,
    'TM':100,
    'X':'AAAAAA,TTTTTT,CCCCCC,GGGGGG',
    'sal':390,
    'form':30,
    'sp':1,
    'concA':25,
    'concB':25,
    'headerVal':None,
    'bedVal':False,
    'OverlapModeVal':False,
    'verbocity':False,
    'reportVal':True,
    'debugVal':False,
    'metaVal':False,
    'outNameVal':None,
    'nn_table':'DNA_NN3'
}
```


## Selection
You will obtain multiple output files including output files from OligoMiner. The final sequences are found in (your_fasta_name)_oligosets.csv.  
The file contains the binding sequences with HCR reaction sites. You may need to further select the oligonucleotides. Since the choice of the number of oligos, binding positions, and combinations are highly dependent on the scientific question, the size of mRNA, and the research budget, I intentionally did not automate this selection process.  
My recommended workflow for the selections of oligo is as follows:
1. If the number of oligos in the oligosets.csv is less than 24 (12 pairs), select all oligos.  
2. If the number is more than 24, you may want to narrow down the binding positions. In my experience, I have never seen a situation where you need more than 48 oligos. To narrow down the binding positions, survey the past FISH literature that provides the oligonucleotide sequence of your interest. For mouse and human brain, Allen Brain ISH database (https://mouse.brain-map.org/ or https://human.brain-map.org/ish/search) is a good place to start. Use the binding positions where the past literature has used, and exclude the oligos which do not bind to the positions. If there are no past literature available, skip this step.
3. Select the oligos with the small intervals. "interval_after" indicates the distance between the oligo and the next oligo. You should select 24 to 48 oligos while keeping the intervals as small as possible. 
4. If you could not get 24 oligos after the step 2 and 3, include oligos you have disregarded. The step 2 and 3 are not the absolute criteria. You can relax the selection criteria until you get 24 oligos.

## Citation

> Murakami and Heintz. Multiplexed and scalable cellular phenotyping toward the standardized three-dimensional human neuroanatomy. bioRxiv (2022) https://doi.org/10.1101/2022.11.23.517711 

> Beliveau, B.J., Kishi, J.Y., Sasaki, H.M. et al. OligoMiner provides a rapid, flexible environment for the design of genome-scale oligonucleotide in situ hybridization probes. PNAS (2018) https://doi.org/10.1073/pnas.1714530115
	


## License

We provide this open source software without any warranty under the [MIT license](https://opensource.org/licenses/MIT).
