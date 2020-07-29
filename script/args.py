#!/usr/bin/env python3

#    danker - PageRank on Wikipedia/Wikidata
#    Copyright (C) 2019  Andreas Thalhammer
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
Python argparse helper for shell script.
"""
import argparse


def main():
    """
    This function enables flexible argument parsing and outputs proper
    parameters that can be processed easily be the dank shell script.
    """
    parser = argparse.ArgumentParser(prog='./danker.sh',
                                     description='Compute PageRank on Wikipedia.',
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('wikilang', type=str, help='Wikipedia language edition, e.g. "en".' +
                        ' "ALL" for computing PageRank over all' +
                        ' languages available in a project.')
    parser.add_argument('-p', '--project', type=str, default='wiki',
                        help='Wiki project, currently supported are [wiki, wikibooks, ' +
                        'wikisource, wikiversity, wikinews, wiktionary, wikiquote].')
    parser.add_argument('-i', '--iterations', type=int, default=40,
                        help='PageRank number of iterations.')
    parser.add_argument('-d', '--damping', type=float, default=0.85,
                        help='PageRank damping factor.')
    parser.add_argument('-s', '--start', type=float, default=0.1,
                        help='PageRank starting value.')
    parser.add_argument('-t', '--dump-date', type=str, help='Dump date in the format YYYYMMDD (defaults to latest).')
    parser.add_argument('-f', '--folder', type=str, help='Folder with existing dumps, ' +
                        'needs to match project and dump-date parameters.')
    parser.add_argument('-b', '--bigmem', action='store_true',
                        help='PageRank big memory flag.')
    parser.add_argument('-l', '--links', action='store_true',
                        help='Only extract links (skip PageRank).')
    args = parser.parse_args()

    # Preparing arguments for Bash
    if args.project:
        print('-p', args.project, end='')
    if args.iterations:
        print('', '-i', args.iterations, end='')
    if args.damping:
        print('', '-d', args.damping, end='')
    if args.start:
        print('', '-s', args.start, end='')
    if args.dump_date:
        print('', '-t', args.dump_date, end='')
    if args.folder:
        print('', '-f', args.folder, end='')
    if args.bigmem:
        print('', '-b', end='')
    if args.links:
        print('', '-l', end='')
    print('', args.wikilang)

if __name__ == '__main__':
    main()
