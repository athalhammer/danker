#!/usr/bin/python3
import sys

#ranks = array('f')
numberOutgoing = {}

def initOutgoing(leftSorted):
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
					numberOutgoing[previousQID] = currentCount
					currentCount = 1
			previousQID = currentQID
	for i in numberOutgoing.keys():
		print(str(i) + "\t" + str(numberOutgoing[i]))

if __name__ == '__main__':
	leftSorted = sys.argv[1]
	rightSorted = sys.argv[2]
	iterations = int(sys.argv[3])
	damping = float(sys.argv[4])
	initOutgoing(leftSorted)
	#danker(leftSorted, rightSorted, iterations, damping)
