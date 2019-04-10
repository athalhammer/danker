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

###################### TRANSFORMING WIKI NAMES WITH DASH CHARACTERS
wiki=$(echo "$1" | sed "s/-/_/g")

###################### VARIABLES
download="http://download.wikimedia.org/""$wiki""wiki/"
rss="https://dumps.wikimedia.org/""$wiki""wiki/latest/"

###################### DOWNLOAD AND UNZIP
wget -q "$rss""$wiki""wiki-latest-pagelinks.sql.gz-rss.xml" "$rss""$wiki""wiki-latest-page_props.sql.gz-rss.xml" "$rss""$wiki""wiki-latest-page.sql.gz-rss.xml" "$rss""$wiki""wiki-latest-redirect.sql.gz-rss.xml"
dump_date=$(cat *.xml | sed -n "s#^                <link>$download\(.*\)</link>#\1#p" | sort -S 50% -u | head -n 1)
rm *.xml
pagelinks="$wiki""wiki-""$dump_date""-pagelinks.sql"
pageprops="$wiki""wiki-""$dump_date""-page_props.sql"
page="$wiki""wiki-""$dump_date""-page.sql"
redirects="$wiki""wiki-""$dump_date""-redirect.sql"
wget -q "$download""$dump_date""/""$pagelinks"".gz" "$download""$dump_date""/""$pageprops"".gz" "$download""$dump_date""/""$page"".gz" "$download""$dump_date""/""$redirects"".gz" 
gunzip -f "$wiki"*.gz

###################### PRE-PROCESSING
export LC_ALL=en_US.UTF-8
sed -n "s/),(/)\n(/gp" $pagelinks | sed -n "s/\(.*\)(\(.*\),\(0\|14\),'\(.*\)',\(0\|14\))\(.*\)/\2\t\3\4/p" > "$wiki""pagelinks.lines"
sed -n "s/),(/)\n(/gp" $pageprops | sed -n "s/\(.*\)(\(.*\),'wikibase_item','\(.*\)',\(.*\))\(.*\)/\3\t\2/p" > "$wiki""pageprops.lines"
sed -n "s/),(/)\n(/gp" $redirects | sed -n "s/\(.*\)(\(.*\),\(0\|14\),'\(.*\)','\(.*\)','\(.*\)')\(.*\)/\2\t\3\4/p" > "$wiki""redirects.lines"
sed -n "s/),(/)\n(/gp" $page | sed -n "s/','/##W31rdS3P4R4T0R##/p" | sed -n "s/\(.*\)(\(.*\),\(0\|14\),'\(.*\)##W31rdS3P4R4T0R##.*$/\2\t\3\4/p" > "$wiki""page.lines"

rm "$wiki"*.sql
###################### JOINS
export LC_ALL=C
sort -S 50% --field-separator=$'\t' --key=2 -o "$wiki""page.lines" "$wiki""page.lines"
sort -S 50% --field-separator=$'\t' --key=2 -o "$wiki""pagelinks.lines" "$wiki""pagelinks.lines"
join -j 2 "$wiki""pagelinks.lines" "$wiki""page.lines" -o 1.1,2.1 -t $'\t' > "$wiki""pagelinks2.lines"
sort -S 50% --field-separator=$'\t' --key=2 -o "$wiki""pagelinks2.lines" "$wiki""pagelinks2.lines"

# take care of redirects (note: 'double redirects' are fixed by bots --> https://en.wikipedia.org/wiki/Wikipedia:Double_redirects)
sort -S 50% --field-separator=$'\t' --key=2 -o "$wiki""redirects.lines" "$wiki""redirects.lines"
join -j 2 "$wiki""redirects.lines" "$wiki""page.lines" -o 2.1,1.1 -t $'\t' > "$wiki""redirects2.lines"
sort -S 50% --field-separator=$'\t' --key=2 -o "$wiki""redirects2.lines" "$wiki""redirects2.lines"
join -j 2 "$wiki""pagelinks2.lines" "$wiki""redirects2.lines" -o 1.1,2.1 -t $'\t' > "$wiki""pagelinks22.lines"

# we can write this back to our page links set (potentially duplicating links)
# because in the following step redirect pages have no Q-id (redirect pages are filtered out).
cat "$wiki""pagelinks22.lines" >> "$wiki""pagelinks2.lines"
# end redirects

###################### GET Q-IDs
sort -S 50% --field-separator=$'\t' --key=2 -o "$wiki""pagelinks2.lines" "$wiki""pagelinks2.lines"
sort -S 50% --field-separator=$'\t' --key=2 -o "$wiki""pageprops.lines" "$wiki""pageprops.lines"
join -j 2 "$wiki""pagelinks2.lines" "$wiki""pageprops.lines" -o 2.1,1.1 -t $'\t' > "$wiki""pagelinks.lines"
sort -S 50% --field-separator=$'\t' --key=2 -o "$wiki""pagelinks.lines" "$wiki""pagelinks.lines"
join -j 2 "$wiki""pagelinks.lines" "$wiki""pageprops.lines" -o 2.1,1.1 -t $'\t' | sed "s/\(Q\|q\)\(.*\)\t\(Q\|q\)\(.*\)/\2\t\4/" > "$wiki""pagelinks2.lines"
sort -S 50% --field-separator=$'\t' -k1 -k2 -nuo "$wiki"-"$dump_date"".links" "$wiki""pagelinks2.lines"
rm "$wiki"*.lines
echo "$wiki"-"$dump_date"".links"
