danker
======

__danker__ is a compilation of Bash and Python3 scripts that enables the computation of PageRank on Wikipedia on normal off-the-shelf hardware (e.g., a quad-core CPU, 8 GB of main memory, and 250 GB hard disk storage). The BIGMEM option enables to speed up computation given that enough main memory is available (this depends on the Wikipedia language edition and your hardware configuration).

* __INPUT__ Wikipedia language edition, e.g. "en" OR "ALL" (for computing PR on the union of all language editions - "bag of links" semantics); optional parameter "BIGMEM".
* __PROCESSING__ danker downloads the required Wikipedia dump files (https://dumps.wikimedia.org/LANGwiki/latest/), resolves links, redirects, Wikidata Q-ids, produces a link-file, and computes PageRank.
* __OUTPUT__ 
  * LANG-DUMPDATE.links - a link file (edge list), the input for PageRank. Every line reads from left to right: Q-id left --links to--> Q-id right)
  * LANG-DUMPDATE.links.rank - a series of Wikidata Q-ids with their respective PageRank (sorted descending)

## Usage

* Compute PageRank on the current dump of English Wikipedia:

   ```bash
   $ ./danker.sh en
   $ ./danker.sh en BIGMEM
   ```
   
* Compute PageRank on the union of all language editions:

   ```bash
   $ ./danker.sh ALL
   $ ./danker.sh ALL BIGMEM    # caution, you will need some main memory for that
   ```
   
* Compute PageRank for each Wikipedia language edition:

   ```bash
   $ for i in $(./script/getLanguages.sh); do ./danker.sh "$i"; done
   $ for i in $(./script/getLanguages.sh); do ./danker.sh "$i" "BIGMEM"; done
   ```
* As a library for computing PageRank on large graphs:
   ```
   $ pip install git+https://github.com/athalhammer/danker.git
   $ python3
   >>> import danker
   >>> danker.init(...
   ```

## Download
Output of ``./danker.sh ALL`` on bi-weekly Wikipedia dumps.

* 2019-04-30
  * https://danker.s3.amazonaws.com/2019-04-30.all.links.stats.txt
  * https://danker.s3.amazonaws.com/2019-04-30.all.links.rank.bz2
* 2019-04-14
  * https://danker.s3.amazonaws.com/2019-04-14.all.links.stats.txt
  * https://danker.s3.amazonaws.com/2019-04-14.all.links.rank.bz2
* 2019-04-05
  * https://danker.s3.amazonaws.com/2019-04-05.all.links.stats.txt
  * https://danker.s3.amazonaws.com/2019-04-05.all.links.rank.bz2
* 2019-03-27
  * https://danker.s3.amazonaws.com/2019-03-27.all.links.stats.txt
  * https://danker.s3.amazonaws.com/2019-03-27.all.links.rank.bz2
* 2019-03-05
  * https://danker.s3.amazonaws.com/2019-03-05.all.links.stats.txt
  * https://danker.s3.amazonaws.com/2019-03-05.all.links.rank.bz2
* 2019-02-26
  * https://danker.s3.amazonaws.com/2019-02-26.all.links.stats.txt
  * https://danker.s3.amazonaws.com/2019-02-26.all.links.rank.bz2
* 2019-02-05
  * https://danker.s3.amazonaws.com/2019-02-05.all.links.stats.txt
  * https://danker.s3.amazonaws.com/2019-02-05.all.links.rank.bz2
* 2019-01-25
  * https://danker.s3.amazonaws.com/2019-01-25.all.links.stats.txt
  * https://danker.s3.amazonaws.com/2019-01-25.all.links.rank.bz2
* 2019-01-05
  * https://danker.s3.amazonaws.com/2019-01-05.all.links.stats.txt
  * https://danker.s3.amazonaws.com/2019-01-05.all.links.rank.bz2
* 2018-12-26
  * https://danker.s3.amazonaws.com/2018-12-26.all.links.stats.txt
  * https://danker.s3.amazonaws.com/2018-12-26.all.links.rank.bz2
* 2018-12-05
  * https://danker.s3.amazonaws.com/2018-12-05.all.links.stats.txt
  * https://danker.s3.amazonaws.com/2018-12-05.all.links.rank.bz2
* 2018-11-25
  * https://danker.s3.amazonaws.com/2018-11-25.all.links.stats.txt
  * https://danker.s3.amazonaws.com/2018-11-25.all.links.rank.bz2

