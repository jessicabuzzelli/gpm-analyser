# Title     : TODO
# Objective : TODO
# Created by: jessica
# Created on: 1/23/21

library("RSQLite")

load_takeout <- function(home_dir){

  zipf <- tcltk::tk_choose.files(filters=matrix(c("ZIP", ".zip"), nrow=1, ncol=2, byrow=TRUE))
  # zipf <- file.path(home_dir, "test_data", "takeout-20210124T042335Z-001.zip")

  data_dir <- file.path(home_dir, "app", "data")
  takeout_dir <- file.path(data_dir, "Takeout")

  if(dir.exists(takeout_dir)){
    unlink(takeout_dir, recursive = TRUE)
  }

  unzip(zipfile=zipf, exdir=data_dir, overwrite=TRUE)

  if(!dir.exists(data_dir)){
    stop("Invalid file. Please select a Google Takeout zip file.")
  }

  if(!dir.exists(file.path(takeout_dir, "Google Play Music"))){
    stop("Google Takeout found but Google Play Music data does not exist.")
  }

  print("Loading Google Play Music data... (this could take a while)")

  load_sqlite(data_dir)

  print("Load complete! Analyzing...")
  setwd(home_dir)

}

load_sqlite <- function(data_dir){
  setwd(data_dir)
  gpm_dir <- file.path(data_dir, "Takeout", "Google Play Music")

  # Clear previous GPM DB if exists
  gpm_db <- file.path(data_dir, "gpm.db")

  if (file.exists(gpm_db)){
    # Clear existing database:
    conn <- dbConnect(drv=SQLite(), dbname="gpm.db")
    dbExecute(conn, "delete from playlists;")
    dbExecute(conn, "delete from playlist_tracks;")
    dbExecute(conn, "delete from all_tracks;")
  }
  else{
    # Create SQLite database:
    conn <- dbConnect(drv=SQLite(), "gpm.db")

    # Create tables
    create_tables(conn)
  }

  # Load playlist data
  playlist_dir <- file.path(gpm_dir, "Playlists")
  if (dir.exists(playlist_dir)){
    load_playlists(playlist_dir, conn)
  }

  # Load Tracks data
  tracks_dir <- file.path(gpm_dir, "Tracks")
  if (dir.exists(tracks_dir)){
    load_tracks(tracks_dir, conn)
  }

  format_db(conn)

  # dbCommit(conn)
  dbDisconnect(conn)

}

load_playlists <- function(playlist_dir, conn){
  playlists <- list.dirs(playlist_dir, recursive=FALSE, full.names=FALSE)
  playlists_full <- list.dirs(playlist_dir, recursive=FALSE, full.names=TRUE)

  n_playlists <- length(playlists)

  for(p in 1:n_playlists){
    insert_playlist <- sprintf("insert into playlists (playlist_id, playlist_name) values (%i, '%s');", p, playlists[p])
    dbExecute(conn, insert_playlist)

    load_tracks(file.path(playlists_full[p], "Tracks"), conn, table_name="playlist_tracks", playlist_id=p)
  }

}

load_tracks <- function(tracks_dir, conn, table_name="all_tracks", playlist_id=0){
  tracks <- list.files(tracks_dir, full.names=TRUE)

  for(track in tracks){
    track_data <- read.csv(file=track, header=TRUE)

    if(table_name == 'all_tracks'){
      insert_track <- sprintf("insert into all_tracks (track_title, album_title, artist, duration, rating, play_count, removed) values ('%s', '%s', '%s', %s, %s, %s, '%s');",
                              track_data[1, 1],
                              track_data[1, 2],
                              track_data[1, 3],
                              track_data[1, 4],
                              track_data[1, 5],
                              track_data[1, 6],
                              track_data[1, 7])
    }
    if(table_name == 'playlist_tracks'){
      # todo - get this working - made it in
      insert_track <- sprintf("insert into playlist_tracks (playlist_id, track_title, album_title, artist, duration, rating, play_count, removed, playlist_index) values (%s, '%s', '%s', '%s', %s, %s, %s, '%s', %s);",
                              playlist_id,
                              track_data[1, 1],
                              track_data[1, 2],
                              track_data[1, 3],
                              track_data[1, 4],
                              track_data[1, 5],
                              track_data[1, 6],
                              track_data[1, 7],
                              track_data[1, 8])
    }

    if((table_name != 'playlist_tracks') & (table_name != 'all_tracks')){stop()}

    dbExecute(conn, insert_track)
  }
}

create_tables <- function(conn){
  playlists_schema <- "create table playlists (playlist_id integer primary key, playlist_name text);"
  playlist_tracks_schema <- "create table playlist_tracks (playlist_id integer, playlist_index integer, track_title text, album_title text, artist text, duration integer, rating text, play_count integer, removed text,  PRIMARY KEY (playlist_id, playlist_index),   FOREIGN KEY(playlist_id) REFERENCES playlists(playlist_id));"
  all_tracks_schema <- "create table all_tracks (track_id integer primary key autoincrement, track_title text, album_title text, artist text, duration integer, rating text, play_count integer, removed text);"

  dbExecute(conn, playlists_schema)
  dbExecute(conn, playlist_tracks_schema)
  dbExecute(conn, all_tracks_schema)
  dbExecute(conn, "ALTER TABLE playlist_tracks ADD COLUMN track_id integer;")
  dbExecute(conn, "update playlist_tracks set track_id = (
	select track_id from all_tracks
	WHERE all_tracks.album_title = playlist_tracks.album_title
	and all_tracks.track_title = playlist_tracks.track_title
	and all_tracks.artist = playlist_tracks.artist);")
}

format_db <- function(conn){
  # Fix weird encoding:
  dbExecute(conn, "update all_tracks set track_title = replace(track_title, '&#39;', '''');")
  dbExecute(conn, "update all_tracks set album_title = replace(album_title, '&#39;', '''');")
  dbExecute(conn, "update all_tracks set artist = replace(artist, '&#39;', '''');")
  dbExecute(conn, "update playlist_tracks set track_title = replace(track_title, '&#39;', '''');")
  dbExecute(conn, "update playlist_tracks set album_title = replace(album_title, '&#39;', '''');")
  dbExecute(conn, "update playlist_tracks set artist = replace(artist, '&#39;', '''');")
  dbExecute(conn, "update playlists set playlist_name = replace(playlist_name, '&#39;', '''');")

  dbExecute(conn, "update all_tracks set track_title = replace(track_title, '&amp;', '&');")
  dbExecute(conn, "update all_tracks set album_title = replace(album_title, '&amp;', '&');")
  dbExecute(conn, "update all_tracks set artist = replace(artist, '&amp;', '&');")
  dbExecute(conn, "update playlist_tracks set track_title = replace(track_title, '&amp;', '&');")
  dbExecute(conn, "update playlist_tracks set album_title = replace(album_title, '&amp;', '&');")
  dbExecute(conn, "update playlist_tracks set artist = replace(artist, '&amp;', '&');")
  dbExecute(conn, "update playlists set playlist_name = replace(playlist_name, '&amp;', '&');")
}
