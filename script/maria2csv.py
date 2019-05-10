#!/usr/bin/env python3

import sys
import re
import argparse
import signal

# Fix broken pipe error.
# More details: https://bugs.python.org/issue1652
try:
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)
except (ImportError, AttributeError):
    pass


COLUMN_DEF_REGEX = r'`([\w_]+)` (\w+)(\(\d+\))? '
PLAIN_MARIADB_DATATYPE = '([^,]*)'
QUOTED_MARIADB_DATATYPE = r"('([^']|\\\')*')"
SQL_NULL = 'NULL'

# TODO extend
QUOTED = ['varchar', 'varbinary', 'blob']

def main():
    parser = argparse.ArgumentParser(description="Parse MariaDB dumps.")
    parser.add_argument('mysqldump', type=str, help='Location of the MariaDB dump.')
    args = parser.parse_args()

    # Note that errors='ignore' ignores rows with blobs.
    with open(args.mysqldump, mode='r', encoding='utf-8', errors='ignore') as in_file:
        data_dict = {}
        create_tab_stmt = False
        line = in_file.readline()
        while not line.startswith('INSERT'):
            line = in_file.readline()
            if line.startswith('CREATE TABLE'):
                create_tab_stmt = True
                # Go directly to next line
                continue
            if 'PRIMARY' in line and create_tab_stmt:
                create_tab_stmt = False
            if create_tab_stmt:
                match = re.search(COLUMN_DEF_REGEX, line)
                name = match.group(1)
                datatype = match.group(2)
                if datatype in QUOTED:
                    expr = QUOTED_MARIADB_DATATYPE[:-1]
                else:
                    expr = PLAIN_MARIADB_DATATYPE[:-1]
                if 'NOT NULL' not in line:
                    expr += '|' + SQL_NULL
                expr += ')'
                data_dict[name] = expr

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
                except BrokenPipeError:
                    pass
            line = in_file.readline()

if __name__ == '__main__':
    main()
