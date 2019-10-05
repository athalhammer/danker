#!/usr/bin/env bash

# reproduce all arguments for Python's argparse
args=""
while [[ $# -gt 0 ]]; do
    args="$args $1"
    shift
done

# argparse with Python
formatted=$(python3 args.py $args)
pyexit=$?

# should not contain "usage" (e.g., from --help)
echo "$formatted" | grep "usage" > /dev/null
formexit=$?

if [ $formexit -eq 0 ] || [ $pyexit -ne 0 ]; then
	printf "%s\n" "$formatted"
else
	./dank.sh $formatted
fi
