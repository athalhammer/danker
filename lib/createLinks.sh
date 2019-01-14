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


###################### VARIABLES
download="http://download.wikimedia.org/""$1""wiki/"
rss="https://dumps.wikimedia.org/""$1""wiki/latest/"

###################### DOWNLOAD AND UNZIP
wget -q "$rss""$1""wiki-latest-pagelinks.sql.gz-rss.xml" "$rss""$1""wiki-latest-page_props.sql.gz-rss.xml" "$rss""$1""wiki-latest-page.sql.gz-rss.xml" "$rss""$1""wiki-latest-redirect.sql.gz-rss.xml"
dump_date=`cat *.xml | sed -n "s#^                <link>$download\(.*\)</link>#\1#p" | sort -S 50% -u | head -n 1`
rm *.xml
pagelinks="$1""wiki-""$dump_date""-pagelinks.sql"
pageprops="$1""wiki-""$dump_date""-page_props.sql"
page="$1""wiki-""$dump_date""-page.sql"
redirects="$1""wiki-""$dump_date""-redirect.sql"
wget -q "$download""$dump_date""/""$pagelinks"".gz" "$download""$dump_date""/""$pageprops"".gz" "$download""$dump_date""/""$page"".gz" "$download""$dump_date""/""$redirects"".gz" 
gunzip -f "$1"*.gz

###################### PRE-PROCESSING
export LC_ALL=en_US.UTF-8
sed -n "s/),(/)\n(/gp" $pagelinks | sed -n "s/\(.*\)(\(.*\),\(0\|14\),'\(.*\)',\(0\|14\))\(.*\)/\2\t\3\4/p" > "$1""pagelinks.lines"
sed -n "s/),(/)\n(/gp" $pageprops | sed -n "s/\(.*\)(\(.*\),'wikibase_item','\(.*\)',\(.*\))\(.*\)/\3\t\2/p" > "$1""pageprops.lines"
sed -n "s/),(/)\n(/gp" $redirects | sed -n "s/\(.*\)(\(.*\),\(0\|14\),'\(.*\)','\(.*\)','\(.*\)')\(.*\)/\2\t\3\4/p" > "$1""redirects.lines"
sed -n "s/),(/)\n(/gp" $page | sed -n "s/','/##W31rdS3P4R4T0R##/p" | sed -n "s/\(.*\)(\(.*\),\(0\|14\),'\(.*\)##W31rdS3P4R4T0R##.*$/\2\t\3\4/p" > "$1""page.lines"

rm "$1"*.sql
###################### JOINS
export LC_ALL=C
sort -S 50% --field-separator=$'\t' --key=2 -o "$1""page.lines" "$1""page.lines"
sort -S 50% --field-separator=$'\t' --key=2 -o "$1""pagelinks.lines" "$1""pagelinks.lines"
join -j 2 "$1""pagelinks.lines" "$1""page.lines" -o 1.1,2.1 -t $'\t' > "$1""pagelinks2.lines"
sort -S 50% --field-separator=$'\t' --key=2 -o "$1""pagelinks2.lines" "$1""pagelinks2.lines"

# take care of redirects (note: 'double redirects' are fixed by bots --> https://en.wikipedia.org/wiki/Wikipedia:Double_redirects)
sort -S 50% --field-separator=$'\t' --key=2 -o "$1""redirects.lines" "$1""redirects.lines"
join -j 2 "$1""redirects.lines" "$1""page.lines" -o 2.1,1.1 -t $'\t' > "$1""redirects2.lines"
sort -S 50% --field-separator=$'\t' --key=2 -o "$1""redirects2.lines" "$1""redirects2.lines"
join -j 2 "$1""pagelinks2.lines" "$1""redirects2.lines" -o 1.1,2.1 -t $'\t' > "$1""pagelinks22.lines"

# we can write this back to our page links set (potentially duplicating links)
# because in the following step redirect pages have no Q-id (redirect pages are filtered out).
cat "$1""pagelinks22.lines" >> "$1""pagelinks2.lines"
# end redirects

###################### GET Q-IDs
sort -S 50% --field-separator=$'\t' --key=2 -o "$1""pagelinks2.lines" "$1""pagelinks2.lines"
sort -S 50% --field-separator=$'\t' --key=2 -o "$1""pageprops.lines" "$1""pageprops.lines"
join -j 2 "$1""pagelinks2.lines" "$1""pageprops.lines" -o 2.1,1.1 -t $'\t' > "$1""pagelinks.lines"
sort -S 50% --field-separator=$'\t' --key=2 -o "$1""pagelinks.lines" "$1""pagelinks.lines"
join -j 2 "$1""pagelinks.lines" "$1""pageprops.lines" -o 2.1,1.1 -t $'\t' | sed "s/\(Q\|q\)\(.*\)\t\(Q\|q\)\(.*\)/\2\t\4/" > "$1""pagelinks2.lines"
sort -S 50% -u "$1""pagelinks2.lines" > "$1"-"$dump_date"".links"
rm "$1"*.lines
echo "$1"-"$dump_date"".links"
