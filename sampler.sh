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

if [[ ! "$WORKDIR" ]]; then
  WORKDIR="/tmp"
fi

if [[ ! "$SRATE" ]]; then
  SRATE=16000
fi

if [[ ! "$SAMPLEINTER" ]]; then
  SAMPLEINTER=1
fi

while true; do
  if [ "$(ls -A $WORKDIR/speech)" ]; then
    filenum=`ls $WORKDIR/speech | sort -nr | head -n1`
    filenum=$(( ${filenum:: -5} + 1 ))
  else
    filenum=1
  fi
  record $SAMPLEINTER $SRATE $WORKDIR/speech/${filenum}.flac
done
