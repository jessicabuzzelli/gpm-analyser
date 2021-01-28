library("shiny")
library("DBI")
library("pool")

# home_dir <- setwd("/home/jessica/Documents/Github/gpm-analyser")  #todo: testing only; remove
home_dir <- getwd()
src_dir <- file.path(home_dir, "app", "src")

# Prompt user to select .zip containing GPM data & load into SQLite DB
# todo: move to "home" tab in Shiny
source(file.path(src_dir, "load_takeout.R"))
load_takeout(home_dir)

conn <- dbPool(drv=RSQLite::SQLite(), dbname=file.path(home_dir, "app", "data", "gpm.db"))

runApp(appDir=src_dir)

dbDisconnect(conn)
