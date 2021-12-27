#!/bin/bash
set -eu

DEEZER_COOKIE_ARL=changeme

docker kill deezer-downloader 2>&1 >/dev/null || true
docker rm deezer-downloader 2>&1 >/dev/null || true
echo "Running deezer downloader in the background"
docker run -d --name deezer-downloader -p 5000:5000 --volume $(pwd)/downloads/:/mnt/deezer-downloader \
                --env DEEZER_COOKIE_ARL=$DEEZER_COOKIE_ARL "dejan995/deezer-downloader:latest" >/dev/null
sleep 5


## testing deezer
rm -rf 'downloads/songs/Deichkind - Illegale Fans.mp3'
echo "Downloading deezer song"
curl -s --fail 'http://localhost:5000/download' --data-raw '{"type":"track","music_id":82120546,"add_to_playlist":false,"create_zip":false}' >/dev/null
sleep 5
ls -lh 'downloads/songs/Deichkind - Illegale Fans.mp3'
file 'downloads/songs/Deichkind - Illegale Fans.mp3'
rm 'downloads/songs/Deichkind - Illegale Fans.mp3'

## testing youtube-dl
rm -rf 'downloads/youtube-dl/Stereoact feat. Kerstin Ott - Die Immer Lacht (Official Video HD).mp3'
echo "Downloading a song via youtube-dl"
curl -s --fail 'http://localhost:5000/youtubedl' --data-raw '{"url":"https://www.youtube.com/watch?v=Bkj3IVIO2Os","add_to_playlist":false}' >/dev/null
sleep 20
ls -lh 'downloads/youtube-dl/Stereoact feat. Kerstin Ott - Die Immer Lacht (Official Video HD).mp3'
file 'downloads/youtube-dl/Stereoact feat. Kerstin Ott - Die Immer Lacht (Official Video HD).mp3'
rm 'downloads/youtube-dl/Stereoact feat. Kerstin Ott - Die Immer Lacht (Official Video HD).mp3'

echo "Tests succeeded."

# cleanup
echo "Cleaning up"
docker kill deezer-downloader >/dev/null
docker rm deezer-downloader >/dev/null
