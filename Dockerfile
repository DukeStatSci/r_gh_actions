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
 && sed 's/value="1GiB"/value="8GiB"/1' /etc/ImageMagick-6/policy.xml > /etc/ImageMagick-6/policy.xml

RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.8.27/quarto-1.8.27-linux-amd64.deb \
 && apt install ./quarto-*-linux-amd64.deb \
 && rm quarto-*-linux-amd64.deb

RUN install.r devtools rmarkdown quarto tidyverse gifski here fs pak \
 && installGithub.r rundel/checklist

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN uv python install 3.14 \
 && uv python pin 3.14 \
 && mkdir /work \
 && cd /work \
 && uv venv 

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /work

ENV VIRTUAL_ENV="/work/.venv"
ENV PATH="/work/.venv/bin:$PATH"
ENV RETICULATE_PYTHON="/work/.venv/bin/python"

CMD ["bash"]
