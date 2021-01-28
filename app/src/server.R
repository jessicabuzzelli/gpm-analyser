# Title     : server.R
# Objective : RShiny server
# Created by: jessica
# Created on: 1/24/21

library("shiny")
library("shinydashboard")
library("DT")
library("DBI")
library("DBI")
library("dplyr")
library("dbplyr")
source(file.path(src_dir, "load_takeout.R"))

conn <- dbPool(drv=RSQLite::SQLite(), dbname=file.path(home_dir, "app", "data", "gpm.db"))


shinyServer(function(input, output, session) {
  v <- reactiveValues(playlist_selection = "None")
  
  output$tracksTbl <- renderDT({
    sql <- paste(readLines(file.path(home_dir, "app", "src", "SQL","viewTracks.sql"), warn=FALSE), collapse=' \n ')
    dbGetQuery(conn, sql)}, 
    filter = 'top',
    rownames = FALSE,
    extensions = 'Buttons',
    options = list(paging = FALSE, 
                   dom = 'Bfrtip',
                   buttons = c('copy', 'print', 'csv'), 
                   scrollX = T))

    output$artistsTbl <- renderDT({
    sql <- paste(readLines(file.path(home_dir, "app", "src", "SQL","viewArtists.sql"), warn=FALSE), collapse=' \n ')
    dbGetQuery(conn, sql)},
    filter = 'top',
    rownames = FALSE,
    extensions = 'Buttons',
    options = list(paging = FALSE,
                   dom = 'Bfrtip',
                   buttons = c('copy', 'print', 'csv'),
                   scrollX = T))

    output$albumsTbl <- renderDT({
    sql <- paste(readLines(file.path(home_dir, "app", "src", "SQL","viewAlbums.sql"), warn=FALSE), collapse=' \n ')  #todo: change /SQL/...sql filepath to file.path()
    dbGetQuery(conn, sql)},
    filter = 'top',
    rownames = FALSE,
    extensions = 'Buttons',
    options = list(paging = FALSE,
                   dom = 'Bfrtip',
                   buttons = c('copy', 'print', 'csv'),
                   scrollX = T))

  output$playlistTbl <- renderDT({
    sql <- paste(readLines(file.path(home_dir, "app", "src", "SQL","viewPlaylists.sql"), warn=FALSE), collapse=' \n ')
    query <- sub("<playlist_choice>", paste0("'",input$playlist_choice,"'"), sql)
    return(dbGetQuery(conn, query))}, 
    
    filter = 'top',
    rownames = FALSE, 
    extensions = 'Buttons', 
    options = list(paging = FALSE, dom = 'Bfrtip',buttons = c('copy', 'print', 'csv'), scrollX = T)
  )

})
