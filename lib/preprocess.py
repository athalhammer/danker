#!/usr/bin/python3
import sys

with open(sys.argv[1], encoding="utf-8", errors='ignore') as f:
	for line in f:
		if line.startswith("INSERT"):		
			line = line.replace("),(", ")\n(")
			print(line)
