# r_gh_actions

Base R Docker image for Duke Statistical Science courses, intended for use with GitHub Actions (assignment checking, rendering Quarto / R Markdown documents, etc.). The image is built automatically from this repository and published to the GitHub Container Registry (GHCR) as:

```
ghcr.io/dukestatsci/r_gh_actions:latest
```

## What is in the image

The image is built on top of [`rocker/r2u`](https://rocker-project.org/images/other/r2u.html) (Ubuntu 24.04 "noble"), which provides the current R release and installs CRAN packages as Ubuntu binaries via bspm, so `install.packages()` is fast and system dependencies are resolved automatically.

On top of the base image it adds:

- R packages: `devtools`, `rmarkdown`, `quarto`, `tidyverse`, `gifski`, `here`, `fs`, `pak`, and [`rundel/checklist`](https://github.com/rundel/checklist) from GitHub
- Quarto CLI (v1.8.27) and pandoc
- Python 3.14 installed via [uv](https://docs.astral.sh/uv/), with a virtual environment preconfigured at `/work/.venv` (`RETICULATE_PYTHON` is set so reticulate uses it automatically; `uv pip install` inside the container targets it as well)
- System libraries for common package needs: GDAL / GEOS / PROJ / udunits2 (`sf`, `terra`), ImageMagick (`magick`) with its disk cache limit raised to 8 GiB, GLPK (`igraph`), and libnode (`V8`)
- Command line utilities: `git`, `wget`, `curl`, `rsync`

The working directory is `/work` and the default command is `bash`.

## How the image is built

Any push to the `main` branch triggers [`.github/workflows/docker-publish.yml`](.github/workflows/docker-publish.yml), which builds the [`Dockerfile`](Dockerfile) for `linux/amd64` and pushes the result to `ghcr.io/dukestatsci/r_gh_actions:latest`. Only the `latest` tag is published, there are no versioned tags, so downstream workflows always get the most recent build.

To change what is in the image, edit the `Dockerfile` and push to `main` (or open a pull request); the new image is published automatically once the workflow completes.

## Using the image

### In a GitHub Actions workflow

The most common use is as the container for a workflow job, for example to render and check student assignments:

```yaml
jobs:
  check:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/dukestatsci/r_gh_actions:latest
    steps:
      - uses: actions/checkout@v4

      - name: Render document
        run: quarto render document.qmd
```

Since the image is public no registry credentials are required to use it.

### Pulling the image locally

The image can be pulled anonymously:

```sh
docker pull ghcr.io/dukestatsci/r_gh_actions:latest
```

The image is only built for `linux/amd64`. On Apple Silicon (or other arm64 hosts) add `--platform linux/amd64` to `docker pull` and `docker run` and it will run under emulation:

```sh
docker pull --platform linux/amd64 ghcr.io/dukestatsci/r_gh_actions:latest
```

### Running the image locally

Start an interactive shell with the current directory mounted at `/work`:

```sh
docker run --rm -it -v "$(pwd)":/work ghcr.io/dukestatsci/r_gh_actions:latest
```

From there you can run `R`, `quarto render`, etc. exactly as they would run in a GitHub Actions job, which is useful for debugging workflow failures locally. One-off commands can also be run directly:

```sh
docker run --rm -v "$(pwd)":/work ghcr.io/dukestatsci/r_gh_actions:latest \
  quarto render document.qmd
```

Note that mounting over `/work` hides the prebuilt Python virtual environment at `/work/.venv`; if you need Python / reticulate locally, mount your project somewhere else (e.g. `-v "$(pwd)":/project -w /project`).

## Repository contents

- [`Dockerfile`](Dockerfile) defines the image
- [`.github/workflows/docker-publish.yml`](.github/workflows/docker-publish.yml) builds and publishes the image on pushes to `main`
