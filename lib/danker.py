#!/usr/bin/python3
import sys

dictionary = {}

def init(leftSorted, startValue):
	previousQID = 0
	currentCount = 1
	with open(leftSorted, encoding="utf-8") as f:
		for line in f:
			currentQID = int(line.split("\t")[0])
			if (currentQID == previousQID):
				# increase counter
				currentCount = currentCount + 1
			else:
				if (previousQID != 0):
					# store previousQID and reset counter
					dictionary[previousQID] = currentCount, startValue
					currentCount = 1
			previousQID = currentQID
		# write last bunch
		dictionary[previousQID] = currentCount, startValue

def danker(rightSorted, iterations, damping, startValue):
	for i in range(0, iterations):
		previous = 0
		with open(rightSorted, encoding="utf-8") as f:
			for line in f:
				current = int(line.split("\t")[1])
				currentDank = dictionary.get(current, (0, startValue))
				if (previous != current):
					dictionary[current] = currentDank[0], 1 - damping
				inlink = int(line.split("\t")[0])
				inDank = dictionary.get(inlink)
				dankInOutgoing = inDank[0]
				dankIn = inDank[1]
				dank = currentDank[1] + (damping * dankIn / dankInOutgoing)
				dictionary[current] = currentDank[0], dank
				previous = current

if __name__ == '__main__':
	# TODO implement with argparse
	leftSorted = sys.argv[1]
	rightSorted = sys.argv[2]
	startValue = float(sys.argv[3])
	iterations = int(sys.argv[4])
	damping = float(sys.argv[5])
	init(leftSorted, startValue)
	danker(rightSorted, iterations, damping, startValue)
	for i in dictionary.keys():
		print(str(i) + "\t" + str(dictionary[i][1]))
