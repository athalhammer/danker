#!/usr/bin/env bash

#    danker - PageRank on Wikipedia/Wikidata
#    Copyright (C) 2017  Andreas Thalhammer
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# configuration
export LC_ALL=C

iterations=40
damping_factor=0.85
start_value=0.1

if [ "$1" == "ALL" ]; then
  filename=$(date +"%Y-%m-%d").all.links
  for i in $(./lib/getLanguages.sh); do
    ./lib/createLinks.sh "$i" >> "$filename.files.txt"
  done
  
  for i in $(cat "$filename.files.txt"); do 
    cat "$i" >> "$filename"
  done
  
  sort -S 50% --field-separator=$'\t' --key=1 --temporary-directory=. -no "$filename" "$filename"

  # collect stats and add language-specific source files to a compressed archive
  for i in $(cat "$filename.files.txt"); do
    wc -l "$i" >> "$filename.stats.txt"
  done
  wc -l "$filename" >> "$filename.stats.txt"
  tar --remove-files -cjf "$filename.tar.bz2" `cat "$filename.files.txt"`
else
  filename=`./lib/createLinks.sh "$1"`
fi
if [ "$2" == "BIGMEM" ]; then
  ./lib/danker.py  "$filename" $damping_factor $iterations $start_value | sed "s/\(.*\)/Q\1/" > "$filename".rank
else
  sort -S 50% --field-separator=$'\t' --key=2 --temporary-directory=. -no "$filename"".right" "$filename"
  ./lib/danker.py  "$filename" --right_sorted "$filename"".right"  $damping_factor $iterations $start_value | sed "s/\(.*\)/Q\1/" > "$filename".rank
  rm "$filename"".right"
fi
sort -S 50% -nro "$filename"".rank" --field-separator=$'\t' --key=2 "$filename"".rank"
bzip2 "$filename"
echo "$filename"
