#!/usr/bin/env bash

#    danker - PageRank on Wikipedia/Wikidata
#    Copyright (C) 2019  Andreas Thalhammer
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


# reproduce all arguments for Python's argparse
args=""
while [[ $# -gt 0 ]]; do
    args="$args $1"
    shift
done

# Flexible argparse with Python and formatting for bash.
formatted=$(python3 ./script/args.py $args)
pyexit=$?

# Output should not contain "usage" (e.g., from --help)
echo "$formatted" | grep "usage" > /dev/null
formexit=$?

if [ $formexit -eq 0 ] || [ $pyexit -ne 0 ]; then
	printf "%s\n" "$formatted"
else
	./script/dank.sh $formatted
fi
