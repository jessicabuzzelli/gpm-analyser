# gpm-analyser
Playing around with Flask to create a simple webapp to highlight a user's Google Play Music trends similar to Spotify's end-of-year usage metrics. 

## Gist of what I'm doing:
- Experimenting with Flask/forms.
- Create an upload page to accept a zip file from [takeout.google.com]().
- Once unzipped, playcount / artist / album info is stored in a separate csv for each song in each playlist made by a user. Need to read each csv and pull the data into a dataframe/master csv/db. Will probably just use a pandas dataframe.
- Once all song data is reorganized, pull quick stats like top 5/10/20 songs played, top artists, songs in the most playlists, etc.

## And then what?
- Cross-reference song/artist data with a lyric site like [Genius]() to incorporate some form of NLP / determine themes in frequently played tracks?
- Add some pizzazz to the page templates
