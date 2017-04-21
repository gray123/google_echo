#!/bin/bash

export WORKDIR="/tmp"
mkdir -p $WORKDIR/text
mkdir -p $WORKDIR/speech
mkdir -p $WORKDIR/res
rm -f $WORKDIR/text/* $WORKDIR/speech/* $WORKDIR/res/*
chmod -R 700 $WORKDIR/text
chmod -R 700 $WORKDIR/speech
chmod -R 700 $WORKDIR/res

./sampler &
sleep 3
./dispatcher &
