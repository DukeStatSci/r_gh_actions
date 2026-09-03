FROM rocker/r2u:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
 && apt upgrade -y \
 && apt install -y --no-install-recommends \
    software-properties-common \
    libudunits2-dev libgdal-dev libgeos-dev \
    libproj-dev pandoc libmagick++-dev \
    libglpk-dev libnode-dev \
    wget git rsync curl \
 && sed -i 's/value="1GiB"/value="8GiB"/' /etc/ImageMagick-6/policy.xml

RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.10.18/quarto-1.10.18-linux-amd64.deb \
 && apt install ./quarto-*-linux-amd64.deb \
 && rm quarto-*-linux-amd64.deb

RUN install.r devtools rmarkdown quarto reticulate tidyverse gifski here fs pak \
 && installGithub.r rundel/checklist

COPY --from=ghcr.io/astral-sh/uv:0.12.9 /uv /uvx /bin/

RUN uv python install 3.14 \
 && mkdir /work

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /work

CMD ["bash"]
