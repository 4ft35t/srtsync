#!/bin/bash

set -e

video="$1"
srt="$2"
sub_in_video=/tmp/sub_in_video.srt

[ "$2" ] || { printf "Uasage: $0 video srt\n"; exit 1; }

echo 'Extracting eng subtile from video ...'
sub_eng_index=$(ffmpeg -i "$video" 2>&1 | fgrep Subtitle | fgrep eng | head -1 | cut -d: -f2 | cut -d'(' -f1)
sub_eng_index=$((sub_eng_index-2))
ffmpeg -y -i "$video" -map 0:s:$sub_eng_index $sub_in_video

# 中文字幕转 utf-8 编码
input_encode=$(file --mime-encoding "$srt" | awk '{print $NF}')
input_encode=${input_encode@U}
output_encode=UTF-8
iconv --from-code=$input_encode --to-code=$output_encode "$srt" > "$srt".utf8 && mv "$srt".utf8 "$srt"

srtsync.py $sub_in_video "$srt"
rm $sub_in_video
echo 'Done'
