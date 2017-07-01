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

filename=`./lib/createLinks.sh "$1"`
sort --field-separator=$'\t' --key=2 -o "$filename"".right" "$filename"
python3 ./lib/danker.py  "$filename" "$filename"".right"  0.85 40 0.1 > "$filename".rank
sort -nro "$filename"".rank" --field-separator=$'\t' --key=2 "$filename"".rank"
rm "$filename"".right"
