#!/bin/bash
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
iterations=40
damping_factor=0.85
start_value=0.1

if [ "$1" == "ALL" ]; then
  filename='all.links'
  for i in `./lib/getLanguages.sh`; do ./lib/createLinks.sh "$i" >> all-link-files.txt; done
  for i in `cat all-link-files.txt`; do cat "$i" >> "$filename"; done
  sort --field-separator=$'\t' --key=1 --temporary-directory=. -no "$filename" "$filename"
else
  filename=`./lib/createLinks.sh "$1"`
fi
if [ "$2" == "BIGMEM" ]; then
  ./lib/dankerBigMem.py  "$filename" $damping_factor $iterations $start_value | sed "s/\(.*\)/Q\1/" > "$filename".rank
else
  sort --field-separator=$'\t' --key=2 --temporary-directory=. -no "$filename"".right" "$filename"
  ./lib/danker.py  "$filename" "$filename"".right"  $damping_factor $iterations $start_value | sed "s/\(.*\)/Q\1/" > "$filename".rank
  rm "$filename"".right"
fi
sort -nro "$filename"".rank" --field-separator=$'\t' --key=2 "$filename"".rank"
