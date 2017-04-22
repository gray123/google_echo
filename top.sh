#!/bin/bash
export WORKDIR=/tmp
mkdir -p /tmp/speech /tmp/text /tmp/res
rm -f /tmp/speech/* /tmp/text/* /tmp/res/*

trap ctrl_c INT
function ctrl_c() {
  kill $pid
}
./sampler.sh&
pid=$?
sleep 5
./main.sh 1
