#!/bin/bash

set -e

video="$1"
srt="$2"
sub_in_video=/tmp/sub_in_video.srt

[ "$2" ] || { printf "Uasage: $0 video srt\n"; exit 1; }

echo 'Extracting eng subtile from video ...'
sub_eng_index=$(ffmpeg -i "$video" 2>&1 | fgrep Subtitle | fgrep eng | head -1 | cut -d: -f2 | cut -d'(' -f1)
sub_eng_index=$((sub_eng_index-2))
ffmpeg -i "$video" -map 0:s:$sub_eng_index $sub_in_video

srtsync.py $sub_in_video "$srt"
echo 'Done'
