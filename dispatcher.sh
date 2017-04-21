#!/bin/bash
st="idle"

if [[ ! "$WORKDIR" ]]; then
  WORKDIR="/tmp"
fi

if [[ ! "$SRATE" ]]; then
  SRATE=16000
fi
if [[ ! "$KEY" ]];then
  KEY=AIzaSyAcalCzUvPmmJ7CZBFOEWx2Z1ZSn4Vs1gg
fi
if [[ ! "$LANGUAGE" ]]; then
  LANGUAGE=en_US
fi

while true; do
  if [ "$(ls -A $WORKDIR/speech)" ]; then
    case "$st" in
      idle)
        echo "Idling"
        filename=`ls $WORKDIR/speech | sort -n | head -n1`
        filesize=`ls -l --block-size=K $WORKDIR/speech/$filename | awk '{print $5}'`
        filesize=${filesize:: -1}
        if [[ $filesize -le 14 ]]; then
          rm -f $filename
        else
          filenum=${filename:: -5}
          RESULT=`wget -q --post-file $WORKDIR/speech/${filename} --header="Content-Type: audio/x-flac; rate=$SRATE" -O - "https://www.google.com/speech-api/v2/recognize?client=chromium&lang=$LANGUAGE&key=$KEY"`
          FILTERED=`echo "$RESULT" | grep "transcript.*}" | sed 's/,/\n/g;s/[{,},"]//g;s/\[//g;s/\]//g;s/:/: /g' | grep -o -i -e "transcript.*" -e "confidence:.*"`
          echo "$FILTERED" > /tmp/text/tmp
          head -n1 /tmp/text/tmp | awk -F':' '{print $2}' | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g' > $WORKDIR/text/$filenum
          filesize=`wc -c $WORKDIR/text/$filenum | awk '{print $1}'`
          if [ $filesize -gt 1 ]; then
            begin_num=$filenum
            st="takecmd"
          else
            rm -f $WORKDIR/text/$filenum
            rm -f $WORKDIR/speech/${filename}
          fi
        fi
      ;;
      takecmd)
        echo "taking cmd"
        filenum=`ls $WORKDIR/text | sort -nr | head -n1`
        filenum=$(( ${filenum} + 1 ))
        if [[ -f $WORKDIR/speech/${filenum}.flac ]]; then
          RESULT=`wget -q --post-file $WORKDIR/speech/${filenum}.flac --header="Content-Type: audio/x-flac; rate=$SRATE" -O - "https://www.google.com/speech-api/v2/recognize?client=chromium&lang=$LANGUAGE&key=$KEY"`
          FILTERED=`echo "$RESULT" | grep "transcript.*}" | sed 's/,/\n/g;s/[{,},"]//g;s/\[//g;s/\]//g;s/:/: /g' | grep -o -i -e "transcript.*" -e "confidence:.*"`
          echo "$FILTERED" > /tmp/text/tmp
          head -n1 /tmp/text/tmp | awk -F':' '{print $2}' | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g' -e 's/\$//g' > $WORKDIR/text/$filenum
          filesize=`wc -c $WORKDIR/text/$filenum | awk '{print $1}'`
          if [ $filesize -lt 2 ]; then
            end_num=$filenum
            st="execmd"
          fi
        fi
      ;;
      execmd)
        echo "executing cmd"
        for i in `seq $begin_num $end_num`;do
          echo $WORKDIR/speech/${i}.flac
        done > $WORKDIR/speech/to_comb_files.txt
        to_comb_files=`cat $WORKDIR/speech/to_comb_files.txt | xargs`
        sox $to_comb_files $WORKDIR/speech/comb_file.flac
        RESULT=`wget -q --post-file $WORKDIR/speech/comb_file.flac --header="Content-Type: audio/x-flac; rate=$SRATE" -O - "https://www.google.com/speech-api/v2/recognize?client=chromium&lang=$LANGUAGE&key=$KEY"`
        FILTERED=`echo "$RESULT" | grep "transcript.*}" | sed 's/,/\n/g;s/[{,},"]//g;s/\[//g;s/\]//g;s/:/: /g' | grep -o -i -e "transcript.*" -e "confidence:.*"`
        archfilename=$WORKDIR/res/`date "+%Y%b%d_%H-%M-%S"`
        echo "$FILTERED" > /tmp/text/tmp
        head -n1 /tmp/text/tmp | awk -F':' '{print $2}' | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g' > ${archfilename}.q
        ./wolframaplah_query.py ${archfilename}.q > ${archfilename}.a 
        gtts-cli -f ${archfilename}.a -l 'en' -o ${archfilename}.mp3
        mplayer ${archfilename}.mp3
        for i in `seq $begin_num $end_num`; do
          rm -f $WORKDIR/text/$i
          rm -f $WORKDIR/speech/$i
        done
        st="idle"
      ;;
      *)
        echo -e "Wrong State $0 exist"
        exit 1
      ;;
    esac
  fi
done
