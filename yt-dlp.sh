#!/bin/sh
echo "Remember to use \\ before space"
echo "Artist?"
read -r ARTIST
echo "Album?"
read -r ALBUM
echo "URL?"
read -r URL
echo "yt-dlp -x -P ~/Music/$ARTIST/$ALBUM  --cookies-from-browser firefox --embed-thumbnail --add-metadata $URL"
