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

"""
danker
"""
import sys
import time
import argparse
#import memory_profiler

INPUT_ASSERTION_ERROR = 'Input file "{0}" is not correctly sorted. "{1}" after "{2}"'

def _conv_int(string):
    """
    Helper function to optimize memory usage.
    """
    if string.isdigit():
        return int(string)
    return string

def _get_std_tuple(smallmem, start_value):
    """
    Helper function to return standard tuple (with or without linked list)
    """
    if smallmem:
        return (0, start_value)
    return (0, start_value, [])

def init(left_sorted, start_value, smallmem):
    """
    Read left_sorted link file and initialization steps.
    """
    dictionary_i_1 = {}
    previous = -1
    current_count = 1
    with open(left_sorted, encoding="utf-8") as ls_file:
        for line in ls_file:
            current = _conv_int(line.split("\t")[0].strip())
            receiver = _conv_int(line.split("\t")[1].strip())

            # take care of inlinks
            if not smallmem:
                data = dictionary_i_1.get(receiver, _get_std_tuple(smallmem, start_value))
                data[2].append(current)
                # make sure to store it in the dict (could be there already)
                dictionary_i_1[receiver] = data

            # take care of counts
            if current == previous:
                # increase counter
                current_count = current_count + 1
            else:
                if previous != -1:
                    # make sure input is correctly sorted
                    assert(current > previous), INPUT_ASSERTION_ERROR.format(left_sorted,
                                                                             current, previous)

                    # store previousQID and reset counter
                    prev = dictionary_i_1.get(previous, _get_std_tuple(smallmem, start_value))
                    dictionary_i_1[previous] = (current_count,) + prev[1:]
                    current_count = 1
            previous = current

        # take care of last item
        if previous != -1:
            prev = dictionary_i_1.get(previous, _get_std_tuple(smallmem, start_value))
            dictionary_i_1[previous] = (current_count,) + prev[1:]
    return dictionary_i_1

def danker_smallmem(dictionary_i_1, right_sorted, iterations, damping, start_value):
    """
    Compute PageRank with right sorted file.
    """
    dictionary_i = {}
    for i in range(0, iterations):
        print(str(i + 1) + ".", end="", flush=True, file=sys.stderr)
        previous = 0
        with open(right_sorted, encoding="utf-8") as rs_file:
            for line in rs_file:
                current = _conv_int(line.split("\t")[1].strip())
                if previous != current:
                    assert(previous == 0 or current > previous), INPUT_ASSERTION_ERROR.format(
                        right_sorted, current, previous)
                    dank = 1 - damping
                current_dank = dictionary_i_1.get(current, (0, start_value))
                in_dank = dictionary_i_1.get(_conv_int(line.split("\t")[0].strip()))
                dank = dank + (damping * in_dank[1] / in_dank[0])
                dictionary_i[current] = current_dank[0], dank
                previous = current

        # after each iteration, fix nodes that don't have inlinks
        for j in dictionary_i_1.keys() - dictionary_i.keys():
            dictionary_i[j] = dictionary_i_1[j][0], 1 - damping
        dictionary_i_1 = dictionary_i
        dictionary_i = {}

    print("", file=sys.stderr)
    return dictionary_i_1

def danker_bigmem(dictionary_i_1, iterations, damping):
    """
    Compute PageRank with big memory option.
    """
    dictionary_i = {}
    for i in range(0, iterations):
        print(str(i + 1) + ".", end="", flush=True, file=sys.stderr)
        for j in dictionary_i_1:
            current = dictionary_i_1.get(j)
            dank = 1 - damping
            for k in current[2]:
                in_dank = dictionary_i_1.get(k)
                dank = dank + (damping * in_dank[1] / in_dank[0])
            dictionary_i[j] = current[0], dank, current[2]
        dictionary_i_1 = dictionary_i
        dictionary_i = {}
    print("", file=sys.stderr)
    return dictionary_i_1

#@profile
def main():
    """
    Execute main program.
    """
    parser = argparse.ArgumentParser(description='danker PageRank.')
    parser.add_argument('left_sorted')
    parser.add_argument('--right_sorted')
    parser.add_argument('damping', type=float)
    parser.add_argument('iterations', type=int)
    parser.add_argument('start_value', type=float)
    args = parser.parse_args()
    start = time.time()
    dictionary_i_1 = init(args.left_sorted, args.start_value, args.right_sorted)
    if args.right_sorted:
        dictionary_i = danker_smallmem(dictionary_i_1, args.right_sorted,
                                       args.iterations, args.damping, args.start_value)
    else:
        dictionary_i = danker_bigmem(dictionary_i_1, args.iterations, args.damping)
    print("Computation of PageRank on '{0}' with {1} took {2:.2f} seconds.".format(
        args.left_sorted, 'danker', time.time() - start), file=sys.stderr)
    for i in dictionary_i:
        print("{0}\t{1:.17g}".format(i, dictionary_i[i][1]))

if __name__ == '__main__':
    main()
