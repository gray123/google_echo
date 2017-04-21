#!/bin/bash
if [[ ! "$WORKDIR" ]]; then
  WORKDIR="/tmp"
fi
if [[ ! "$SRATE" ]]; then
  SRATE=16000
fi
if [[ ! "$KEY" ]]; then
KEY=AIzaSyAIiWBcR-VbycBhWuZyHyCopKAPEdVvK0E
fi
LANGUAGE=en_US
THRSIZE=15

mkdir -p $WORKDIR/speech $WORKDIR/text $WORKDIR/res
if [ $1 -eq 0 ]; then
  echo "Run in test mode"
fi

st="idle"
echo "start with idling"
while true; do
  if [ "$(ls -A $WORKDIR/speech)" ]; then
    case "$st" in
      idle)
        filename=`ls $WORKDIR/speech | sort -n | head -n1`
        filesize=`ls -l --block-size=K $WORKDIR/speech/$filename | awk '{print $5}'`
        filesize=${filesize:: -1}
        if [[ $filesize -le 14 ]]; then
          rm -f $WORKDIR/speech/$filename
          echo "$WORKDIR/speech/${filename} is smaller than $THRSIZE"
        else
          filenum=${filename:: -5}
          ./stt.sh -i $WORKDIR/speech/$filename -r $SRATE -l $LANGUAGE > $WORKDIR/text/${filenum}.s2t
          sed -n '2{p;q}' sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g' $WORKDIR/text/${filenum}.s2t > $WORKDIR/text/${filenum}
          filesize=`wc -c $WORKDIR/text/$filenum | awk '{print $1}'`
          if [ $filesize -gt 1 ]; then
            begin_num=$filenum
            st="takecmd"
            echo "switch to $st"
          else
            echo "$WORKDIR/text/${filenum} is empty"
            rm -f $WORKDIR/text/${filenum}.s2t
            rm -f $WORKDIR/text/$filenum
            rm -f $WORKDIR/speech/${filename}
          fi
        fi
      ;;
      takecmd)
        filenum=`ls $WORKDIR/text | sort -nr | head -n1`
        filenum=$(( ${filenum} + 1 ))
        if [[ -f $WORKDIR/speech/${filenum}.flac ]]; then
          ./stt.sh -i $WORKDIR/speech/${filenum}.flac -r $SRATE -l $LANGUAGE > $WORKDIR/text/${filenum}.s2t
          sed -n '2{p;q}' sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g' $WORKDIR/text/${filenum}.s2t > $WORKDIR/text/${filenum}
          filesize=`wc -c $WORKDIR/text/$filenum | awk '{print $1}'`
          if [ $filesize -lt 2 ]; then
            end_num=$filenum
            st="execmd"
            echo "$WORKDIR/text/${filenum} is empty, switch to $st"
          fi
        fi
      ;;
      execmd)
        echo "executing cmd"
        resultstr=/tmp/res/`date "+%Y%b%d_%H-%M-%S"`
        for i in `seq $begin_num $end_num`;do
          echo $WORKDIR/speech/${i}.flac
        done > $WORKDIR/speech/to_comb_files.txt
        to_comb_files=`cat $WORKDIR/speech/to_comb_files.txt | xargs`
        sox $to_comb_files ${resultstr}.flac
        ./stt.sh -i ${resultstr}.flac -r $SRATE -l ${LANGUAGE} > ${resultstr}.s2t
        sed -n '2{p;q}' sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g' ${resultstr}.s2t > ${resultstr}.question
        filesize=`wc -c ${resultstr}.question | awk '{print $1}'`
        if [ $filesize -gt 1 ];then
          ./dispatcher.py ${resultstr}.question > ${resultstr}.answer
          gtts-cli -f ${resultstr}.answer -l ${LANGUAGE:0:2} -o ${resultstr}.mp3
          mplayer ${resultstr}.mp3
        else
          gtts-cli "Sorry, I missed that." -l ${LANGUAGE:0:2} -o ${resultstr}.mp3
          mplayer ${resultstr}.mp3
        fi
        for i in `seq $begin_num $end_num`; do
          rm -f $WORKDIR/text/${i}
          rm -f $WORKDIR/text/${i}.s2t
          rm -f $WORKDIR/speech/${i}.flac
        done
        st="idle"
        echo "go back to $st"
      ;;
      *)
        echo -e "Wrong State $0 exist"
        exit 1
      ;;
    esac
  else
    echo "$WORKDIR/speech is empty"
    if [ $1 -eq 0 ]; then
      exit 0
    fi
  fi
done
