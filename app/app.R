# Shiny App Template
#
# This template demonstrates reading external data from a mounted directory.
# When running locally, data is read from ../data_mount/
# When running in Docker, set APP_DATA_PATH to the container mount point.

# EXTERNAL DATA PATH -------------------------------------------------------
# Reads APP_DATA_PATH from environment; defaults to ../data_mount for local dev
APP_DATA_PATH <- Sys.getenv("APP_DATA_PATH", unset = "../data_mount")

# Helper function to construct paths relative to external data
data_path <- function(...) {
  file.path(APP_DATA_PATH, ...)
}

# LOAD PACKAGES ------------------------------------------------------------
library(shiny)

# LOAD DATA ----------------------------------------------------------------
# Example: read a CSV file from the data mount
# my_data <- read.csv(data_path("my_data.csv"))

# For this demo, we'll check what files exist in the data mount
get_data_files <- function() {
  if (dir.exists(APP_DATA_PATH)) {
    files <- list.files(APP_DATA_PATH, recursive = TRUE)
    if (length(files) == 0) {
      return("(no files found)")
    }
    return(paste(files, collapse = "\n"))
  }
  return("(data directory not found)")
}

# UI -----------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("Shiny App Template"),

  sidebarLayout(
    sidebarPanel(
      h4("About"),
      p("This is a starter template for Dockerized Shiny apps."),
      p("It reads data from an external mounted directory."),
      hr(),
      h4("Configuration"),
      tags$code(paste("APP_DATA_PATH:", APP_DATA_PATH))
    ),

    mainPanel(
      h3("Hello, Shiny!"),
      p("Your app is running successfully."),
      hr(),
      h4("Files in data mount:"),
      verbatimTextOutput("data_files"),
      hr(),
      p("Edit ", tags$code("app/app.R"), " to build your application.")
    )
  )
)

# SERVER -------------------------------------------------------------------
server <- function(input, output, session) {
  output$data_files <- renderText({
    get_data_files()
  })
}

# RUN APP ------------------------------------------------------------------
shinyApp(ui = ui, server = server)
