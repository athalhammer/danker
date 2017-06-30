#!/bin/bash

###################### VARIABLES
url="https://dumps.wikimedia.org/""$1""wiki/latest/"
pagelinks="$1""wiki-latest-pagelinks.sql"
pageprops="$1""wiki-latest-page_props.sql"
page="$1""wiki-latest-page.sql"
redirects="$1""wiki-latest-redirect.sql"
md5sums="$1""wiki-latest-md5sums.txt"
folder="$2"

###################### DOWNLOAD AND UNZIP
wget -q "$url""$pagelinks"".gz" "$url""$pageprops"".gz" "$url""$page"".gz" "$url""$redirects"".gz" "$url""$md5sums"
gunzip -f "$1"*.gz

###################### PRE-PROCESSING
export LC_ALL=C.UTF-8
dump_date=`head -n 1 "$1"wiki-latest-md5sums.txt | sed "s/\(.*\) \(.*\)-\(.*\)-\(.*\)/\3/"`
python3 lib/preprocess.py $pagelinks | sed -n "s/\(.*\)(\(.*\),0,'\(.*\)',0)\(.*\)/\2\t\3/p"  > "$1""pagelinks.lines"
python3 lib/preprocess.py $pageprops | sed -n "s/\(.*\)(\(.*\),'wikibase_item','\(.*\)',\(.*\))\(.*\)/\3\t\2/p" > "$1""pageprops.lines"
python3 lib/preprocess.py $redirects | sed -n "s/\(.*\)(\(.*\),0,'\(.*\)','\(.*\)','\(.*\)')\(.*\)/\2\t\3/p" > "$1""redirects.lines"

# the page table does not always contain 14 fields (has 14 in MediaWiki 1.30.0-wmf.1, additional column "page_no_title_convert" in MediaWiki 1.30.0-wmf.2)
if grep -q 'page_no_title_convert' $page; then
python3 lib/preprocess.py $page | sed -n "s/\(.*\)(\(.*\),0,'\(.*\)'\(,.*\)\{12\})\(.*\)/\2\t\3/p" > "$1""page.lines"
else
python3 lib/preprocess.py $page | sed -n "s/\(.*\)(\(.*\),0,'\(.*\)'\(,.*\)\{11\})\(.*\)/\2\t\3/p" > "$1""page.lines"
fi
rm "$1"*.sql
rm "$1"*.txt
###################### JOINS
export LC_ALL=C
sort --field-separator=$'\t' --key=2 -o "$1""page.lines" "$1""page.lines"
sort --field-separator=$'\t' --key=2 -o "$1""pagelinks.lines" "$1""pagelinks.lines"
python3 lib/join.py "$1""pagelinks.lines" "$1""page.lines" > "$1""pagelinks2.lines"
sort --field-separator=$'\t' --key=2 -o "$1""pagelinks2.lines" "$1""pagelinks2.lines"

# take care of redirects (note: 'double redirects' are fixed by bots --> https://en.wikipedia.org/wiki/Wikipedia:Double_redirects)
sort --field-separator=$'\t' --key=2 -o "$1""redirects.lines" "$1""redirects.lines"
python3 lib/join.py "$1""redirects.lines" "$1""page.lines" | sed "s/\(.*\)\t\(.*\)/\2\t\1/" > "$1""redirects2.lines"
sort --field-separator=$'\t' --key=2 -o "$1""redirects2.lines" "$1""redirects2.lines"
python3 lib/join.py "$1""pagelinks2.lines" "$1""redirects2.lines" > "$1""pagelinks22.lines"
cat "$1""pagelinks22.lines" >> "$1""pagelinks2.lines"
# end redirects

sort --field-separator=$'\t' --key=2 -o "$1""pagelinks2.lines" "$1""pagelinks2.lines"
sort --field-separator=$'\t' --key=2 -o "$1""pageprops.lines" "$1""pageprops.lines"
python3 lib/join.py "$1""pagelinks2.lines" "$1""pageprops.lines" | sed "s/\(.*\)\t\(.*\)/\2\t\1/" > "$1""pagelinks.lines"
sort --field-separator=$'\t' --key=2 -o "$1""pagelinks.lines" "$1""pagelinks.lines"
python3 lib/join.py "$1""pagelinks.lines" "$1""pageprops.lines" | sed "s/\(Q\|q\)\(.*\)\t\(Q\|q\)\(.*\)/\4\t\2/" > "$1""pagelinks2.lines"
sort "$1""pagelinks2.lines" | uniq > "$2"/"$1"-"$dump_date"".links"
#bzip2 "$1"".links"
rm "$1"*.lines