## Previous work
Before __danker__, I performed a number of experiments with [DBpedia "page links" datasets](https://wiki.dbpedia.org/services-resources/documentation/datasets#pagelinks) most of which are documented at https://web.archive.org/web/20180222182923/https://people.aifb.kit.edu/ath/.

## Test
The unit tests assure correctness and compare the results of danker to the PageRank implementation of [NetworkX](https://networkx.github.io/). The tests need the `numpy` and `networkx` libraries installed.

Execute the unit tests as follows:

```
python3 -m unittest test/danker_test.py
```


In the directory `test` is a small graph with which you can try out the PageRank core of __danker__.

```bash
$ ./danker/danker.py ./test/graphs/test.links 0.85 40 1
1.2.3.4.5.6.7.8.9.10.11.12.13.14.15.16.17.18.19.20.21.22.23.24.25.26.27.28.29.30.31.32.33.34.35.36.37.38.39.40.
Computation of PageRank on './test/graphs/test.links' with danker took 0.00 seconds.
C	3.1828140590777672
B	3.5642607869667629
A	0.30410528185693986
D	0.3626006631927996
F	0.3626006631927996
E	0.75035528185693967
G	0.15000000000000002
H	0.15000000000000002
I	0.15000000000000002
K	0.15000000000000002
L	0.15000000000000002
$ ./danker/danker.py ./test/graphs/test.links 0.85 40 1 --right_sorted ./test/graphs/test.links.right
1.2.3.4.5.6.7.8.9.10.11.12.13.14.15.16.17.18.19.20.21.22.23.24.25.26.27.28.29.30.31.32.33.34.35.36.37.38.39.40.
Computation of PageRank on './test/graphs/test.links' with danker took 0.01 seconds.
A	0.30410528185693986
B	3.5642607869667629
C	3.1828140590777672
D	0.3626006631927996
E	0.75035528185693967
F	0.3626006631927996
G	0.15000000000000002
L	0.15000000000000002
K	0.15000000000000002
I	0.15000000000000002
H	0.15000000000000002
```

If you normalize the output values (divide each by 11) the values compare well to https://commons.wikimedia.org/wiki/File:PageRank-Beispiel.png or, if you compute percentages (division by the sum), they are similar to https://commons.wikimedia.org/wiki/File:PageRanks-Example.svg (same graph).

## License
This software is licensed under GPLv3. (see https://www.gnu.org/licenses/).

## FAQ

1. __The source code of danker is licensed under GPL v3. What about the output?__

   _The output of danker has no license. It can be used without attribution. However, if you use the PageRank scores it would be nice if you would provide reference to this page or, if you use the scores in an academic work, cite the following paper:_

   ```
   @InCollection{Thalhammer2016,
       Title                    = {{PageRank on Wikipedia: Towards General Importance Scores for Entities}},
       Author                   = {Andreas Thalhammer and Achim Rettinger},
       Booktitle                = {The Semantic Web: ESWC 2016 Satellite Events, Heraklion, Crete, Greece, May 29 -- June 2, 2016, Revised Selected Papers},
       Publisher                = {Springer International Publishing},
       Year                     = {2016},
       Address                  = {Cham},
       Month                    = oct,
       Pages                    = {227--240},
       Doi                      = {10.1007/978-3-319-47602-5_41},
       ISBN                     = {978-3-319-47602-5},
       Url                      = {https://dx.doi.org/10.1007/978-3-319-47602-5_41}
   }
   ```
  
  
2. __The output format is a tab-separated values (TSV) file with Wikidata Qids and the respective rank. Can I have format xyz?__

   _We consider TSV as sufficient. Any other format and/or mapping can easily be produced with a simple script._

3. __Why is this not programmed with Apache Hadoop/NetworkX/etc.?__

   _We believe that ranking computations should be transparent. In the best case, everyone who wants to verify the computed rankings should be enabled to do so. Therefore, we also support computation on off-the-shelf hardware. We do this taking into account that we don't need this to finish in one or two days (also the Wikipedia dumps are not that frequent). In general, the provided code can be extended and also be ported to other platforms (under consideration of the license terms)._

4. __Why does it take so long (up to two weeks) to compute PageRank with the ALL option?__

   _This goes in line with the previous point: we want to provide software that everyone with a standard laptop and some time can use. Of course it is possible to speed the computation up at the cost of required memory/computation power but we strongly believe that "this is for everyone"._
   
5. __Can I use danker to compute PageRank on other graphs than Wikipedia?__

   _Sure, you can use the file `./danker/danker.py` for computing PageRank on your graph. If you pass a "right sorted" file with the optional parameter `--right_sorted` automatically the slower method with low memory footprint will be used. The memory-intensive method will be used otherwise. You can sort tab-separated files with the Unix command `sort --key=2 -o output-file input-file`._ 
   
6. __Why do the scores not form a nice probability distribution?__

   _This has multiple reasons. First, we do not compute the normalized version of PageRank. Instead of `(1 - damping)/N` (N is the total number of nodes) we only use `(1 - damping)`. This doesn't change the ranking as it is just multiplying by a constant factor. Second, according to the theory, given the non-normalized version, all scores should add up to N. This would only be true if there would be no dangling nodes (pages with no outlinks) - these serve as energy sinks. One way to mitigate this would be to create links from dangling nodes to all pages (including itself). However, this also would only introduce a constant factor and therefore also has no effect on the final ranking. More information on the topic can be found in Monica Bianchini, Marco Gori, and Franco Scarselli. 2005. Inside PageRank. ACM Trans. Internet Technol. 5, 1 (February 2005), 92-128. DOI: https://doi.org/10.1145/1052934.1052938_
   
7. __Sorted edge lists are not a common graph representation format (compared to adjacency list or adjacency matrix). Why is it useful in this particular case?__

   _This is a good question and there are multiple aspects to it. We know that the graph would not easily fit in some 8GB of memory (as we have ~3bn edges). The good news is: We don't have to fit it. Random access to get all out/in links of a specific node is not needed for computing PageRank as we access every node anyway._
   
   _With sorted edge lists we gain two main advantages:_
   1. _We can walk through the graph node by node just by reading the lines of a file consecutively._
   2. _We can transform quickly from the best way accessing out-links to the best way of accessing in-links by sorting by the second column ("best way" refers to this specific case)._
   
   _Trade offs:_
   1. _We use much more diskspace than actually needed as we repeat nodes (compared to adjacency lists). Still, computation usually needs < 100GB of space and disk space is cheaper than memory._
   2. _Isolated nodes can not be represented with edge lists. However their PageRank would be `(1 - damping)`._
