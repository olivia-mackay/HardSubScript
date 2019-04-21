# HardSubScript
## Usage
Install ffmpeg and add it to your path before using this script.

Pass your working directory as an argument, for example:
`./hardSubScript.sh Lucky\ Star`

You may also pass in the 3 stream mappings yourself alongside your directory, in the order `video, audio, subtitle`. For example,
`./hardSubScript.sh Lucky\ Star 0 1 3`
Take note that this will apply these to the entire folder; the stream mapping order can vary occasionally from file-to-file.

Assuming your files contain a Japanese audio stream, a subtitle stream, and video, this should take your MKV and produce a hard-encoded AVI.

## Why?
This script is particularly helpful when Chromecasting anime using VLC, as it's not possible to cast with a subtitle (.srt) file supplied. This script allows you to hard-encode subs onto a video to get around this. This will also convert videos to an AVI, which can be natively casted and does not require on-the-fly re-encoding.
