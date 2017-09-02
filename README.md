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
Before __danker__, I performed a number of experiments with DBpedia "Wikipedia Pagelinks" datasets (http://wiki.dbpedia.org/services-resources/documentation/datasets#PageLinks) most of which are documented at http://people.aifb.kit.edu/ath/.

## License
This software is licensed under GPLv3. (see http://www.gnu.org/licenses/).
