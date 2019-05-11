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
    printf "Missing positional language parameter.\nExamples: \n\ten\n\tde\n\tbar\n\t...\n"
    exit 1
fi

wiki="$1"
dir=$(dirname "$0")

# Location of wikipedia dumps
DOWNLOAD="http://download.wikimedia.org/""$wiki""wiki/"
RSS="https://dumps.wikimedia.org/""$wiki""wiki/latest/"

# Latest dumps
wget -q "$RSS""$wiki""wiki-latest-pagelinks.sql.gz-rss.xml" "$RSS""$wiki""wiki-latest-page_props.sql.gz-rss.xml" "$RSS""$wiki""wiki-latest-page.sql.gz-rss.xml" "$RSS""$wiki""wiki-latest-redirect.sql.gz-rss.xml"
dump_date=$(cat *.xml | sed -n "s#^                <link>$DOWNLOAD\(.*\)</link>#\1#p" | sort -S 50% -u | head -n 1)
rm *.xml

# File locations
pagelinks="$wiki""wiki-""$dump_date""-pagelinks.sql"
pageprops="$wiki""wiki-""$dump_date""-page_props.sql"
page="$wiki""wiki-""$dump_date""-page.sql"
redirects="$wiki""wiki-""$dump_date""-redirect.sql"

# Download and pre-process
curl -sL "$DOWNLOAD$dump_date/$page.gz" \
    | gunzip \
    | "$dir"/maria2csv.py \
    | csvformat -q "'" -b -p '\' \
    | csvcut -c page_id,page_namespace,page_title \
           | csvgrep -c page_namespace -r "^0$|^14$" \
> "$wiki"page.csv
exit
curl -sL "$DOWNLOAD$dump_date/$pagelinks.gz" \
    | gunzip \
    | "$dir"/maria2csv.py \
    | csvformat -q "'" -b -p '\' \
        | csvgrep -c pl_from_namespace -r "^0$|^14$" \
    | csvgrep -c pl_namespace -r "^0$|^14$" \
> "$wiki"pagelinks.csv

curl -sL "$DOWNLOAD$dump_date/$redirects.gz" \
    | gunzip \
    | "$dir"/maria2csv.py \
    | csvformat -q "'" -b -p '\' \
    | csvcut -c rd_from,rd_namespace,rd_title \
    | csvgrep -c rd_namespace -r "^0$|^14$" \
> "$wiki"redirects.csv

curl -sL "$DOWNLOAD$dump_date/$pageprops.gz" \
    | gunzip \
    | "$dir"/maria2csv.py \
    | csvformat -q "'" -b -p '\' \
    | csvcut -c pp_page,pp_propname,pp_value \
    | csvgrep -c pp_propname -r "^wikibase_item$" \
> "$wiki"page_props.csv

# Normalize pagelinks
csvsql -I --query "
    SELECT pl.pl_from, p.page_id 
    FROM "$wiki"pagelinks pl 
    JOIN "$wiki"page p 
    ON (p.page_namespace = pl.pl_namespace 
    AND p.page_title = pl.pl_title)" \
"$wiki"pagelinks.csv "$wiki"page.csv \
> "$wiki"pagelinks_norm.csv

# Normalize redirects
csvsql -I --query "
    SELECT rd.rd_from, p.page_id
    FROM "$wiki"redirects rd
    JOIN "$wiki"page p
    ON (p.page_namespace = rd.rd_namespace
    AND rd.rd_title = p.page_title)" \
"$wiki"redirects.csv "$wiki"page.csv \
> "$wiki"redirects_norm.csv

# Resolve redirects
csvjoin -c page_id,rd_from "$wiki"pagelinks_norm.csv "$wiki"redirects_norm.csv \
    | csvcut -c pl_from,page_id2 \
> "$wiki"redirected.csv

# Stack pagelinks and redirected links
csvstack "$wiki"pagelinks_norm.csv "$wiki"redirected.csv \
> "$wiki"pagelinks_all.csv

# Resolve to Wikidata IDs
csvjoin -c pl_from,pp_page "$wiki"pagelinks_all.csv "$wiki"page_props.csv \
    | csvcut -c pp_value,page_id \
> "$wiki"pagelinks_qp.csv

csvjoin -c page_id,pp_page "$wiki"pagelinks_qp.csv "$wiki"page_props.csv \
    | csvcut -c pp_value,pp_value2 \
> "$wiki"pagelinks_qq.csv

# Write final output
tail -n+2 "$wiki"pagelinks_qq.csv \
    | sed "s/\(Q\|q\)\([0-9]\+\),\(Q\|q\)\([0-9]\+\)/\2\t\4/" \
    | sort -S 50% --field-separator=$'\t' -k1 -k2 -nu \
> "$wiki"-"$dump_date"".links"

# Delete temporary csv files
rm "$wiki"*.csv

# Output name of edge list file
echo "$wiki"-"$dump_date"".links"
