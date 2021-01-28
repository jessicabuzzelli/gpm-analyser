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


# Will live in "run_analysis.R" later:
playlist_names <- dbGetQuery(conn, "SELECT DISTINCT playlist_name FROM playlists;")[1]
top_five_tracks <- dbGetQuery(conn, "select track_title from (select track_title, sum(play_count) from all_tracks group by track_title order by sum(play_count) desc limit 5);")[1]
top_five_artists <- dbGetQuery(conn, "select artist from (select artist, sum(play_count) from all_tracks group by artist order by sum(play_count) desc limit 5);")[1]
top_five_albums <- dbGetQuery(conn, "select album_title from (select album_title, sum(play_count) from all_tracks group by album_title order by sum(play_count) desc limit 5);")[1]
top_five_playlists<- dbGetQuery(conn, "select playlist_name, sum(play_count) from playlists join playlist_tracks using(playlist_id) group by playlist_name order by sum(play_count) desc limit 5;")[1]


shinyUI(
  dashboardPage(
    dashboardHeader(title='GPM Explorer'),
    dashboardSidebar(
      sidebarMenu(id = "tabs",
        menuItem("Home", tabName = "home", icon=icon("home")),
        menuItem("Tracks", tabName = "viewTracks", icon = icon("table")),
        menuItem("Albums", tabName = "viewAlbums", icon = icon("table")),
        menuItem("Artists", tabName = "viewArtists", icon = icon("table")),
        menuItem("Playlists", tabName = "viewPlaylists", icon = icon("table"))
    )
    ),

    dashboardBody(
      use_gotop(src = "fas fa-arrow-alt-circle-up", opacity=1),

      tabItems(
        tabItem(tabName = "home",
          h3(""),
#          ,fileInput("file", "Choose file", accept=as.vector(".zip")),
#          renderText("file_message")
          h3("Listening Habits by Total Play Count:"),
          box(h4("Top Tracks:"),
              tags$ol(
                  tags$li(top_five_tracks[1,1]),
                  tags$li(top_five_tracks[2,1]),
                  tags$li(top_five_tracks[3,1]),
                  tags$li(top_five_tracks[4,1]),
                  tags$li(top_five_tracks[5,1])
              )),
            box(h4("Top Albums:"),
              tags$ol(
                  tags$li(top_five_albums[1,1]),
                  tags$li(top_five_albums[2,1]),
                  tags$li(top_five_albums[3,1]),
                  tags$li(top_five_albums[4,1]),
                  tags$li(top_five_albums[5,1])
              )),
            box(h4("Top Artists:"),
              tags$ol(
                  tags$li(top_five_artists[1,1]),
                  tags$li(top_five_artists[2,1]),
                  tags$li(top_five_artists[3,1]),
                  tags$li(top_five_artists[4,1]),
                  tags$li(top_five_artists[5,1])
              )),
            box(h4("Top Playlists:"),
              tags$ol(
                  tags$li(top_five_playlists[1,1]),
                  tags$li(top_five_playlists[2,1]),
                  tags$li(top_five_playlists[3,1]),
                  tags$li(top_five_playlists[4,1]),
                  tags$li(top_five_playlists[5,1])
              ))
        ),

        tabItem(tabName = "viewTracks",
          h3("All Tracks"),
          DTOutput("tracksTbl")),

        tabItem(tabName = "viewPlaylists",
          selectInput("playlist_choice",
                      label="Select a playlist:", 
                      choices = c('', playlist_names)),
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
