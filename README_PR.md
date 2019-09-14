# danker - Compute PageRank on large graphs with off-the-shelf hardware.
 
* Standalone with any input graph:
   ```
   $ pip install danker
   $ python3 -m danker -h
   usage: __main__.py [-h]
                      left_sorted [right_sorted] damping iterations start_value

   danker - Compute PageRank on large graphs with off-the-shelf hardware.

   positional arguments:
     left_sorted   A two-column, tab-separated file sorted by the left column.
     right_sorted  The same file as left_sorted but sorted by the right column.
     damping       PageRank damping factor.
     iterations    Number of PageRank iterations.
     start_value   PageRank starting value.

   optional arguments:
     -h, --help    show this help message and exit

   ```

* As Python library for computing PageRank on large graphs:
   ```
   $ pip install danker
   $ python3
   >>> import danker
   ```
   More information on this option can be found at https://danker.rtfd.org.

More information: [Compute PageRank on the Wikipedia graph](./README.md)
