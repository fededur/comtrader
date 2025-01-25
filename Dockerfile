# Base image with R and Shiny server
FROM rocker/shiny:4.3.1 AS base

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV R_REMOTES_NO_ERRORS_FROM_WARNINGS=true

# Install system dependencies for R packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    libicu-dev \
    git \
    --fix-missing --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install remotes package
RUN Rscript -e "install.packages('remotes')"

# Install missing R dependencies
RUN Rscript -e "install.packages(c('dplyr', 'httr', 'lubridate', 'shiny', 'shinydashboard', 'shinyWidgets'), repos = 'https://cloud.r-project.org')"

# Install comtrader package
RUN Rscript -e "remotes::install_github('fededur/comtrader', dependencies = TRUE, upgrade = 'never')"

# Expose the default Shiny server port
EXPOSE 3838

# Set permissions
RUN chown -R shiny:shiny /srv/shiny-server

# Set the Shiny server as the entrypoint
CMD ["R", "-e", "options(shiny.host = '0.0.0.0', shiny.port = 3838); library(comtrader); comtrader::ctdashboard()"]
