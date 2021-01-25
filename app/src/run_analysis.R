# Title     : TODO
# Objective : TODO
# Created by: jessica
# Created on: 1/24/21

library("spotifyr")
library("stringr")

run_analysis <- function(client_id, client_secret, home_dir){

  access_token <- access_spotify(client_id, client_secret)
  conn <- connect_sqlite(home_dir)

  top_artists_data <- get_top_artists(conn, access_token)

  dbDisconnect(conn)
}

access_spotify <- function(client_id, client_secret){
  Sys.setenv(SPOTIFY_CLIENT_ID = client_id)
  Sys.setenv(SPOTIFY_CLIENT_SECRET = client_secret)

  access_token <- get_spotify_access_token()
  print(access_token)

  return(access_token)
}

connect_sqlite <- function(home_dir){
  conn <- dbConnect(RSQLite::SQLite(), file.path(home_dir, "app", "data", "gpm.db"))
  return(conn)
}

get_top_artists <- function(conn, access_token){
  search_terms <- dbGetQuery(conn, "select artist from (select replace(artist, ' ', '+') artist, count(play_count) from all_tracks group by artist order by count(play_count) desc limit 5);")
  ids <- vector()
  artists <- vector()

  for(s in search_terms[, 'artist']){
    results <- spotifyr::search_spotify(q=s, type=c("artist"), authorization=access_token)

    if(nrow(results) > 0){
      ids <- c(ids, results$uri[1])
      artists <- c(artists, stringr::str_replace(s, "\\+", " "))
    }
  }
  ids <- stringr::str_replace_all(ids, "spotify:artist:", "")
  results <- spotifyr::get_artists(ids=ids, authorization=access_token)

  m <- results[, c("name", "id", "popularity", "images", "genres", "followers.total")]

  return(m)
}