library("shiny")
library("DBI")

home_dir <- getwd()
src_dir <- file.path(home_dir, "app", "src")

# Prompt user to select .zip containing GPM data & loads into SQLite DB
source(file.path(src_dir, "load_takeout.R"))
source(file.path(src_dir, "run_analysis.R"))
source(file.path(src_dir, "credentials.R"))

load_takeout(home_dir)

run_analysis(client_id, client_secret, home_dir)

# Run the application
runApp(src_dir)
