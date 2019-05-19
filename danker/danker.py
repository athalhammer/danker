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

_INPUT_ASSERTION_ERROR = 'Input file "{0}" is not correctly sorted. "{1}" after "{2}"'

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
        return [0, start_value, start_value, False]
    return [0, start_value, start_value, []]

def init(left_sorted, start_value, smallmem):
    """
    Read left_sorted link file and initialization steps.
    """
    dictionary = {}
    previous = -1
    current_count = 1
    with open(left_sorted, encoding="utf-8") as ls_file:
        for line in ls_file:
            current = _conv_int(line.split("\t")[0].strip())
            receiver = _conv_int(line.split("\t")[1].strip())

            # take care of inlinks
            if not smallmem:
                data = dictionary.setdefault(receiver, _get_std_tuple(smallmem, start_value))
                data[3].append(current)

            # take care of counts
            if current == previous:
                # increase counter
                current_count = current_count + 1
            else:
                if previous != -1:
                    # make sure input is correctly sorted
                    assert current > previous, _INPUT_ASSERTION_ERROR.format(left_sorted,
                                                                             current, previous)
                    # store previous Q-ID and reset counter
                    prev = dictionary.get(previous, _get_std_tuple(smallmem, start_value))
                    dictionary[previous] = [current_count] + prev[1:]
                    current_count = 1
            previous = current

        # take care of last item
        if previous != -1:
            prev = dictionary.get(previous, _get_std_tuple(smallmem, start_value))
            dictionary[previous] = [current_count] + prev[1:]
    return dictionary

#@profile
def danker_smallmem(dictionary, right_sorted, iterations, damping, start_value):
    """
    Compute PageRank with right sorted file.
    """
    for iteration in range(0, iterations):
        print(str(iteration + 1) + ".", end="", flush=True, file=sys.stderr)
        previous = 0

        # positions for i and i+1 result values (alternating with iterations).
        i_location = (iteration % 2) + 1
        i_plus_1_location = ((iteration + 1) % 2) + 1

        with open(right_sorted, encoding="utf-8") as rs_file:
            for line in rs_file:
                current = _conv_int(line.split("\t")[1].strip())
                if previous != current:
                    assert previous == 0 or current > previous, _INPUT_ASSERTION_ERROR.format(
                        right_sorted, current, previous)
                    # reset dank
                    dank = 1 - damping
                    # initialize in case of no outgoing links
                    dictionary.setdefault(current, _get_std_tuple(True, start_value))

                in_link = _conv_int(line.split("\t")[0].strip())
                in_dank = dictionary.get(in_link)
                dank = dank + (damping * in_dank[i_location] / in_dank[0])
                dictionary[current][i_plus_1_location] = dank
                previous = current

                # record current node as 'touched' (it has incoming links)
                if iteration == 0:
                    dictionary[current][3] = True

            # fix 'untouched' nodes (they do not have incoming links)
            if iteration == 0:
                for k in dictionary.keys():
                    if not dictionary[k][3]:
                        dictionary[k][i_plus_1_location] = 1 - damping
                        dictionary[k][i_location] = 1 - damping
    print("", file=sys.stderr)
    return dictionary

#@profile
def danker_bigmem(dictionary, iterations, damping):
    """
    Compute PageRank with big memory option.
    """
    for iteration in range(0, iterations):

        # positions for i and i+1 result values (alternating with iterations).
        i_location = (iteration % 2) + 1
        i_plus_1_location = ((iteration + 1) % 2) + 1

        print(str(iteration + 1) + ".", end="", flush=True, file=sys.stderr)
        for j in dictionary:
            current = dictionary.get(j)
            dank = 1 - damping
            for k in current[3]:
                in_dank = dictionary.get(k)
                dank = dank + (damping * in_dank[i_location] / in_dank[0])
            dictionary[j][i_plus_1_location] = dank
    print("", file=sys.stderr)
    return dictionary

#@profile
def _main():
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
    dictionary = init(args.left_sorted, args.start_value, args.right_sorted)
    result_position = (args.iterations % 2) + 1
    if args.right_sorted:
        danker_smallmem(dictionary, args.right_sorted, args.iterations,
                        args.damping, args.start_value)
    else:
        danker_bigmem(dictionary, args.iterations, args.damping)
    print("Computation of PageRank on '{0}' with {1} took {2:.2f} seconds.".format(
        args.left_sorted, 'danker', time.time() - start), file=sys.stderr)

    for i in dictionary:
        print("{0}\t{1:.17g}".format(i, dictionary[i][result_position]))

if __name__ == '__main__':
    _main()
