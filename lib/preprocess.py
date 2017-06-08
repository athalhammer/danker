#!/usr/bin/python3
import sys

try:
	with open(sys.argv[1], encoding="utf-8", errors='ignore') as f:
		for line in f:
			if line.startswith("INSERT"):		
				line = line.replace("),(", ")\n(")
				print(line)
except FileNotFoundError:
	print("Couldn't find file " + sys.argv[1], file=sys.stderr)
