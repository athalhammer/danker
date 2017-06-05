#!/usr/bin/python3

import sys


def leftJoin(file1, file2, reversePrint):
	with open(file1, encoding="utf-8") as f:
		with open(file2, encoding="utf-8") as f2:
			try:
				line1 = ""
				line2 = next(f2)
				while (True):
					line1 = next(f)
					part1 = line1.split("\t")[1].strip("\n")
					part2 = line2.split("\t")[1].strip("\n")
					while (part1 > part2):
						line2 = next(f2)
						part2 = line2.split("\t")[1].strip("\n")
					if (part1 == part2):
						if reversePrint:
							print(line2.split("\t")[0] + "\t" + line1.split("\t")[0])
						else:
							print(line1.split("\t")[0] + "\t" + line2.split("\t")[0])
			except StopIteration:
				# done
				pass

a = sys.argv[1]
b = sys.argv[2]
leftJoin(a,b,False)
leftJoin(b,a,True)
