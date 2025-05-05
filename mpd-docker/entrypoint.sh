#!/bin/bash
set -e

mkdir -p /var/lib/mpd/playlists /var/lib/mpd/music /var/lib/mpd/cache /var/log/mpd /run/mpd
touch /var/lib/mpd/database /var/lib/mpd/state /var/lib/mpd/sticker.sql /var/log/mpd/mpd.log

rm -f /var/lib/mpd/database

cat <<EOF > /etc/mpd.conf
music_directory    "/music"
playlist_directory "/var/lib/mpd/playlists"
db_file            "/var/lib/mpd/database"
log_file           "/var/log/mpd/mpd.log"
pid_file           "/run/mpd/pid"
state_file         "/var/lib/mpd/state"
sticker_file       "/var/lib/mpd/sticker.sql"

bind_to_address    "127.0.0.1"
user               "root"
zeroconf_enabled   "no"

audio_output {
    type            "shout"
    encoding        "mp3"
    name            "FotexNET MPD Stream"
    host            "${ICECAST_HOST}"
    port            "8000"
    mount           "/stream.mp3"
    password        "${ICECAST_PASSWORD}"
    user            "source"
    bitrate         "128"
    format          "44100:16:2"
    genre           "AI music"
    description     "Fotexnet Radio"
}

audio_output {
    type            "null"
    name            "dummy"
}

decoder {
    plugin "wildmidi"
    enabled "no"
}
EOF

/usr/bin/mpd /etc/mpd.conf

sleep 2

update_playlist() {
  echo "[INFO] Updating playlist..."
  mpc update
  sleep 2
  mpc clear
  mpc ls | mpc add
  mpc repeat on
  mpc random on
  mpc play
}

update_playlist

inotifywait -m -e create -e delete -e move -e modify /music |
while read -r path event file; do
  echo "[INFO] Detected change in /music: $event $file"
  update_playlist
done &
WATCHER_PID=$!

while true; do
  if ! mpc status | grep -q "\[playing\]"; then
    echo "[INFO] MPD not playing, restarting..."
    update_playlist
  fi
  sleep 30
done
