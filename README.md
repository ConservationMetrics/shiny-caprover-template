# Shiny App - Dockerized for CapRover

This repository is a starter template for R Shiny applications, packaged with Docker and ready to deploy on CapRover.

## Quick Start

### 1. Add packages and runtime libraries to the Dockerfile

See [Adding R Packages](#adding-r-packages) below.

### 2. Build the Docker Image

The `shiny` user inside the container needs to read files you mount from your host machine. To make this work, build the image with your user's UID/GID:

```bash
docker build --build-arg SHINY_UID=$(id -u) --build-arg SHINY_GID=$(id -g) -t my-shiny-app .
```

If deploying to a server where the data files are owned by a different user, use that user's UID/GID instead.
If you installed CapRover on a fresh VM, the correct UID and GID to use there are most likely `1000`.

### 3. Run Locally with Docker

```bash
docker run -p 3838:3838 -v "$(pwd)/data_mount:/data_mount" my-shiny-app
```

Then open http://localhost:3838

**Without Docker (for development):** Open `app/shiny-app.Rproj` in RStudio and click "Run App". The app will read from `data_mount/` in the repo root.

### 4. Deploy to CapRover

1. Push the Docker image to a container registry that's hooked up in your CapRover deployment.

2. Create a new app in CapRover, making sure to check **Has Persistent Data**.

3. In **App Configs > Environment Variables**, add:
   ```
   APP_DATA_PATH=/data_mount
   ```

3. In **App Configs > Persistent Directories**, add a volume mount:
   - Path in App: `/data_mount`
   - Map to a host path or named volume containing your data

4. If you need password protection, in **HTTP Settings > Edit HTTP Basic Auth** assign a username and password. This approach does not allow multiple different usernames.

5. Under the **Deployment** tab, use "Method 6: Deploy via ImageName"


## Project Structure

```
.
├── app/
│   ├── app.R              # Your Shiny application
│   └── shiny-app.Rproj    # RStudio project file
├── data_mount/            # Put data files here for LOCAL development
├── Dockerfile
├── shiny-server.conf
└── README.md
```

## Working with Data

Your app reads data from `APP_DATA_PATH`:
- **Local development:** Defaults to `../data_mount` (relative to `app/`)
- **Docker:** Set to `/data_mount` via the `.Renviron` file in the image

In your R code:

```r
APP_DATA_PATH <- Sys.getenv("APP_DATA_PATH", unset = "../data_mount")

# Helper to build paths
data_path <- function(...) file.path(APP_DATA_PATH, ...)

# Use it
my_data <- read.csv(data_path("my_data.csv"))
```

## Adding R Packages

Install packages in the Dockerfile, not at runtime. Edit the Dockerfile:

```dockerfile
RUN R -e "install.packages(c('dplyr', 'ggplot2', 'plotly'), repos='https://cloud.r-project.org')"
```

This keeps container startup fast and ensures reproducible builds.

## Troubleshooting

If you encounter this error message on startup:

```
[INFO] shiny-server - Error getting worker: Error: The application exited during initialization.
```

That is an indicator that you might be missing an R package, or that something in the R code is not working as expected. Turn on logging by uncommenting `preserve_logs true;` in `shiny-server.conf` and check the logs on the container in `/var/log/shiny-server/` for more information.

See https://github.com/rstudio/shiny-server/issues/353 for more information.

## Get building! Your next steps are:

1. Edit `app/app.R` to build your application
2. Add data files to `data_mount/` for local testing
3. Update the Dockerfile to install any packages you need
4. Rename `shiny-app.Rproj` if you like
