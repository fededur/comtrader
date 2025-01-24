# Base image with R and Shiny server
FROM rocker/shiny:4.3.1

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV R_REMOTES_NO_ERRORS_FROM_WARNINGS=true

# Install system dependencies for R packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    pandoc \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R package dependencies (including remotes)
RUN Rscript -e "install.packages('remotes')"

# Install the comtrader package from GitHub without prompts
RUN Rscript -e "remotes::install_github('fededur/comtrader', dependencies = TRUE, upgrade = 'never')"

# Expose the default Shiny server port
EXPOSE 3838

# Set permissions (required for the Shiny server)
RUN chown -R shiny:shiny /srv/shiny-server

# Set the Shiny server as the entrypoint
CMD ["R", "-e", "comtrader::ctdashboard()"]
