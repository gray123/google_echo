#!/bin/bash
 
# Usage info
show_help() {
cat << EOF
  Usage: ${0##*/} [-h] [-i INFILE] [-r RATE] [-l LANGUAGE] [-k KEY]
  
  Send audio data file to Google for speech recognition.
  
       -h|--help               display this help and exit.
       -i|--input     INFILE   input audio data file name.
       -r|--rate      INTEGER  Sampling rate of the input audio data (Default: 16000).
       -l|--language  STRING   set transcription language (Default: en_US).
                               Other languages: fr_FR, de_DE, es_ES, cn_ZH, ...
       -k|--key       STRING   Google Speech Recognition Key.
                  
EOF
}

INFILE=
SRATE=
LANGUAGE=
KEY=
# parse parameters
while [[ $# -ge 1 ]]
do
   key="$1"
   case $key in
       -h|--help)
       show_help
       exit 0
       ;;
       -i|--input)
       INFILE="$2"
       shift
       ;;
       -r|--rate)
       SRATE=$2
       shift
       ;;
       -l|--language)
       LANGUAGE="$2"
       shift
       ;;
       -k|--key)
       KEY="$2"
       shift
       ;;
       *)
       echo "Unknown parameter '$key'. Type $0 -h for more information."
       exit 1
       ;;
   esac
   shift
done

paramter_err() {
  local m=$1
  echo "ERROR: empty value for ${m}. $0 -h for more information."
  exit 1
}

if [[ -z "$LANGUAGE" ]]; then 
  LANGUAGE="en_US"
fi
if [[ -z "$SRATE" ]]; then 
  SRATE=16000
fi
if [[ -z "$KEY" ]]; then
  KEY="AIzaSyAIiWBcR-VbycBhWuZyHyCopKAPEdVvK0E"
fi
if [[ -z "$INFILE" ]]; then
  paramter_err "input file"
fi

RESULT=`wget -q --post-file $INFILE --header="Content-Type: audio/x-flac; rate=$SRATE" -O - "https://www.google.com/speech-api/v2/recognize?client=chromium&lang=$LANGUAGE&key=$KEY"`
 
FILTERED=`echo "$RESULT" | grep "transcript.*}" | sed 's/,/\n/g;s/[{,},"]//g;s/\[//g;s/\]//g;s/:/: /g' | grep -o -i -e "transcript.*" -e "confidence:.*"`
 
if [[ ! "$FILTERED" ]]
  then
     >&2 echo "Google was unable to recognize any speech in audio data"
else
    echo "Recognition result:"
    echo "$FILTERED"
fi
 
exit 0
