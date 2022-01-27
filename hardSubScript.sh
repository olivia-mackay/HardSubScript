#!/bin/bash
trap "echo Exiting!; exit;" SIGINT SIGTERM

function usage() {
    echo "Usage:"

    echo "  Use default script settings that attempt to embed English subtitles onto videos with Japanese audio."
    echo "      ./hardSubScript <show directory>"
    echo ""
    echo "  Or provide your own stream mappings for more fine-grained control."
    echo "      ./hardSubScript <show directory> [<video stream #> <audio stream #> <subtitle stream #>]"
    exit 2
}

usage

# pass the show/anime/working directory
directory="$1"

temp="temp.mkv"
info="output/info.txt"

# make output if it doesn't exist, clear directory before working
cd "$directory" || exit 2

mkdir -p output && rm -f output/*

function strip_video(file) {
    filename="${i%.*}"
    start=`date +%s`

    if [ "$#" -eq 1 ]; then
        # save info output to var
        info=$(ffmpeg -i "$i")

        # start grepping for video, audio, and sub tracks, gawk out stream numbers
        video=$(cat "$info" | gawk '{print $1}' FS="(" | gawk '{print $2}' FS=":")
        audio=$(cat "$info" | grep "(jpn): Audio" | gawk '{print $1}' FS="(" | gawk '{print $2}' FS=":")
        subtitle=$(cat "$info" | grep "Subtitle" | gawk '{print $1}' FS="(" | gawk '{print $2}' FS=":")
    elif [ "$#" -eq 3 ]; then
        # assume our user was nice and gave us the stream info themselves
        video=$2
        audio=$3
        subtitle=$4
    else
        exit 1
    fi

    echo "===== Stream mappings: video=$video, audio=$audio, subtitle=$subtitle."

    # validate mapping values
    re='^[0-9]+$'
    if ! [[ $video =~ $re ]] || ! [[ $audio =~ $re ]] || ! [[ $subtitle =~ $re ]]; then
        echo "===== one of the provided mapping values were invalid" >&2;
        exit 1
    fi

    # encode with specified 3 streams, save to temp.mkv in output folder
    echo "===== processing $i with mappings video:$video audio:$audio subtitle:$subtitle"
    ffmpeg -loglevel panic -i "$i" \
        -map 0:"$video" -map 0:"$audio" -map 0:"$subtitle" \
        -c:v copy -c:a copy -c:s copy \
        "output/$temp"

    # hardcode subs to original filename.avi
    cd output
    mid=`date +%s`
    echo "===== audio removed, took $((mid - start)) seconds"
    ffmpeg -loglevel panic -i "$temp" -vf subtitles="$temp" "$filename".avi

    # back to start position
    end=`date +%s`
    echo "===== done, took $((end - mid)) seconds"
    rm -f "$temp"
    rm -f "$info"
    cd ..
}

info=""

# should let us handle inner directories
find . -type d "" exec strip_video {} \;
