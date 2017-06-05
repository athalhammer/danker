#!/bin/bash

###################### VARIABLES
url="https://dumps.wikimedia.org/""$1""wiki/latest/"
pagelinks="$1""wiki-latest-pagelinks.sql"
pageprops="$1""wiki-latest-page_props.sql"
page="$1""wiki-latest-page.sql"
redirect="$1""wiki-latest-redirect.sql"

###################### DOWNLOAD AND UNZIP
wget "$url""$pagelinks"".gz" "$url""$pageprops"".gz" "$url""$page"".gz" "$url""$redirect"".gz"
gunzip -f "$1"*.gz

###################### PRE-PROCESSING
export LC_ALL=C.UTF-8
python3 lib/preprocess.py $pagelinks | grep -P "([0-9]+,0,'.*',0)" | sed s/"\(.*\)(\(.*\),0,'\(.*\)',0)\(.*\)"/"\2\t\3"/  > "$1""pagelinks.lines"
python3 lib/preprocess.py $pageprops | grep "wikibase_item" | sed s/"\(.*\)(\(.*\),'\(.*\)','\(.*\)',\(.*\))\(.*\)"/"\4\t\2"/ > "$1""pageprops.lines"
python3 lib/preprocess.py $redirect | grep -P "\([0-9]+,0,'.*','.*','.*'\)" | sed s/"\(.*\)(\(.*\),0,'\(.*\)','\(.*\)','\(.*\)')\(.*\)"/"\3\t\2"/ | grep -v "^$" > "$1""redirect.lines"

# the page table does not always contain 14 fields (has 14 in MediaWiki 1.30.0-wmf.1, additional column "page_no_title_convert" in MediaWiki 1.30.0-wmf.2)
if grep -q 'page_no_title_convert' $page; then
python3 lib/preprocess.py $page | grep -P "\([0-9]+,0,'.*'(,.*){12}\)" | sed s/"\(.*\)(\(.*\),0,'\(.*\)'\(,.*\)\{12\})\(.*\)"/"\2\t\3"/ | grep -v "^$"> "$1""page.lines"
else
python3 lib/preprocess.py $page | grep -P "\([0-9]+,0,'.*'(,.*){11}\)" | sed s/"\(.*\)(\(.*\),0,'\(.*\)'\(,.*\)\{11\})\(.*\)"/"\2\t\3"/ | grep -v "^$"> "$1""page.lines"
fi
rm "$1"*.sql

###################### JOINS
export LC_ALL=C
sort --field-separator=$'\t' --key=2 -o "$1""page.lines" "$1""page.lines"
sort --field-separator=$'\t' --key=2 -o "$1""pagelinks.lines" "$1""pagelinks.lines"
python3 lib/join.py "$1""pagelinks.lines" "$1""page.lines" > "$1""pagelinks2.lines"

# take care of redirects (we assume only one hop redirects otherwise this process needs to be repeated several times)
sort --field-separator=$'\t' --key=2 -o "$1""pagelinks2.lines" "$1""pagelinks2.lines"
sort --field-separator=$'\t' --key=2 -o "$1""redirect.lines" "$1""redirect.lines"
python3 lib/join.py "$1""pagelinks2.lines" "$1""redirect.lines" > "$1""pagelinks22.lines"
sort --field-separator=$'\t' --key=2 -o "$1""pagelinks22.lines" "$1""pagelinks22.lines"
python3 lib/join.py "$1""pagelinks22.lines" "$1""page.lines" >> "$1""pagelinks2.lines"
# end redirects

sort --field-separator=$'\t' --key=2 -o "$1""pagelinks2.lines" "$1""pagelinks2.lines"
sort --field-separator=$'\t' --key=2 -o "$1""pageprops.lines" "$1""pageprops.lines"
# switch one time
python3 lib/join.py "$1""pagelinks2.lines" "$1""pageprops.lines" | sed s/'\(.*\)\t\(.*\)'/'\2\t\1'/ > "$1""pagelinks3.lines"
sort --field-separator=$'\t' --key=2 -o "$1""pagelinks3.lines" "$1""pagelinks3.lines"
# switch back
python3 lib/join.py "$1""pagelinks3.lines" "$1""pageprops.lines" | sed s/'\(.*\)\t\(.*\)'/'\2\t\1'/ > "$1""pagelinks4.lines"
sort "$1""pagelinks4.lines" | uniq > "$1"".links"
bzip2 "$1"".links"
rm "$1"*.lines
