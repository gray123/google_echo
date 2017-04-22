#!/bin/bash

mkdir -p /tmp/res
rm -f /tmp/res/*
resultstr=/tmp/res/`date "+%Y%b%d_%H-%M-%S"`
../rec.sh -o ${resultstr}.flac -d 2 -r 16000
echo "Recorded your question to ${resultstr}.flac"
../stt.sh -i ${resultstr}.flac -r 16000 -l "en_US" > ${resultstr}.s2t
echo "Google Speech API transcript:"
cat ${resultstr}.s2t
sed -n '2{p;q}' ${resultstr}.s2t | awk -F':' '{print $2}' | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g' > ${resultstr}.question
filesize=`wc -c ${resultstr}.question | awk '{print $1}'`
if [ $filesize -gt 1 ]; then
  ../dispatcher.py ${resultstr}.question > ${resultstr}.answer
  echo "Walfram-Alpha reply:"
  cat ${resultstr}.answer 
  gtts-cli -f ${resultstr}.answer -l 'en' -o ${resultstr}.mp3
  mplayer ${resultstr}.mp3
else
  gtts-cli "Sorry, I missed that." -l 'en' -o ${resultstr}.mp3
  mplayer ${resultstr}.mp3
fi
