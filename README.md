# HardSubScript
Install ffmpeg and add it to your path before using this script.

Pass your working directory when running, for example:
`./hardSubScript.sh Lucky\ Star`

You may also pass in the 3 stream mappings yourself, in the order `video, audio, subtitle` after your directory. For example,
`./hardSubScript.sh Lucky\ Star 0 1 3`
Take note that this will apply these to the entire folder; the stream mapping order can vary occasionally from file-to-file.

Assuming your files contain a Japanese audio stream, a subtitle stream, and video, this should take your MKV and produce a hard-encoded AVI.
