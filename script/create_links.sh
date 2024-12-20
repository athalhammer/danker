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


# Check for environment variables for sort
if [ -z ${MEM_PERC+x} ]; then
	export MEM_PERC="50%"
fi

while getopts ":d:f:k" a; do
    case "${a}" in
        d)
            dump_date=${OPTARG}
            ;;
        f)
            folder=${OPTARG}
            ;;
        k)
	    keep_site_links=1
	    ;;
        *)
	    # should not occur
            ;;
    esac
done
shift $((OPTIND-1))

dir=$(dirname "$0")

latest_dump() {
	rss="https://dumps.wikimedia.org/$wiki/latest/$wiki-latest-"
	# Latest dump date
	if wget -q "$rss""page.sql.gz-rss.xml" \
	    "$rss""pagelinks.sql.gz-rss.xml" \
	    "$rss""linktarget.sql.gz-rss.xml" \
	    "$rss""redirect.sql.gz-rss.xml" \
	    "$rss""page_props.sql.gz-rss.xml"; then
		dump_date=$(cat "$wiki"*.xml | sed -n "s#.*$download\([0-9]\+\).*#\1#p" | sort -u)
	fi

	if [ "$(echo "$dump_date" | wc -l)" != '1' ] || [ "$dump_date" == '' ]; then
	    (>&2 printf "[Error]\tMultiple or no date for '%s' dump.\n" "$wiki.")
	    return 1
	fi

	rm "$wiki-latest-page.sql.gz-rss.xml" \
	    "$wiki-latest-pagelinks.sql.gz-rss.xml" \
	    "$wiki-latest-linktarget.sql.gz-rss.xml" \
	    "$wiki-latest-redirect.sql.gz-rss.xml" \
	    "$wiki-latest-page_props.sql.gz-rss.xml"
	echo "$dump_date"
}

download() {
	tmpdir=$(mktemp -d -t "danker.XXXX")
	cd "$tmpdir" || return 1

	# Download and unzip
	if ! wget -q --waitretry=1m --retry-connrefused "$download$dump_date/$page.gz" \
	    "$download$dump_date/$pagelinks.gz" \
	    "$download$dump_date/$linktarget.gz" \
	    "$download$dump_date/$redirect.gz" \
	    "$download$dump_date/$pageprops.gz"; then
		(>&2 printf "Couldn't download dumps of '%s' for date '%s'.\n" "$wiki" "$dump_date")
		rm -rf "$tmpdir"
		return 1
	fi

	gunzip "$page.gz" "$pagelinks.gz" "$redirect.gz" "$pageprops.gz" "$linktarget.gz"
	echo "$tmpdir"
}


