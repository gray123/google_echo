#!/bin/bash

if [[ ! "$WORKDIR" ]]; then
  WORKDIR="/tmp"
fi

if [[ ! "$SRATE" ]]; then
  SRATE=16000
fi

if [[ ! "$SAMPLEINTER" ]]; then
  SAMPLEINTER=1
fi

mkdir -p $WORKDIR/speech

while true; do
  if [ "$(ls -A $WORKDIR/speech)" ]; then
    filenum=`ls $WORKDIR/speech | sort -nr | head -n1`
    filenum=$(( ${filenum:: -5} + 1 ))
  else
    filenum=1
  fi
  ./rec.sh -o $WORKDIR/speech/${filenum}.flac -d $SAMPLEINTER -r $SRATE
done
