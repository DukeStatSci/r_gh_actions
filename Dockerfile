FROM rocker/r2u:latest

#ADD Rprofile.site /usr/lib/R/etc/Rprofile.site

RUN apt-get update \
 && apt-get upgrade -y

RUN apt-get install -y --no-install-recommends \
    software-properties-common \
    libudunits2-dev libgdal-dev libgeos-dev \
    libproj-dev pandoc libmagick++-dev \
    libglpk-dev libnode-dev \
    wget git rsync curl \
    && sed 's/value="1GiB"/value="8GiB"/1' /etc/ImageMagick-6/policy.xml > /etc/ImageMagick-6/policy.xml

RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.8.25/quarto-1.8.25-linux-amd64.deb \
    && DEBIAN_FRONTEND=noninteractive apt install ./quarto-*-linux-amd64.deb \
    && rm quarto-*-linux-amd64.deb

RUN install.r devtools rmarkdown quarto tidyverse gifski ggrepel ggpubr \
 && installGithub.r rundel/checklist rundel/parsermd djnavarro/jasmines \
 && installGithub.r Selbosh/ggchernoff

RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
 && source $HOME/.local/bin/env \
 && uv python install 3.14 \
 && uv python pin 3.14

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

CMD ["bash"]


