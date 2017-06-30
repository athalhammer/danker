#!/bin/bash

folder="results"
mkdir "$folder"

#./lib/getLanguages.sh
for i in `cat wiki.langs`; do ./lib/createLinks.sh "$i" "$folder"; done
for i in `ls ./$folder/*.links`; do sort --field-separator=$'\t' --key=2 -o "$i"".right" "$i"; done
for i in `ls ./$folder/*.links`; do python3 ./lib/danker.py  "$i" "$i"".right"  0.85 40 0.1 > "$i".rank; done
for i in `ls ./$folder/*.right`; do rm "$i"; done
for i in `ls ./$folder/*.rank`; do sort -nro "$i" --field-separator=$'\t' --key=2 "$i"; done

