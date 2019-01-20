#!/usr/bin/env python3

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

def init(left_sorted, start_value):
	dictionary_i_1 = {}
	previous = 0
	current_count = 1
	with open(left_sorted, encoding="utf-8") as f:
		for line in f:
			current = int(line.split("\t")[0])
			receiver = int(line.split("\t")[1])

			# always take care of inlinks
			data = dictionary_i_1.get(receiver, (0, start_value, []))
			data[2].append(current)
			dictionary_i_1[receiver] = data[0], data[1], data[2]

			# now take care of counts
			if current == previous:
				# increase counter
				current_count = current_count + 1
			else:
				if previous != 0:
					# store previousQID and reset counter
					prev = dictionary_i_1.get(previous, (0, start_value, []))
					dictionary_i_1[previous] = current_count, prev[1], prev[2]
					current_count = 1
			previous = current
		# write last bunch
		if previous != 0:
			prev = dictionary_i_1.get(previous, (0, start_value, []))
			dictionary_i_1[previous] = current_count, prev[1], prev[2]
	return dictionary_i_1

def danker(dictionary_i_1, iterations, damping):
	dictionary_i = {}
	for i in range(0, iterations):
		print(str(i + 1) + ".", end="", flush=True, file=sys.stderr)	
		for i in dictionary_i_1:
			current = dictionary_i_1.get(i)
			dank = 1 - damping
			for j in current[2]:
				inDank = dictionary_i_1.get(j)
				dank = dank + (damping * inDank[1] / inDank[0])
			dictionary_i[i] = current[0], dank, current[2]
		dictionary_i_1 = dictionary_i
		dictionary_i = {}
	print("", file=sys.stderr)
	return dictionary_i_1

if __name__ == '__main__':
	left_sorted = sys.argv[1]
	damping = float(sys.argv[2])
	iterations = int(sys.argv[3])
	start_value = float(sys.argv[4])
	start = time.time()
	dictionary_i_1 = init(left_sorted, start_value)
	dictionary_i = danker(dictionary_i_1, iterations, damping)
	for i in dictionary_i:
		print("{0:d}\t{1:.17g}".format(i, dictionary_i[i][1]))
	print("Computation of PageRank on '{0}' took {1:.2f} seconds.".format(left_sorted, time.time() - start), file=sys.stderr)
