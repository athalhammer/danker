#!/usr/bin/python3
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

# TODO to be replaced by SED/AWK
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
if __name__ == '__main__':
	a = sys.argv[1]
	b = sys.argv[2]
	leftJoin(a, b, False)
	leftJoin(b, a, True)
