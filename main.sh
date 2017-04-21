#!/bin/bash

record() {
  local DURATION=$1
  local SRATE=$2
  local INFILE=$3

    if hash rec 2>/dev/null; then
      rec -q -c 1 -r $SRATE $INFILE trim 0 $DURATION
    else
      timeout $DURATION parecord $INFILE --file-format=flac --rate=$SRATE --channels=1
    fi
}
rm -f /tmp/speech/tmp.flac /tmp/text/tmp /tmp/text/tmp1
record 3 16000 /tmp/speech/tmp.flac
RESULT=`wget -q --post-file /tmp/speech/tmp.flac --header="Content-Type: audio/x-flac; rate=16000" -O - "https://www.google.com/speech-api/v2/recognize?client=chromium&lang=en_US&key=AIzaSyAcalCzUvPmmJ7CZBFOEWx2Z1ZSn4Vs1gg"`
FILTERED=`echo "$RESULT" | grep "transcript.*}" | sed 's/,/\n/g;s/[{,},"]//g;s/\[//g;s/\]//g;s/:/: /g' | grep -o -i -e "transcript.*" -e "confidence:.*"`
echo "$FILTERED" > /tmp/text/tmp1
head -n1 /tmp/text/tmp1 | awk -F':' '{print $2}' | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g' > /tmp/text/tmp
filesize=`ls -l --block-size=K /tmp/text/tmp | awk '{print $5}'`
filesize=${filesize:: -1}
if [ $filesize -gt 0 ]; then
  archfilename=/tmp/res/`date "+%Y%b%d_%H-%M-%S"`
  mv /tmp/text/tmp ${archfilename}.q
  ./wolframaplah_query.py ${archfilename}.q > ${archfilename}.a
  gtts-cli -f ${archfilename}.a -l 'en' -o ${archfilename}.mp3
  mplayer ${archfilename}.mp3
fi
