# Dockerfile for the pararius scrape app
FROM r-base

MAINTAINER Jasper Ginn "jasperginn@gmail.com"

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    libcurl4-gnutls-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libgit2-dev \
    libpq-dev \
    libxml2-dev \
    python3 
    
# install R packages
RUN R -e "install.packages(c('devtools', 'yaml', 'stringr', 'rvest', 'tibble', 'reticulate'), dependencies = c('Depends', 'Imports'), repos='https://cloud.r-project.org/')"

# Copy application
RUN mkdir /root/pararius
COPY app /root/pararius

# Install listings package
RUN R CMD INSTALL --no-multiarch --with-keep.source /root/pararius/r-package-listings

# Install miniconda
RUN mkdir /root/temp

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

# Installing miniconda (python2.7)
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda2-4.5.4-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# Entrypoint
CMD ["R", "-e", "setwd('/root/data'); source('/root/pararius/main.R')"]