#!/bin/bash

filename=`./lib/createLinks.sh "$1"`
sort --field-separator=$'\t' --key=2 -o "$filename"".right" "$filename"
python3 ./lib/danker.py  "$filename" "$filename"".right"  0.85 40 0.1 > "$filename".rank
sort -nro "$filename"".rank" --field-separator=$'\t' --key=2 "$filename"".rank"
rm "$filename"".right"
