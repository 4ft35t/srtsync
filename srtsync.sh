#!/bin/bash

set -e

SRC="$(dirname $(readlink -f $0))"

video_or_dir="$1"
chi_srt="$2"

tmp=$(mktemp -d)

on_exit(){
     [ "$TMP" ] && rm -rf $TMP*
 }

trap on_exit EXIT

sub_in_video=$tmp/sub_in_video.srt

extract_subtitle() {
    # eng chi
    lang=$1
    output=$2

    echo "Extracting $lang subtile from video ..."
    sub_index=$(ffmpeg -i "$video" 2>&1 | grep Subtitle | grep $lang | head -1 | cut -d: -f2 | cut -d'(' -f1)
    # sub_index=$((sub_index-2))
    # ffmpeg -y -i "$video" -map 0:s:$sub_index $sub_in_video
    ffmpeg -y -i "$video" -map 0:$sub_index $output
}

syncsrt() {
    video="$1"
    chi_srt="$2"

    chi_tmp=$tmp/chi.srt

    if [ ! "$chi_srt" ]; then
        echo "No subtitle file provided, extracting Chinese subtitle from video."
        local chi_srt=$chi_tmp
        extract_subtitle chi "$chi_srt"
    fi

    # 中文字幕转 utf-8 编码
    input_encode=$(file --mime-encoding "$chi_srt" | awk '{print $NF}')
    input_encode=${input_encode@U}
    output_encode=UTF-8
    iconv --from-code=$input_encode --to-code=$output_encode "$chi_srt" > "$chi_srt".utf8 && mv "$chi_srt".utf8 $chi_srt

    # English subtitle extraction
    extract_subtitle eng $sub_in_video

    if [ "$chi_srt" = "$chi_tmp" ]; then
        # just merge chi and eng subtitles
        cat "$chi_srt"  $sub_in_video > ${video%.*}.chi.srt
    else
        # sync timeline
        # chi_srt must be chi + eng
        python3 $SRC/srtsync.py $sub_in_video "$chi_srt"
    fi

    echo "$video done"
}


if [ -d "$video_or_dir" ]; then
    for video in "$video_or_dir"/*.{mkv,webm}; do
        srt=${video%.*}.chi.srt
        [ -f "${srt}" ] || syncsrt "$video"
    done
else
    syncsrt "$video_or_dir" "$chi_srt"
fi
