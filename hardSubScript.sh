#!/bin/bash
trap "echo Exiting!; exit;" SIGINT SIGTERM

# pass the working directory
directory=$1
temp="temp.mkv"
info="output/info.txt" #only referenced within base dir

# make output if it doesn't exist, clear directory before working
cd "$directory"
mkdir -p output
rm -f output/*

for i in *; do
    # no directories allowed!
    if [[ ! -d "$i" ]]; then
        filename="${i%.*}"
        start=`date +%s`

        if [ "$#" -eq 1 ]; then
            # save info to file and grep for our mappings
            ffmpeg -i "$i" &> "$info"
            video=`grep "Video" "$info" | gawk '{print $1}' FS="(" | gawk '{print $2}' FS=":"`
            audio=`grep "(jpn): Audio" "$info" | gawk '{print $1}' FS="(" | gawk '{print $2}' FS=":"`
            subtitle=`grep "Subtitle" "$info" | gawk '{print $1}' FS="(" | gawk '{print $2}' FS=":"`
        elif [ "$#" -eq 3 ]; then
            # assume our user was nice and gave us the stream info themselves
            video=$2
            audio=$3
            subtitle=$4
        else
            echo "Please provide a directory or a directory and 3 stream mapping values" <&2;
            exit 1
        fi

        # validate mapping values
        re='^[0-9]+$'
        if ! [[ $video =~ $re ]] || ! [[ $audio =~ $re ]] || ! [[ $subtitle =~ $re ]]; then
            echo "one of the provided mapping values were invalid" >&2;
            exit 1
        fi

        # encode with specified 3 streams, save to temp.mkv in output folder
        echo "processing $i with mappings video:$video audio:$audio subtitle:$subtitle"
        ffmpeg -loglevel panic -i "$i" \
            -map 0:"$video" -map 0:"$audio" -map 0:"$subtitle" \
            -c:v copy -c:a copy -c:s copy \
            "output/$temp"

        # hardcode subs to original filename.avi
        cd output
        mid=`date +%s`
        echo "audio removed, took $((mid - start)) seconds"
        ffmpeg -loglevel panic -i "$temp" -vf subtitles="$temp" "$filename".avi
        
        # back to start position
        end=`date +%s`
        echo "done, took $((end - mid)) seconds"
        rm -f "$temp"
        rm -f "$info"
        cd ..
      
    fi
done
