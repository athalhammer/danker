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
set -e

# Check for environment variables for sort
if [ -z ${MEM_PERC+x} ]; then
        export MEM_PERC="50%"
fi

# defaults
project="wiki"
dump_time=""
folder=""
while getopts ":p:i:d:s:t:f:bl" a; do
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
	t)
	    dump_time=${OPTARG}
	    ;;
	f)
	    folder=${OPTARG}
	    ;;
        b)
            bigmem=1
            ;;
	l)
	    links=1
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
    filename=$(date +"%Y-%m-%d").all"$project".links
    true > "$filename.files.txt"
    true > "$filename.stats.txt"
    if languages=$(./script/get_languages.sh "$project"); then

	# collect
	for i in $languages; do
	    ./script/create_links.sh "$i" "$project" "$dump_time" "$folder" >> "$filename.files.txt"
	done

	# merge
	xargs sort -m -k 1,1n -T . -S "$MEM_PERC" -o "$filename" < "$filename.files.txt" 

        # collect stats
	xargs wc -l < "$filename.files.txt" | grep -v "total" | sed "s/^[[:space:]]\+//" > "$filename.stats.txt"

        # clean up
	xargs rm < "$filename.files.txt"

    else
	(>&2 printf "[Error]\tCouldn't retrieve languages...\n")
        exit 1
    fi
else
    filename=$(./script/create_links.sh "$1" "$project" "$dump_time" "$folder")
    true > "$filename.stats.txt"
fi

wc -l "$filename" >> "$filename.stats.txt"

# "extract links only" option
if [ "$links" ]; then
    echo "$filename"
    exit 0
fi

if [ "$bigmem" ]; then
    python3 -m danker  "$filename" "$damping" "$iterations" "$start_value" -i \
       2>> "$filename.stats.txt" | sed "s/\(.*\)/Q\1/" \
    > "$filename".rank
else
    sort -k 2,2n -T . -S "$MEM_PERC" -o "$filename"".right" "$filename"
    python3 -m danker  "$filename" -r "$filename"".right" "$damping" "$iterations" "$start_value" -i \
        2>> "$filename.stats.txt" | sed "s/\(.*\)/Q\1/" \
    > "$filename".rank
    rm "$filename"".right"
fi
sort -k 2,2nr -T . -S "$MEM_PERC" -o "$filename"".rank" "$filename"".rank"
wc -l "$filename"".rank" >> "$filename.stats.txt"
echo "$filename"
