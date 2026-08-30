# syntax=docker/dockerfile:1

##############################################################################
# split-oligo-designer
# Reproduces the Ubuntu 20.04 / conda "oligo" env from the repo, plus
# BLAST+ 2.13.0 exactly as required by the software prerequisites.
#
# Built for linux/amd64 on purpose: NCBI only publishes official BLAST+
# 2.13.0 binaries for x86_64 Linux. Docker Desktop on Apple Silicon and on
# Windows/ARM both emulate linux/amd64 transparently, so this runs fine on
# your ARM Mac — just build/run with --platform linux/amd64 (see notes below).
##############################################################################

FROM --platform=linux/amd64 condaforge/miniforge3:24.9.2-0

LABEL maintainer="you@example.com" \
      description="split-oligo-designer (oligo design for split HCR) with BLAST+ 2.13.0"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# --- OS packages: build tools (biopython/mygene deps compile some C ext) ---
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        wget \
        ca-certificates \
        git \
        perl \
    && rm -rf /var/lib/apt/lists/*

##############################################################################
# 1. Install BLAST+ 2.13.0 (official NCBI Linux x86_64 build)
##############################################################################
ENV BLAST_VERSION=2.13.0
RUN wget -q https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/${BLAST_VERSION}/ncbi-blast-${BLAST_VERSION}+-x64-linux.tar.gz \
    && tar -xzf ncbi-blast-${BLAST_VERSION}+-x64-linux.tar.gz -C /opt \
    && rm ncbi-blast-${BLAST_VERSION}+-x64-linux.tar.gz

ENV PATH="/opt/ncbi-blast-${BLAST_VERSION}+/bin:${PATH}"

##############################################################################
# 2. Clone the repo and build the conda env from environment.yml
##############################################################################
WORKDIR /app
RUN git clone https://github.com/Aymnad/split-oligo-designer.git .

# Create the "oligo" conda env exactly as environment.yml specifies
RUN conda env create -f environment.yml \
    && conda clean -afy

# Make sure the env is used everywhere from here on (RUN, CMD, ENTRYPOINT)
SHELL ["conda", "run", "--no-capture-output", "-n", "oligo", "/bin/bash", "-c"]

# Install oligodesigner itself into the env, as the README instructs
RUN pip install .

##############################################################################
# 3. Runtime setup
##############################################################################
# Somewhere to mount your BLAST databases / fasta templates from the host
RUN mkdir -p /data
VOLUME ["/data"]

EXPOSE 8888

# Drop back to a normal shell for CMD, but still auto-activate "oligo"
SHELL ["/bin/bash", "-c"]
RUN echo "conda activate oligo" >> ~/.bashrc

# Launch Jupyter Lab (used to run OligoDesign.ipynb) by default.
# --allow-root because containers commonly run as root.
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "oligo"]
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]