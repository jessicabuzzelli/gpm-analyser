library("shiny")
library("DBI")
library("pool")

home_dir <- getwd()
src_dir <- file.path(home_dir, "app", "src")

# Prompt user to select .zip containing GPM data & load into SQLite DB
# todo: move to "home" tab in Shiny
source(file.path(src_dir, "load_takeout.R"))

main <- function(){
  err <- load_takeout(home_dir)

  if(err == 'SUCCESS'){
    runApp(appDir=src_dir)
    dbDisconnect(conn)

  } else {
    print(err)
  }
}

main()
