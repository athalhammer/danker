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

try:
	with open(sys.argv[1], encoding="utf-8", errors='ignore') as f:
		for line in f:
			if line.startswith("INSERT"):		
				line = line.replace("),(", ")\n(")
				print(line)
except FileNotFoundError:
	print("Couldn't find file " + sys.argv[1], file=sys.stderr)
