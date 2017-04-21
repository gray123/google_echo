#!/bin/bash

mkdir -p /tmp/res
rm -f /tmp/res/*
resultstr=/tmp/res/`date "+%Y%b%d_%H-%M-%S"`
../rec.sh -o ${resultstr}.flac -d 3 -r 16000
../stt.sh -i ${resultstr}.flac -r 16000 -l "en_US" > ${resultstr}.s2t
sed -n '2{p;q}' sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g' ${resultstr}.s2t > ${resultstr}.question
filesize=`wc -c ${resultstr}.question | awk '{print $1}'`
if [ $filesize -gt 1 ]; then
  ../wolframaplah_query.py ${resultstr}.question > ${resultstr}.answer
  gtts-cli -f ${resultstr}.answer -l 'en' -o ${resultstr}.mp3
  mplayer ${resultstr}.mp3
else
  gtts-cli "Sorry, I missed that." -l 'en' -o ${resultstr}.mp3
  mplayer ${resultstr}.mp3
fi
