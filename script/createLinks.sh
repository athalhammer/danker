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

if [ ! "$1" ]; then
    (>&2 printf "[Error]\tMissing positional wiki language parameter.
    \tExamples: [en, de, bar, ...]\n")
    exit 1
fi

wiki="$1"
dir=$(dirname "$0")

# Location of wikipedia dumps
download="http://download.wikimedia.org/""$wiki""wiki/"
rss="https://dumps.wikimedia.org/""$wiki""wiki/latest/"

# Latest dump date
wget -q "$rss""$wiki""wiki-latest-page.sql.gz-rss.xml" \
	"$rss""$wiki""wiki-latest-pagelinks.sql.gz-rss.xml" \
	"$rss""$wiki""wiki-latest-redirect.sql.gz-rss.xml" \
	"$rss""$wiki""wiki-latest-page_props.sql.gz-rss.xml"
dump_date=$(cat "$wiki"*.xml | sed -n "s#.*$download\([0-9]\+\).*#\1#p" | sort -u)

rm "$wiki""wiki-latest-page.sql.gz-rss.xml" \
	"$wiki""wiki-latest-pagelinks.sql.gz-rss.xml" \
	"$wiki""wiki-latest-redirect.sql.gz-rss.xml" \
	"$wiki""wiki-latest-page_props.sql.gz-rss.xml"

if [ $(echo "$dump_date" | wc -l) != '1' ] || [ "$dump_date" == '' ]; then
	(>&2 printf "[Error]\tMultiple or no date for '$wiki' dump.\n")
	exit 1
fi

# File locations
page="$wiki""wiki-""$dump_date""-page.sql"
pagelinks="$wiki""wiki-""$dump_date""-pagelinks.sql"
redirect="$wiki""wiki-""$dump_date""-redirect.sql"
pageprops="$wiki""wiki-""$dump_date""-page_props.sql"

# Download and unzip
wget -q "$download$dump_date/$page.gz" \
	"$download$dump_date/$pagelinks.gz" \
	"$download$dump_date/$redirect.gz" \
	"$download$dump_date/$pageprops.gz"

gunzip "$page.gz" "$pagelinks.gz" "$redirect.gz" "$pageprops.gz"


# Pre-process
"$dir"/maria2csv.py "$page" \
    | csvformat -q "'" -b -p '\' \
    | csvcut -c page_id,page_namespace,page_title \
    | csvgrep -c page_namespace -r "^0$|^14$" \
    | csvformat -D $'\t' \
    | tail -n+2 \
    | sed "s/\([0-9]\+\)\t\([0-9]\+\)\t\(.*\)/\1\t\2\3/" \
> "$wiki"page.lines

"$dir"/maria2csv.py "$pagelinks" \
    | csvformat -q "'" -b -p '\' \
    | csvgrep -c pl_from_namespace -r "^0$|^14$" \
    | csvgrep -c pl_namespace -r "^0$|^14$" \
    | csvcut -C pl_from_namespace \
    | csvformat -D $'\t' \
    | tail -n+2 \
    | sed "s/\([0-9]\+\)\t\([0-9]\+\)\t\(.*\)/\1\t\2\3/" \
> "$wiki"pagelinks.lines

"$dir"/maria2csv.py "$redirect" \
    | csvformat -q "'" -b -p '\' \
    | csvcut -c rd_from,rd_namespace,rd_title \
    | csvgrep -c rd_namespace -r "^0$|^14$" \
    | csvformat -D $'\t' \
    | tail -n+2 \
    | sed "s/\([0-9]\+\)\t\([0-9]\+\)\t\(.*\)/\1\t\2\3/" \
> "$wiki"redirect.lines

"$dir"/maria2csv.py "$pageprops" \
    | csvformat -q "'" -b -p '\' \
    | csvcut -c pp_page,pp_propname,pp_value \
    | csvgrep -c pp_propname -r "^wikibase_item$" \
    | csvcut -c pp_value,pp_page \
    | csvformat -D $'\t' \
    | tail -n+2 \
> "$wiki"pageprops.lines

exit
# Delete sql files.
#rm "$page" "$pagelinks" "$redirect" "$pageprops"

# Ensure proper sorting order
export LC_ALL=C

# Prepare page table - needed to normalize pagelinks and redirects
sort -S 50% \
	--field-separator=$'\t' --key=2 \
	-o "$wiki""page.lines" \
	"$wiki""page.lines"

# Prepare pagelinks
sort -S 50% \
	--field-separator=$'\t' --key=2 \
	-o "$wiki""pagelinks.lines" \
	"$wiki""pagelinks.lines"

# Normalize pagelinks
join -j 2 \
	"$wiki""pagelinks.lines" \
	"$wiki""page.lines" \
	-o 1.1,2.1 -t $'\t' \
> "$wiki""pagelinks_norm.lines"

# Prepare redirects
sort -S 50% \
	--field-separator=$'\t' --key=2 \
	-o "$wiki""redirect.lines" \
	"$wiki""redirect.lines"

# Normalize redirects
join -j 2 \
	"$wiki""redirect.lines" \
	"$wiki""page.lines" \
	-o 2.1,1.1 -t $'\t' \
> "$wiki""redirect_norm.lines"


# Take care of redirects. Note: 'double redirects' are fixed by bots
# (https://en.wikipedia.org/wiki/Wikipedia:Double_redirects).
sort -S 50% \
	--field-separator=$'\t' --key=2 \
	-o "$wiki""pagelinks_norm.lines" \
	"$wiki""pagelinks_norm.lines"

sort -S 50% \
	--field-separator=$'\t' --key=2 \
	-o "$wiki""redirect_norm.lines" \
	"$wiki""redirect_norm.lines"

join -j 2 \
	"$wiki""pagelinks_norm.lines" \
	"$wiki""redirect_norm.lines" \
	-o 1.1,2.1 -t $'\t' \
> "$wiki""pagelinks_redirected.lines"


# We can write this back to our page links set (potentially duplicating links)
# because in the following step redirect pages have no Q-id (redirect pages are filtered out).
cat "$wiki""pagelinks_redirected.lines" >> "$wiki""pagelinks_norm.lines"


# Resolve internal IDs to Wikidata Q-Is
sort -S 50% \
	--field-separator=$'\t' --key=2 \
	-o "$wiki""pagelinks_norm.lines" \
	"$wiki""pagelinks_norm.lines"
sort -S 50% \
	--field-separator=$'\t' --key=2 \
	-o "$wiki""pageprops.lines" \
	"$wiki""pageprops.lines"
join -j 2 \
	"$wiki""pagelinks_norm.lines" \
	"$wiki""pageprops.lines" \
	-o 2.1,1.1 -t $'\t' \
> "$wiki""pagelinks.lines"

sort -S 50% \
	--field-separator=$'\t' --key=2 \
	-o "$wiki""pagelinks.lines" \
	"$wiki""pagelinks.lines"
join -j 2 \
	"$wiki""pagelinks.lines" \
	"$wiki""pageprops.lines" \
	-o 2.1,1.1 -t $'\t' \
	| sed "s/\(Q\|q\)\(.*\)\t\(Q\|q\)\(.*\)/\2\t\4/" \
> "$wiki"-"$dump_date"".links"

# Sort final output, cleanup, and print filename
sort -S 50% \
	--field-separator=$'\t' \
	-k1 -k2 -nu \
	-o "$wiki"-"$dump_date"".links" \
	"$wiki"-"$dump_date"".links"

# Delete temporary files
rm "$wiki""page.lines" \
	"$wiki""pagelinks.lines" \
	"$wiki""pagelinks_norm.lines" \
	"$wiki""redirect.lines" \
	"$wiki""redirect_norm.lines" \
	"$wiki""pagelinks_redirected.lines" \
	"$wiki""pageprops.lines"

echo "$wiki"-"$dump_date"".links"
