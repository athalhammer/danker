#!/bin/bash

mkdir results
#./getLanguages.sh
for i in `cat wiki.langs`; do ./createLinks.sh "$i" "results"; done
for i in `ls ./results/*.links`; do sort --field-separator=$'\t' --key=2 -o "$i"".right" "$i"; done
for i in `ls ./results/*.links`; do python3 ./lib/danker.py  "$i" "$i"".right"  0.85 40 0.1 > "$i".rank; done
for i in `ls ./results/*.right`; do rm "$i"; done
for i in `ls ./results/*.rank`; do sort -nro "$i" --field-separator=$'\t' --key=2 "$i"; done

