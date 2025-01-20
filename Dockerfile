# Use the Rocker Shiny base image
FROM rocker/shiny:latest

# Install system dependencies for R packages
RUN apt-get update && apt-get -y --no-install-recommends install \
        libxml2-dev \
        libcairo2-dev \
        libsqlite3-dev \
        libpq-dev \
        libssh2-1-dev \
        unixodbc-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        git && \
    apt-get clean

# Clone the comtrader repository
RUN git clone https://github.com/fededur/comtrader.git /tmp/comtrader

# Build the package and install it
RUN R CMD build /tmp/comtrader && \
    R CMD INSTALL /tmp/comtrader/comtrader_0.1.0.tar.gz

# Install additional R dependencies (if required)
RUN R -e "install.packages(c('dplyr', 'httr', 'lubridate', 'shiny', 'shinydashboard', 'shinyWidgets'), repos = 'https://cloud.r-project.org')"

# Run the Shiny app
CMD ["R", "-e", "comtrader::ctdashboard()"]