if [ ! "$1" ]; then
    (>&2 printf "[Error]\tMissing positional wiki language parameter.
    \tExamples: [en, de, bar, ...]\n")
    exit 1
else
    invalid=$(grep "^$1$" <("$dir"/get_languages.sh "$2"))
    if [ -z "$invalid" ]; then
        (>&2 printf "[Error]\t'%s' is an invalid language parameter for '%s'.
	\tPlease check: http://wikistats.wmflabs.org/display.php\n" "$1" "$2")
        exit 1
    fi
fi

project="$2"
# default to wiki project
if [ ! "$2" ] || [ "$2" = "test" ]; then
    project="wiki"
fi
wiki="$1$project"

# Download location of dumps for project
download="http://download.wikimedia.org/$wiki/"

# Take latest if no date is specified
if [ ! "$dump_date" ]; then
    dump_date=$(latest_dump) || exit 1
fi

# Skip if file exists
if [ -f "$wiki-$dump_date"".links" ]; then
    echo "$wiki-$dump_date.links exists... skipping" 1>&2
    echo "$wiki-$dump_date"".links"
    exit 0
fi


# File names are now fully specified
page="$wiki-""$dump_date""-page.sql"
pagelinks="$wiki-""$dump_date""-pagelinks.sql"
linktarget="$wiki-""$dump_date""-linktarget.sql"
redirect="$wiki-""$dump_date""-redirect.sql"
pageprops="$wiki-""$dump_date""-page_props.sql"

# If a folder is provided, take the files from the folder
if [ ! "$folder" ]; then
    use_tmp=true
    file_dir=$(download) || exit 1
else
    use_tmp=false
    file_dir="$folder"
fi

# Pre-process
maria2csv "$file_dir/$page" \
    | csvformat -q "'" -b -p "\\" \
    | csvcut -c page_id,page_namespace,page_title \
    | csvgrep -c page_namespace -r "^0$|^14$" \
    | csvformat -D $'\t' \
    | tail -n+2 \
    | sed "s/\([0-9]\+\)\t\([0-9]\+\)\t\(.*\)/\1\t\2\3/" \
> "$wiki"page.lines

maria2csv "$file_dir/$pagelinks" \
    | csvformat -q "'" -b -p "\\" \
    | csvcut -c pl_from,pl_from_namespace,pl_target_id \
    | csvgrep -c pl_from_namespace -r "^0$|^14$" \
    | csvcut -C pl_from_namespace \
    | csvformat -D $'\t' \
    | tail -n+2 \
> "$wiki"pagelinks.lines

maria2csv "$file_dir/$linktarget" \
    | csvformat -q "'" -b -p "\\" \
    | csvgrep -c lt_namespace -r "^0$|^14$" \
    | csvformat -D $'\t' \
    | tail -n+2 \
    | sed "s/\([0-9]\+\)\t\([0-9]\+\)\t\(.*\)/\1\t\2\3/" \
> "$wiki"linktarget.lines

maria2csv "$file_dir/$redirect" \
    | csvformat -q "'" -b -p "\\" \
    | csvcut -c rd_from,rd_namespace,rd_title \
    | csvgrep -c rd_namespace -r "^0$|^14$" \
    | csvformat -D $'\t' \
    | tail -n+2 \
    | sed "s/\([0-9]\+\)\t\([0-9]\+\)\t\(.*\)/\1\t\2\3/" \
> "$wiki"redirect.lines

maria2csv "$file_dir/$pageprops" \
    | csvformat -q "'" -b -p "\\" \
    | csvcut -c pp_page,pp_propname,pp_value \
    | csvgrep -c pp_propname -r "^wikibase_item$" \
    | csvcut -c pp_value,pp_page \
    | csvformat -D $'\t' \
    | tail -n+2 \
> "$wiki"pageprops.lines

# Delete files if in tmp dir
if [ "$use_tmp" = true ]; then
	rm -rf "$file_dir"
fi

# To avoid any locale-related issues, it
# is recommended to use the ‘C’ locale [...].
# http://www.gnu.org/software/coreutils/manual/html_node/Sorting-files-for-join.html#Sorting-files-for-join
export LC_ALL=C

# Prepare page table - needed to normalize pagelinks and redirects
sort -k 2,2 \
     -S "$MEM_PERC" \
     -o "$wiki""page.lines" \
     "$wiki""page.lines"

# Prepare pagelinks
sort -k 2,2 \
     -S "$MEM_PERC" \
     -o "$wiki""pagelinks.lines" \
     "$wiki""pagelinks.lines"

# Prepare linktarget
sort -k 1,1 \
    -S "$MEM_PERC" \
    -o "$wiki"linktarget.lines \
    "$wiki"linktarget.lines

# Create pagelinks with linktarget
join -1 2 -2 1 \
     "$wiki""pagelinks.lines" \
     "$wiki"linktarget.lines \
     -o 1.1,2.2,2.1 -t $'\t' \
    | sort -k 2,2 \
> "$wiki""pagelinks_old.lines"

# Normalize pagelinks
join -j 2 \
     "$wiki""pagelinks_old.lines" \
     "$wiki""page.lines" \
     -o 1.1,2.1 -t $'\t' \
> "$wiki""pagelinks_norm.lines"

# Prepare redirects
sort -k 2,2 \
     -S "$MEM_PERC" \
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
sort -k 2,2 \
     -S "$MEM_PERC" \
     -o "$wiki""pagelinks_norm.lines" \
     "$wiki""pagelinks_norm.lines"

sort -k 2,2 \
     -S "$MEM_PERC" \
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
sort -k 2,2 \
     -S "$MEM_PERC" \
     -o "$wiki""pagelinks_norm.lines" \
     "$wiki""pagelinks_norm.lines"
sort -k 2,2 \
     -S "$MEM_PERC" \
     -o "$wiki""pageprops.lines" \
     "$wiki""pageprops.lines"
join -j 2 \
     "$wiki""pagelinks_norm.lines" \
     "$wiki""pageprops.lines" \
     -o 2.1,1.1 -t $'\t' \
> "$wiki""pagelinks.lines"

sort -k 2,2 \
     -S "$MEM_PERC" \
     -o "$wiki""pagelinks.lines" \
     "$wiki""pagelinks.lines"
join -j 2 \
     "$wiki""pagelinks.lines" \
     "$wiki""pageprops.lines" \
     -o 2.1,1.1 -t $'\t' \
     | sed "s/\(Q\|q\)\(.*\)\t\(Q\|q\)\(.*\)/\2\t\4\t$wiki-$dump_date/" \
> "$wiki-$dump_date"".links"

# Sort final output, cleanup, and print filename
sort -k 1,1n -k 2,2n -u \
     -S "$MEM_PERC" \
     -o "$wiki"-"$dump_date"".links" \
     "$wiki-$dump_date"".links"

if [ "$keep_site_links" ]; then
   mv "$wiki""pageprops.lines" "$wiki-$dump_date".site.links
else
   rm "$wiki""pageprops.lines"
fi

# Delete temporary files
rm "$wiki""page.lines" \
   "$wiki""pagelinks.lines" \
   "$wiki""pagelinks_old.lines" \
   "$wiki""linktarget.lines" \
   "$wiki""pagelinks_norm.lines" \
   "$wiki""redirect.lines" \
   "$wiki""redirect_norm.lines" \
   "$wiki""pagelinks_redirected.lines"

echo "$wiki-$dump_date"".links"
