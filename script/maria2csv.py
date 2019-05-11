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

# Fix broken pipe error.
# More details: https://bugs.python.org/issue1652
signal.signal(signal.SIGPIPE, signal.SIG_DFL)


COLUMN_DEF_REGEX = r'^\s*`([\w_]+)` (\w+)(\(\d+\))? '
PLAIN_MARIADB_DATATYPE = '([^,]*)'
QUOTED_MARIADB_DATATYPE = r"('([^']|\\\')*')"
SQL_NULL = 'NULL'

# TODO extend
QUOTED_DATATYPES = ['varchar', 'varbinary', 'blob', 'char', 'binary', 'text']

def main():
    parser = argparse.ArgumentParser(description="Parse MariaDB dumps.")
    parser.add_argument('dump_file', nargs='?', type=str, default=sys.stdin.fileno(),
                        help='Path of MariaDB dump file.')
    args = parser.parse_args()

    # Note that errors='ignore' ignores rows with blobs.
    with open(args.dump_file, mode='r', encoding='utf-8', errors='ignore') as in_file:
        data_dict = {}
        line = in_file.readline()
        while not line.startswith('INSERT'):

            # Check for column definition lines
            # Assumption: each column definition has its own line (typical for dumps)
            match = re.search(COLUMN_DEF_REGEX, line)
            if match:
                name = match.group(1)
                datatype = match.group(2)
                if datatype.lower() in QUOTED_DATATYPES:
                    expr = QUOTED_MARIADB_DATATYPE[:-1]
                else:
                    expr = PLAIN_MARIADB_DATATYPE[:-1]
                if 'NOT NULL' not in line:
                    expr += '|' + SQL_NULL
                expr += ')'
                data_dict[name] = expr
            line = in_file.readline()

        # This only works in Python 3.7 as earlier versions do not guarantee
        # insertion order in dictionaries (3.6 has it implemented though)
        regex = r'\(' + ','.join([data_dict[i] for i in data_dict]) + r'\)'

        print(",".join(data_dict))

        # Parse rest of file
        pattern = re.compile(regex)
        while line.startswith('INSERT'):
            for match in pattern.finditer(line):
                try:
                    print(match.group()[1:-1])
                except KeyboardInterrupt:
                    sys.exit(1)
            line = in_file.readline()

if __name__ == '__main__':
    main()
