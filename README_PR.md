# danker - Compute PageRank on large graphs with off-the-shelf hardware.
 
* Standalone with any input graph:
   ```
   $ pip install danker
   $ python -m danker -h
     usage: python -m danker [-h]
                             left_sorted [right_sorted] damping iterations
                             start_value

     danker - Compute PageRank on large graphs with off-the-shelf hardware.

     positional arguments:
       left_sorted   A two-column, tab-separated file sorted by the left column.
       right_sorted  The same file as left_sorted but sorted by the right column.
       damping       PageRank damping factor(between 0 and 1).
       iterations    Number of PageRank iterations (>0).
       start_value   PageRank starting value(>0).

     optional arguments:
       -h, --help    show this help message and exit

   $ wget https://raw.githubusercontent.com/athalhammer/danker/master/test/graphs/test.links
   $ python -m danker test.links 0.85 30 1
      1.2.3.4.5.6.7.8.9.10.11.12.13.14.15.16.17.18.19.20.21.22.23.24.25.26.27.28.29.30.
      Computation of PageRank on 'test.links' with danker took 0.00 seconds.
      C	3.1898535044738043
      B	3.5572213415705725
      A	0.30410528185694391
      D	0.36260066319290651
      F	0.36260066319290651
      E	0.75035528185694389
      G	0.15000000000000002
      H	0.15000000000000002
      I	0.15000000000000002
      K	0.15000000000000002
      L	0.15000000000000002
   ```

* As Python library for computing PageRank on large graphs:
   ```
   $ pip install danker
   $ python
   >>> import danker
   ```
   More information on this option can be found at https://danker.rtfd.org.

More information on the project: [Compute PageRank on the Wikipedia graph](https://github.com/athalhammer/danker)
