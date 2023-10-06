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

# Substitute output for testing 'ALL' option.
# printf "ch\ncr\nfj\n"
# exit 0

declare -A WIKIS
WIKIS=( ["wiki"]="wp" ["wikibooks"]="wb" ["wikisource"]="ws" ["wikiversity"]="wv"
        ["wikinews"]="wn" ["wiktionary"]="wt" ["wikiquote"]="wq" ["test"]="test")

# default is normal Wikipedia (wp)
project="wp"

if [ "$1" ]; then
	project=${WIKIS[$1]}
fi
if [ ! "$project" ]; then
	(>&2 printf "[Error]\tno project found for '%s'.\n" "$1")
	exit 1
fi

if [ "$project" = "test" ]; then
	result=$(printf "anp\nch\nmad\nty\n")
else
	result=$(curl --retry-connrefused --retry 5 --retry-delay 60 -s "https://wikistats.wmcloud.org/display.php?t=$project" \
		| sed -n 's;\(.*text\)\{2\}.*>\(.*\)</a>.*;\2;p'  `# Parse wiki names` \
		| sed "s/-/_/g"                                   `# Replace "-" with "_"` \
		| sed "s/be_tarask/be_x_old/" 	                  `# Manual fix for be_x_old` \
		| sort)
fi

# ensure proper exit code
if [ "$result" ]; then
	echo "$result"
	exit 0
else
	exit 1
fi
