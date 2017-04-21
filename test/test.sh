#!/bin/bash
export WORKDIR=/tmp
mkdir -p /tmp/speech /tmp/text /tmp/res
rm -f /tmp/speech/* /tmp/text/* /tmp/res/*

../sampler.sh&
pid=`echo $?`
sleep 10
kill $pid

../main.sh 0
