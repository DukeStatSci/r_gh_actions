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

RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.8.26/quarto-1.8.26-linux-amd64.deb \
    && DEBIAN_FRONTEND=noninteractive apt install ./quarto-*-linux-amd64.deb \
    && rm quarto-*-linux-amd64.deb

RUN install.r devtools rmarkdown quarto tidyverse gifski here fs pak \
 && installGithub.r rundel/checklist
 #&& installGithub.r Selbosh/ggchernoff djnavarro/jasmines 

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


