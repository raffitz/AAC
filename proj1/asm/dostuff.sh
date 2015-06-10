#!/bin/sh


./urasm $1.asm

./urlink $1.obj

python link2rom.py a.out

mv imem.txt imem_$1.txt
