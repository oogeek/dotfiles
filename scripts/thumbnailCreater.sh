count=1
while IFS= read -r line
do
    echo $line
    echo $count
#    ffmpeg -i "$line" -vframes 1 -an -s 480x270 -ss 0 $(printf "%03d" $count).png
#ffmpeg -i "$line" -vf  "thumbnail,scale=640:360" -frames:v 1 thumb%03d.png
ffmpegthumbnailer -i "$line" -o "thumb$(printf "%03d" $count).png" -s 0 -t 0:0:1 -q 10
count=$(($count+1))
done<shit.txt
