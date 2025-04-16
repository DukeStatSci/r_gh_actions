FROM rocker/r2u:latest

#ADD Rprofile.site /usr/lib/R/etc/Rprofile.site

RUN apt-get update \
 && apt-get upgrade -y

RUN apt-get install -y --no-install-recommends \
    libudunits2-dev libgdal-dev libgeos-dev \
    libproj-dev pandoc libmagick++-dev \
    libglpk-dev libnode-dev \
    wget git rsync \
    && sed 's/value="1GiB"/value="8GiB"/1' /etc/ImageMagick-6/policy.xml > /etc/ImageMagick-6/policy.xml

RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.6.42/quarto-1.6.42-linux-amd64.deb \
    && DEBIAN_FRONTEND=noninteractive apt install ./quarto-*-linux-amd64.deb \
    && rm quarto-*-linux-amd64.deb

RUN install.r devtools rmarkdown quarto tidyverse gifski ggrepel ggpubr \
 && installGithub.r rundel/checklist rundel/parsermd djnavarro/jasmines \
 && installGithub.r Selbosh/ggchernoff

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
