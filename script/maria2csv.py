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

import re
import argparse
import sys
import signal
from collections import OrderedDict

# Fix broken pipe error.
# More details: https://bugs.python.org/issue1652
signal.signal(signal.SIGPIPE, signal.SIG_DFL)

# \w matches most unicode characters including _. $ is needed in addition.
# https://mariadb.com/kb/en/library/identifier-names/
COLUMN_DEF_REGEX = r'^\s*`([\w$]+)` (\w+)(\(\d+\))? '

PLAIN_MARIADB_DATATYPE = '([^,^a-z^A-Z]*)'
QUOTED_MARIADB_DATATYPE = r"('([^']|\\\')*')"
SQL_NULL = 'NULL'

# TODO extend
QUOTED_DATATYPES = ['varchar', 'varbinary', 'blob', 'char', 'binary', 'text']

def main():
    parser = argparse.ArgumentParser(description="Parse MariaDB dumps.")
    parser.add_argument('dump_file', nargs='?', type=str, default=sys.stdin.fileno(),
                        help='Path of MariaDB dump file.')
    args = parser.parse_args()
    if args.dump_file == sys.stdin.fileno() and sys.stdin.isatty():
        print("[Error] maria2csv has no interactive mode. Type --help for options.",
              file=sys.stderr)
        sys.exit(1)

    # Note: Lines with non-unicode characters will be ignored
    with open(args.dump_file, mode='r', encoding='utf-8', errors='surrogateescape') as in_file:
        data_dict = OrderedDict()
        line = in_file.readline()

        # counter for expected regex matches based on data_dict entries
        group_counter = 0
        while not line.startswith('INSERT') and line != '':

            # Check for column definition lines
            # Assumption: each column definition has its own line (typical for dumps)
            match = re.search(COLUMN_DEF_REGEX, line)
            if match:
                name = match.group(1)
                datatype = match.group(2)
                if datatype.lower() in QUOTED_DATATYPES:
                    expr = QUOTED_MARIADB_DATATYPE[:-1]
                    group_counter += 2
                else:
                    expr = PLAIN_MARIADB_DATATYPE[:-1]
                    group_counter += 1
                if 'NOT NULL' not in line:
                    expr += '|' + SQL_NULL
                expr += ')'
                data_dict[name] = expr
            line = in_file.readline()

        # build regex with a bit of lookahead
        regex = r'\(' + ','.join([data_dict[i] for i in data_dict]) + r'\)(?=((,\()|;))'
        group_counter += 2
        # header of CSV
        print(",".join(data_dict))

        # Parse rest of file
        pattern = re.compile(regex)
        while line.startswith('INSERT'):
            for match in pattern.finditer(line):
                if len(match.groups()) != group_counter:
                    print('[Error] "' + match.group() +
                          ' does not correspond to "' + ",".join(data_dict) +
                          '".', file=sys.stderr)
                    sys.exit(1)

                # Handle errors when surrogate escapes can not be printed
                try:
                    print(match.group()[1:-1])
                except UnicodeEncodeError:
                    # ignore lines with non-unicode characters
                    pass
            line = in_file.readline()

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(1)
