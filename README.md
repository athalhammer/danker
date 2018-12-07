danker
======

__danker__ is a compilation of Bash and Python3 scripts that enables the computation of (non-normalized) PageRank on Wikipedia on normal off-the-shelf hardware (e.g., a quad-core CPU, 8 GB of main memory, and 250 GB hard disk storage). The BIGMEM option enables to speed up computation given that enough main memory is available (this depends on the Wikipedia language edition and your hardware configuration). The total size of danker is __< 200 lines of code__.

* __INPUT__ Wikipedia language edition, e.g. "en" OR "ALL" (for computing PR on the union of all language editions - "bag of links" semantics); optional parameter "BIGMEM".
* __PROCESSING__ danker downloads the needed Wikipedia dump files (https://dumps.wikimedia.org/LANGwiki/latest/), resolves links, redirects, Wikidata Q-ids, produces a link-file and computes PageRank.
* __OUTPUT__ 
  * LANG-DUMPDATE.links - a link file, the input for PageRank (every line reads from left to right: Q-id left --links to--> Q-id right)
  * LANG-DUMPDATE.links.rank - a series of Wikidata Q-ids with their respective PageRank (sorted descending)

## Usage

* Compute PageRank on the current dump of English Wikipedia:

   ```bash
   ./danker.sh en
   ./danker.sh en BIGMEM
   ```
   
* Compute PageRank on the union of all language editions:

   ```bash
   ./danker.sh ALL
   ./danker.sh ALL BIGMEM    # caution, you will need some main memory for that
   ```
   
* Compute PageRank for each Wikipedia language edition:

   ```bash
   for i in `./lib/getLanguages.sh`; do ./danker.sh "$i"; done
   for i in `./lib/getLanguages.sh`; do ./danker.sh "$i" "BIGMEM"; done
   ```

## Download
Output of ``./danker.sh ALL`` on bi-weekly Wikipedia dumps.
* 2018-11-25
  * http://danker.s3.amazonaws.com/2018-11-25.all.links.stats.txt
  * http://danker.s3.amazonaws.com/2018-11-25.all.links.rank.bz2

## Previous work
Before __danker__, I performed a number of experiments with [DBpedia "page links" datasets](http://wiki.dbpedia.org/services-resources/documentation/datasets#pagelinks) most of which are documented at http://people.aifb.kit.edu/ath/.

## Test
In the directory `test` is a small graph with which you can try out the PageRank core of __danker__.

```bash
./lib/danker.py ./test/test.links ./test/test.links.right 0.85 40 1
1.2.3.4.5.6.7.8.9.10.11.12.13.14.15.16.17.18.19.20.21.22.23.24.25.26.27.28.29.30.31.32.33.34.35.36.37.38.39.40.
1	0.30410528185693986
2	3.5642607869667637
3	3.182814059077767
4	0.3626006631927996
5	0.7503552818569398
6	0.3626006631927996
7	0.15000000000000002
8	0.15000000000000002
9	0.15000000000000002
10	0.15000000000000002
11	0.15000000000000002
Computation of PageRank on './test/test.links' took 0.0 seconds.
```

```bash
./lib/dankerBigMem.py ./test/test.links 0.85 40 1
1.2.3.4.5.6.7.8.9.10.11.12.13.14.15.16.17.18.19.20.21.22.23.24.25.26.27.28.29.30.31.32.33.34.35.36.37.38.39.40.
1	0.30410528185693986
2	3.564260786966763
3	3.182814059077767
4	0.3626006631927996
5	0.7503552818569397
6	0.3626006631927996
7	0.15000000000000002
8	0.15000000000000002
9	0.15000000000000002
10	0.15000000000000002
11	0.15000000000000002
Computation of PageRank on './test/test.links' took 0.0 seconds.
```

If you normalize the output values (divide each by 11) the values compare well to https://commons.wikimedia.org/wiki/File:PageRank-Beispiel.png or, if you compute percentages (division by the sum), they are similar to https://commons.wikimedia.org/wiki/File:PageRanks-Example.svg (same graph where 1 corresponds to A, 2 to B, etc.).

## License
This software is licensed under GPLv3. (see http://www.gnu.org/licenses/).

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
       Url                      = {http://dx.doi.org/10.1007/978-3-319-47602-5_41}
   }
   ```
  
  
2. __The output format is a tab-separated values (TSV) file with Wikidata Qids and the respective rank. Can I have format xyz?__

   _We consider TSV as sufficient. Any other format and/or mapping can easily be produced with a simple script._


3. __Why is this not programmed with Apache Hadoop?__

   _We believe that ranking computations should be transparent. In the best case, everyone who wants to verify the computed rankings should be enabled to do so. Therefore, we also support computation on off-the-shelf hardware. However, the provided code can be extended and also be ported to other platforms (under consideration of the license terms)._

4. __Why does it take so long (up to two weeks) to compute PageRank with the ALL option?__

   _This goes in line with the previous point: we want to provide software that everyone with a standard laptop and some time can use. Of course it is possible to speed the computation up at the cost of required memory/computation power but we strongly believe that "this is for everyone"._
   
5. __Can I use danker to compute PageRank on other graphs than Wikipedia?__

   _Sure, you can use the files ./lib/danker.py and ./lib/dankerBigMem.py for computing PageRank on your graph. Note that the former needs the same file in two different formats (left and right sorted, tab-separated respectively) and the latter only once (left sorted, tab-separated). You can use the sort Unix command for sorting._
   
6. __Why do the scores not form a nice probability distribution?__

   _This has multiple reasons. First, we do not compute the normalized version of PageRank. Instead of (1 - damping)/2 we only use (1 - damping). This doesn't change the ranking. Second, according to the theory, given the non-normalized version, all scores should add up to N (the total number of nodes). This would only be true if there would be no dangling nodes (pages with no outlinks) - these serve as energy sinks. More information on the topic can be found in Monica Bianchini, Marco Gori, and Franco Scarselli. 2005. Inside PageRank. ACM Trans. Internet Technol. 5, 1 (February 2005), 92-128. DOI: https://doi.org/10.1145/1052934.1052938_
