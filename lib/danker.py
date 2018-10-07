#!/usr/bin/python3
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

import sys
import time

dictionary = {}

def init(leftSorted, startValue):
	previous = 0
	currentCount = 1
	with open(leftSorted, encoding="utf-8") as f:
		for line in f:
			current = int(line.split("\t")[0])
			if (current == previous):
				# increase counter
				currentCount = currentCount + 1
			else:
				if (previous != 0):
					# store previousQID and reset counter
					dictionary[previous] = currentCount, startValue
					currentCount = 1
			previous = current
		# write last bunch
		if (previous != 0):
			dictionary[previous] = currentCount, startValue

def danker(rightSorted, iterations, damping, startValue):
	for i in range(0, iterations):
		print(str(i + 1) + ".", end="", flush=True, file=sys.stderr)
		previous = 0
		with open(rightSorted, encoding="utf-8") as f:
			for line in f:
				current = int(line.split("\t")[1])
				currentDank = dictionary.get(current, (0, startValue))
				if (previous != current):
					currentDank = currentDank[0], (1 - damping)
				inlink = int(line.split("\t")[0])
				inDank = dictionary.get(inlink)
				dank = currentDank[1] + (damping * inDank[1] / inDank[0])
				dictionary[current] = currentDank[0], dank
				previous = current
				
		# after the first iteration, fix nodes that don't have inlinks.
		if i == 0:
			for n in dictionary.keys():
				node = dictionary[n]
				if node[1] == startValue:
					dictionary[n] = node[0], 1 - damping
	print("", file=sys.stderr)

if __name__ == '__main__':
	leftSorted = sys.argv[1]
	rightSorted = sys.argv[2]
	damping = float(sys.argv[3])
	iterations = int(sys.argv[4])
	startValue = float(sys.argv[5])
	start = time.time()
	init(leftSorted, startValue)
	danker(rightSorted, iterations, damping, startValue)
	for i in dictionary.keys():
		print(str(i) + "\t" + str(dictionary[i][1]))
	print("Computation of PageRank on '" + leftSorted + "' took " + str(int(100* (time.time() - start)) / 100) + " seconds.", file=sys.stderr)
