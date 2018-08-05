# Dockerfile for the pararius scrape app
FROM openanalytics/r-base

MAINTAINER Jasper Ginn "jasperginn@gmail.com"

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    libcurl4-gnutls-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0 \
    libgit2-dev \
    libpq-dev
    
# Install java
RUN apt-get install -y \ 
    default-jre \
    default-jdk
    
# Make sure that R can find java 
RUN R CMD javareconf

# install R packages
RUN R -e "install.packages(c('devtools', 'yaml', 'mailR'), repos='https://cloud.r-project.org/')"

# Copy application
RUN mkdir /root/pararius
COPY app /root/pararius

# Install listings package
RUN R CMD INSTALL --no-multiarch --with-keep.source /root/pararius/r-package-listings

# Entrypoint
CMD ["R", "-e", "main.R"]