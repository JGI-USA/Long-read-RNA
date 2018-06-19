FROM ubuntu:14.04

LABEL maintainer "Matthew Blow mjblow@lbl.gov"

# System packages 
RUN apt-get update && apt-get install -y curl
RUN apt-get install -y libxau6 libxdmcp6 libxext6

COPY * /usr/local/bin/

# Install miniconda to /miniconda
RUN curl -LO http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh
RUN bash Miniconda-latest-Linux-x86_64.sh -p /miniconda -b
RUN rm Miniconda-latest-Linux-x86_64.sh
ENV PATH=/miniconda/bin:${PATH}
RUN conda update -y conda

# Install packages
RUN conda config --append channels anaconda
RUN conda config --append channels bioconda
RUN conda config --append channels conda-forge
RUN conda config --append channels agbiome

RUN conda install minimap2 bedtools samtools htsbox java-jdk bbtools perl ucsc-gff3togenepred ucsc-genepredtobed genometools-genometools

# Setup application
#ENTRYPOINT ["/miniconda/bin/python", "/imgsrv.py"]
#EXPOSE 8080
