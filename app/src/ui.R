# Title     : ui.R
# Objective : RShiny UI
# Created by: jessica
# Created on: 1/24/21

library("shiny")
library("shinydashboard")
library("DT")
library("DBI")
library("dplyr")
library("dbplyr")
library("gotop")
library("pool")

conn <- dbPool(drv=RSQLite::SQLite(), dbname=file.path(home_dir, "app", "data", "gpm.db"))

# Will live in "run_analysis.R" later:
playlist_names <- dbGetQuery(conn, "SELECT DISTINCT playlist_name FROM playlists;")

shinyUI(
  dashboardPage(
    dashboardHeader(title='GPM Explorer'),
    dashboardSidebar(
      sidebarMenu(id = "tabs",
        menuItem("Home", tabName = "home", icon=icon("home")),
        menuItem("Tracks", tabName = "viewTracks", icon = icon("table")),
        menuItem("Artists", tabName = "viewArtists", icon = icon("table")),
        menuItem("Albums", tabName = "viewAlbums", icon = icon("table")),
        menuItem("Playlists", tabName = "viewPlaylists", icon = icon("table"))
    )
    ),

    dashboardBody(
      use_gotop(src = "fas fa-arrow-alt-circle-up", opacity=1),

      tabItems(
        tabItem(tabName = "home",
          h3("Home")
#          ,fileInput("file", "Choose file", accept=as.vector(".zip")),
#          renderText("file_message")
        ),

        tabItem(tabName = "viewTracks",
          h3("All Tracks"),
          DTOutput("tracksTbl")),

        tabItem(tabName = "viewPlaylists",
          selectInput("playlist_choice",
                      label="Select a playlist:", 
                      choices = c('', playlist_names[1])),
          DTOutput("playlistTbl")),

          tabItem(tabName = "viewArtists",
          h3("All Artists"),
          DTOutput("artistsTbl")),

          tabItem(tabName = "viewAlbums",
          h3("All Albums"),
          DTOutput("albumsTbl"))
      )
    ),
  )
)
