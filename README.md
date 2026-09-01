# split-oligo-designer

## Overview

This repository is a fork of the project created by [Tatsuya C. Murakami](https://github.com/tatz-murakami) for designing oligonucleotides for mFISH3D. For the most up-to-date information and database generation, refer to the [original project](https://github.com/tatz-murakami/split-oligo-designer).

The modifications in this fork include:
- A more comprehensive description of how to use the original project.
- A **Dockerfile** for cross-platform compatibility (ARM macOS, x86 Linux, and **Windows**).
- Added support for the **zebrafish transcriptome**.

---

## Install Docker

This project **requires Docker** to run. Install it using the instructions below for your operating system.

---
### On Windows

1. **Install Docker Desktop for Windows**:
   - Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
   - Follow the installation instructions and **restart your computer** when prompted.

2. **Verify Docker Installation**:
   - Open **PowerShell** or **Command Prompt (CMD)**.
   - Run the following command:
     ```powershell
     docker --version
     ```
   - If Docker is installed correctly, you will see output like:
     ```
     Docker version 24.0.7, build afdd53b
     ```

---
### On macOS

1. **Install Docker Desktop for Mac**:
   - Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
   - Open the **Docker Desktop** app and follow the setup instructions.

2. **Verify Docker Installation**:
   - Open a terminal (`Cmd + Space`, type "Terminal", and press Enter).
   - Run:
     ```bash
     docker --version
     ```
   - If installed, you will see the Docker version (e.g., `Docker version 24.0.7, build afdd53b`).

---

## Download and Build

---
### On Windows

1. **Download the Project**:
   - Click the green **<> Code** button on the repository page.
   - Select **Download ZIP** and extract the folder to a location of your choice (e.g., `C:\Users\YourName\Downloads\split-oligo-designer`).

2. **Build the Docker Image**:
   - Open **PowerShell** or **Command Prompt**.
   - Navigate to the project directory:
     ```powershell
     cd C:\Users\YourName\Downloads\split-oligo-designer
     ```
   - Build the Docker image (for Windows, use `--platform linux/amd64` to ensure compatibility):
     ```powershell
     docker build --platform linux/amd64 -t split-oligo-designer .
     ```

3. **Run the Container**:
   - Start the container with:
     ```powershell
     docker run --platform linux/amd64 -p 8888:8888 `
       -v "${PWD}/data:/data" `
       split-oligo-designer
     ```
   - A URL like `http://127.0.0.1:8888/lab?token=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa` will appear in the terminal.
   - Copy and paste this URL into your web browser to access **Jupyter Lab**.
   - Open the `OligoDesign.ipynb` notebook and execute each cell (press `Shift + Enter`).

4. **Clean Up**:
   - When finished, stop and remove the container via **Docker Desktop**:
     - Open Docker Desktop.
     - Go to **Containers**.
     - Stop and delete the `split-oligo-designer` container.
     - *Note*: The Docker image remains on your machine unless manually removed.

---
### On macOS

1. **Download the Project**:
   - Click the green **<> Code** button and select **Download ZIP**.
   - Extract the folder (e.g., to `~/Downloads/split-oligo-designer`).

2. **Build the Docker Image**:
   - Open a terminal and navigate to the project directory:
     ```bash
     cd ~/Downloads/split-oligo-designer
     ```
   - Build the image:
     ```bash
     docker build --platform linux/amd64 -t split-oligo-designer .
     ```

3. **Run the Container**:
   - Start the container:
     ```bash
     docker run --platform linux/amd64 -p 8888:8888 \
       -v "$(pwd)/data:/data" \
       split-oligo-designer
     ```
   - Copy the URL (e.g., `http://127.0.0.1:8888/lab?token=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`) into your browser.
   - Open `OligoDesign.ipynb` and execute each cell (`Shift + Enter`).

4. **Clean Up**:
   - Open **Docker Desktop**, go to **Containers**, and stop/delete the `split-oligo-designer` container.

---
## Parameters

### mFISH3D Parameters
The example parameters for `mFISH3D_param` are shown below:
```python
mFISH3D_param = {
    'fasta': '/data/your_gene/your_gene.fasta',  # Path to your FASTA file (mounted in /data)
    'database': '/data/your_transcriptome/your_transcriptome_db',  # Path to the transcriptome database
    'minimum_offtarget_gap': 100,  # Recommended: 100
    'hcr_seqs': {
        'seq_even_l': 'GAGGAGGGCAGCAAACGGaa',
        'seq_odd_r': 'atGAAGAGTCTTCCTTTACG',
        'seq_even_r': '',
        'seq_odd_l': ''
    },
    'self_remove': True  # Set to True if your template sequence is in the database.
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
