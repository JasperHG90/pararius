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
    libxml2-dev
    
# install R packages
RUN R -e "install.packages(c('devtools', 'yaml', 'gmailr'), dependencies = c('Depends', 'Imports'), repos='https://cloud.r-project.org/')"

RUN R -e "install.packages(c('loggit'),repos='https://cloud.r-project.org/')"

RUN R -e "install.packages(c('stringr'), dependencies = c('Depends', 'Imports'), repos='https://cloud.r-project.org/')"

RUN R -e "install.packages(c('rvest'), dependencies = c('Depends', 'Imports'), repos='https://cloud.r-project.org/')"

RUN R -e "install.packages(c('tibble'), dependencies = c('Depends', 'Imports'), repos='https://cloud.r-project.org/')"

# Copy application
RUN mkdir /root/pararius
COPY app /root/pararius

# Install listings package
RUN R CMD INSTALL --no-multiarch --with-keep.source /root/pararius/r-package-listings

# Entrypoint
CMD ["R", "-e", "setwd('/root/data'); source('/root/pararius/main.R')"]