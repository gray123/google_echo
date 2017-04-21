#!/bin/bash
./sampler.sh&
pid=`echo $?`
sleep 5
kill $pid
