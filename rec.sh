#!/bin/bash
 
# Usage info
show_help() {
cat << EOF
  Usage: ${0##*/} [-h] [-o OUTFILE] [-d DURATION] [-r RATE]
  
  Record an utterance.
  
       -h|--help               display this help and exit.
       -o|--output    OUTFILE  use sox or parecord to record audio data to.
       -d|--duration  FLOAT    recoding duration in seconds (Default: 3).
       -r|--rate      INTEGER  sampling rate of audio data (Default: 16000).
EOF
}

# set paramter default
DURATION=3
SRATE=16000
OUTFILE=record_`date "+%Y%b%d_%H-%M-%S"`.flac

# parse parameters
while [[ $# -ge 1 ]]
do
   key="$1"
   case $key in
       -h|--help)
       show_help
       exit 0
       ;;
       -o|--output)
       OUTFILE="$2"
       shift
       ;;
       -d|--duration)
       DURATION="$2"
       shift
       ;;
       -r|--rate)
       SRATE=$2
       shift
       ;;
       *)
       echo "Unknown parameter '$key'. Type $0 -h for more information."
       exit 1
       ;;
   esac
   shift
done

#main function
#first try to use sox, if no sox, use parecord
record() {
    DURATION=$1
    SRATE=$2
    OUTFILE=$3

    if hash rec 2>/dev/null; then
        rec -q -c 1 -r $SRATE $OUTFILE trim 0 $DURATION
    else
        timeout $DURATION parecord $OUTFILE --file-format=flac --rate=$SRATE --channels=1
    fi
}

echo "Say something..."
record $DURATION $SRATE $OUTFILE
 
exit 0
