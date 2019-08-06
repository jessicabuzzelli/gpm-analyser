# gpm-analyser
Playing around with Flask to create a simple webapp to analyse Google Play Music data. Moving to Spotify since,
among other things, year-end usage metrics are cool and GPM is pretty lacking in that department.

## Gist of what I'm doing:
- Experimenting with Flask/forms.
- Create an upload page to accept a zip file from [takeout.google.com]().
- Playcount / artist / album info is stored in a separate csv for each song in each playlist made by a user. Need to read each csv and 
pull the data into a dataframe/sqlite db file/master csv. Depends on type of analysis I'm feeling at that point.

## And then what?
- Can pull quick stats like top 5/10/20 songs played, top artists, songs in the most playlists, etc.
- Cross-reference song/artist data with a lyric site like [Genius]() to incorporate some form of NLP?
- Make the page templates pretty.