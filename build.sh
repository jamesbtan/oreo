#!/bin/sh

if [ "$1" = "clean" ]; then
    make -C dep/termbox2/ clean
    rm -rf bin
    exit
fi

make -C dep/termbox2/ libtermbox2.a

mkdir -p bin
odin build src/ -out:bin/oreo
