[![Build Status](https://app.travis-ci.com/athalhammer/danker.svg?branch=master)](https://app.travis-ci.com/athalhammer/danker)
[![Coverage Status](https://coveralls.io/repos/github/athalhammer/danker/badge.svg?branch=master)](https://coveralls.io/github/athalhammer/danker?branch=master)
[![Documentation Status](https://readthedocs.org/projects/danker/badge/?version=latest)](https://danker.readthedocs.io/en/latest/?badge=latest)
[![PyPI](https://img.shields.io/pypi/v/danker)](https://pypi.org/project/danker)
[![GitHub license](https://img.shields.io/github/license/athalhammer/danker.svg)](https://github.com/athalhammer/danker/blob/master/LICENSE)

danker
======

__danker__ is a compilation of Bash and Python3 scripts that enables the computation of PageRank on Wikipedia on normal off-the-shelf hardware (e.g., a quad-core CPU, 8 GB of main memory, and 250 GB hard disk storage). The "--bigmem/-b" option enables to speed up computation given that enough main memory is available (this depends on the Wikipedia language edition, project and your hardware configuration).

* __INPUT__ Wikipedia language edition, e.g. "en" OR "ALL" (for computing PR on the union of all language editions using the bag-of-links model); optional parameter "--bigmem/-b".
* __PROCESSING__ danker downloads the required Wikipedia dump files (https://dumps.wikimedia.org/LANGwiki/latest/), resolves links, redirects, Wikidata Q-IDs, produces a link-file and computes PageRank.
* __OUTPUT__ 
  * LANG-DUMPDATE.links - a link file (edge list, tab-separated), the input for PageRank. Every line reads from left to right: 
  ```
  # Q-ID left --links to--> Q-ID right
  Q30    Q46
  ```
  * LANG-DUMPDATE.links.rank - a series of Wikidata Q-ID with their respective PageRank (sorted descending)

## Requirements
No additional packages required for running danker (see `setup.py`).

To run the unit tests:
* `csvkit>=1.0.4`
* `numpy>=1.18.5`
* `networkx>=2.3`
* `scipy>=1.9.1`
* `coveralls>=3.3.1`

## Usage
```
  usage: ./danker.sh [-h] [-p PROJECT] [-i ITERATIONS] [-d DAMPING] [-s START]
                     [-t DUMP_DATE] [-f FOLDER] [-b] [-l]
                     wikilang

  Compute PageRank on Wikipedia.

  positional arguments:
    wikilang              Wikipedia language edition, e.g. "en". "ALL" for
                          computing PageRank over all languages available in a
                          project.

  optional arguments:
    -h, --help            show this help message and exit
    -p PROJECT, --project PROJECT
                          Wiki project, currently supported are [wiki,
                          wikibooks, wikisource, wikiversity, wikinews,
                          wiktionary, wikiquote]. (default: wiki)
    -i ITERATIONS, --iterations ITERATIONS
                          PageRank number of iterations. (default: 40)
    -d DAMPING, --damping DAMPING
                          PageRank damping factor. (default: 0.85)
    -s START, --start START
                          PageRank starting value. (default: 0.1)
    -t DUMP_DATE, --dump-date DUMP_DATE
                          Dump date in the format YYYYMMDD (defaults to latest).
                          (default: None)
    -f FOLDER, --folder FOLDER
                          Folder with existing dumps, needs to match project and
                          dump-date parameters. (default: None)
    -b, --bigmem          PageRank big memory flag. (default: False)
    -l, --links           Only extract links (skip PageRank). (default: False)
```

## Examples


* Compute PageRank on the current dump of English Wikipedia:

   ```bash
   $ ./danker.sh en
   $ ./danker.sh en --bigmem
   ```
   
* Compute PageRank on the union of all language editions:

   ```bash
   $ ./danker.sh ALL
   $ ./danker.sh ALL --bigmem    # caution, you will need some main memory for that
   ```
   
* Compute PageRank for each Wikipedia language edition separately:

   ```bash
   $ for i in $(./script/get_languages.sh); do ./danker.sh "$i"; done
   $ for i in $(./script/get_languages.sh); do ./danker.sh "$i" -b; done
   ```
* Compute PageRank on the English version of Wikibooks:

   ```bash
   $ ./danker.sh en --project wikibooks
   $ ./danker.sh en --bigmem --project wikibooks
   ```

* [Compute PageRank on any graph](./README_PR.md)


## Download
The output of ``./danker.sh ALL`` on bi-weekly Wikipedia dumps is available at https://danker.s3.amazonaws.com/index.html ([CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/)).

Check out https://github.com/athalhammer/danker-hdt-docker for an example on how to publish the scores to an endpoint with docker-compose and do federated queries.

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
C	3.18281405907776715
B	3.56426078696676285
A	0.30410528185693986
D	0.36260066319279960
F	0.36260066319279960
E	0.75035528185693967
G	0.15000000000000002
H	0.15000000000000002
I	0.15000000000000002
K	0.15000000000000002
L	0.15000000000000002
$ ./danker/danker.py ./test/graphs/test.links -r ./test/graphs/test.links.right 0.85 40 1
1.2.3.4.5.6.7.8.9.10.11.12.13.14.15.16.17.18.19.20.21.22.23.24.25.26.27.28.29.30.31.32.33.34.35.36.37.38.39.40.
Computation of PageRank on './test/graphs/test.links' with danker took 0.01 seconds.
B	3.56426078696676285
C	3.18281405907776715
D	0.36260066319279960
E	0.75035528185693967
F	0.36260066319279960
G	0.15000000000000002
H	0.15000000000000002
I	0.15000000000000002
K	0.15000000000000002
L	0.15000000000000002
A	0.30410528185693986
```

If you normalize the output values (divide each by 11) the values compare well to https://commons.wikimedia.org/wiki/File:PageRank-Beispiel.png or, if you compute percentages (division by the sum), they are similar to https://commons.wikimedia.org/wiki/File:PageRanks-Example.svg (same graph).

## License
This software is licensed under GPLv3. (see https://www.gnu.org/licenses/).

## PageRank
For a comprehensive overview on the history of PageRank I recommend the following reading: [Sebastiano Vigna. Spectral Ranking](https://arxiv.org/abs/0912.0238)

## FAQ

1. __The source code of danker is licensed under GPL v3. What about the output?__

   _The input to danker are files from the Wikimedia projects published on https://dumps.wikimedia.org, i.e. Wikipedia.  The content of Wikipedia is licensed as [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/). When you use danker to compute PageRank on Wikipedia you need to respect this license. In addition, if you find this work useful it would be nice if you would provide reference to this repository or, if you use the scores in an academic work, cite the following paper (or both):_

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

4. __Why does it take so long (up to one week) to compute PageRank with the ALL option?__

   _This goes in line with the previous point: we want to provide software that everyone with a standard laptop and some time can use. Of course it is possible to speed the computation up at the cost of required memory/computation power but we strongly believe that "this is for everyone"._
   
5. __Can I use danker to compute PageRank on other graphs than Wikipedia?__

   _Sure, you can use the file `./danker/danker.py` for computing PageRank on your graph. If you pass a "right sorted" file with the optional parameter `right_sorted` automatically the slower method with low memory footprint will be used. The memory-intensive method will be used otherwise. You can sort tab-separated files with the Unix command `sort --key=2 -o output-file input-file`. Type `./danker/danker.py -h` for options. In addition, you can use danker as a library in your Python 3.x code (cf.: https://danker.rtfd.org)_
   
6. __Why do the scores not form a nice probability distribution?__

   _This has multiple reasons. First, we do not compute the normalized version of PageRank. Instead of `(1 - damping)/N` (N is the total number of nodes) we only use `(1 - damping)`. This doesn't change the ranking as it is just multiplying by a constant factor. Second, according to the theory, given the non-normalized version, all scores should add up to N. This would only be true if there would be no dangling nodes (pages with no outlinks) - these serve as energy sinks. One way to mitigate this would be to create links from dangling nodes to all pages (including itself). However, this also would only introduce a constant factor and therefore also has no effect on the final ranking. More information on the topic can be found in Monica Bianchini, Marco Gori, and Franco Scarselli. 2005. Inside PageRank. ACM Trans. Internet Technol. 5, 1 (February 2005), 92-128. DOI: https://doi.org/10.1145/1052934.1052938_
   
7. __Sorted edge lists are not a common graph representation format (compared to adjacency list or adjacency matrix). Why is it useful in this particular case?__

   _This is a good question and there are multiple aspects to it. We know that the graph would not easily fit in some 8GB of memory (as we have >3bn edges). The good news is: We don't have to fit it. Random access to get all out/in links of a specific node is not needed for computing PageRank as we access every node anyway (some of these ideas are presented in Taher H. Haveliwala. 1999. Efficient Computation of PageRank. http://ilpubs.stanford.edu:8090/386/)._
   
   _With sorted edge lists we gain two main advantages:_
   1. _We can walk through the graph node by node just by reading the lines of a file consecutively._
   2. _We can transform quickly from the best way accessing out-links to the best way of accessing in-links by sorting by the second column ("best way" refers to this specific case)._
   
   _Trade offs:_
   1. _We use much more diskspace than actually needed as we repeat nodes (compared to adjacency lists). Still, computation usually needs < 100GB of space and disk space is cheaper than memory._
   2. _Isolated nodes can not be represented with edge lists. However their PageRank would be `(1 - damping)`._
   3. _Computation by iterating over files is much slower than storing the graph in memory. If you have a graph that can fit into memory you can use the --bigmem/-b option and speed up computation time._


8. __What is the ALL option and what is the bag-of-links model?__

   _Naturally, the PageRank algorithm works with lists rather than sets. It also does not make any assumptions on the uniqueness of a link on a given web site. Therefore, if a link to page B apears multiple times on page A (say twice) it basically means that page B gets double the share of A's PageRank score than any other page C that is only linked once on page A. The following example shows that scenario:_
   ```
   A -> B
   A -> C
   A -> B
   ```
   _B gets `2/3 * PR(A)` while C gets `1/3 * PR(A)` (the damping factor is ignored here for brevity). This basic principle holds for every web site and can also be leveraged for Wikipedia. However, in the particular case of Wikipedia there is a ["one link only" policy](https://en.wikipedia.org/wiki/Wikipedia:Manual_of_Style/Linking#Duplicate_and_repeat_links) and multiple occurrences of a link may be arbitrary or due to quality issues of the article. However, with the `ALL` option we extract and align all page links from all Wikipedia language editions via the Wikidata identifier of each article. In this mode, we leverage the different language editions as link voting entities - the above example with Wikipedia language editions:_
   ```
   A -> B   # en
   A -> C   # en
   A -> B   # de
   ```
   _For example, the link `Q159 -> Q46` appears in 254 different language editions. As stated above, PageRank automatically handles multiple link occurrences and adjusts the scores accordingly. The whole methodology is similar to the [bag-of-words model](https://en.wikipedia.org/wiki/Bag-of-words_model) of the information retrieval domain where the word count is tracked and the resulting frequencies are fed into a probabilistic model (such as topic modeling). Due to this relation we call this method informally "bag-of-links model"._
