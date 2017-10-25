danker
======

__danker__ is a compilation of Bash and Python3 scripts that enables the computation of PageRank on Wikipedia on normal off-the-shelf hardware (e.g., a quad-core CPU, 8 GB of main memory, and 250 GB hard disk storage). The BIGMEM option enables to speed up computation given that enough main memory is available (this depends on the Wikipedia language edition and your hardware configuration). The total size of danker is __< 150 lines of code__.

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
   
## Previous work
Before __danker__, I performed a number of experiments with [DBpedia "page links" datasets](http://wiki.dbpedia.org/services-resources/documentation/datasets#pagelinks) most of which are documented at http://people.aifb.kit.edu/ath/.

## License
This software is licensed under GPLv3. (see http://www.gnu.org/licenses/).

## FAQ

1. __The source code of danker is licensed under GPL v3. What about the output?__

   _The output of danker has no license. It can be used without attribution. However, if you use the PageRank scores in an academic work, it would be nice if you would provide reference to this page and cite the following paper:_

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

   _We consider TSV as sufficient. Any other format and/or mapping can easily be produced with a simple Python script._


3. __Why is this not programmed with Apache Hadoop?__

   _We believe that ranking computations should be transparent. In the best case, everyone who wants to verify the computed rankings should be enabled to do so. Therefore, we only support computation on off-the-shelf hardware. However, the provided code can be extended and also be ported to other platforms (under consideration of the license terms)._
