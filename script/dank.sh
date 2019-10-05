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

while getopts ":p:i:d:s:b" a; do
    case "${a}" in
        p)
            project=${OPTARG}
            ;;
        i)
            iterations=${OPTARG}
            ;;
        d)
            damping=${OPTARG}
            ;;
        s)
            start_value=${OPTARG}
            ;;
        b)
            bigmem=1
            ;;
        *)
	    # should not occur
            ;;
    esac
done
shift $((OPTIND-1))

if [ ! "$1" ]; then
    (>&2 printf "[Error]\tMissing positional wiki language parameter.
    \tExamples: [en, de, bar, ...]\n")
    exit 1
fi

if [ "$1" == "ALL" ]; then
    filename=$(date +"%Y-%m-%d").all.links
    languages=$(./script/get_languages.sh "$project")
    if [ $? -eq 0 ]; then
        for i in $(echo "$languages"); do
            ./script/create_links.sh "$i" "$project" >> "$filename.files.txt"
        done

        for i in $(cat "$filename.files.txt"); do
            cat "$i" >> "$filename"
        done

	sort -k 1,1n -T . -S 50% -o "$filename" "$filename"

        # collect stats and add language-specific source files to a compressed archive
        for i in $(cat "$filename.files.txt"); do
            wc -l "$i" >> "$filename.stats.txt"
        done
        wc -l "$filename" >> "$filename.stats.txt"
        tar --remove-files -cjf "$filename.tar.bz2" $(cat "$filename.files.txt")
    else
	(>&2 printf "[Error]\tCouldn't retrieve languages...\n")
        exit 1
    fi
else
    filename=$(./script/create_links.sh "$1" "$project")
fi
if [ $bigmem ]; then
    python3 -m danker  "$filename" $damping $iterations $start_value \
        | sed "s/\(.*\)/Q\1/" \
    > "$filename".rank
else
    sort -k 2,2n -T . -S 50% -o "$filename"".right" "$filename"
    python3 -m danker  "$filename" "$filename"".right" $damping $iterations $start_value \
        | sed "s/\(.*\)/Q\1/" \
    > "$filename".rank
    rm "$filename"".right"
fi
sort -k 2,2nr -T . -S 50% -o "$filename"".rank" "$filename"".rank"
bzip2 "$filename"
wc -l "$filename"".rank"
