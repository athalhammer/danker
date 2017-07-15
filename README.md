danker
======

__danker__ is a compilation of Bash and Python3 scripts that enables the computation of PageRank on Wikipedia on normal off-the-shelf hardware (e.g., a quad-core CPU, 8 GB of memory and 250 GB hard disk storage). The BIGMEM option enables to speed up the computation process (given enough memory is available - depending on the Wikipedia language edition and hardware). The total size of danker is < 250 lines of code.

* __INPUT__ Wikipedia language edition , e.g. "en"; optional parameter "BIGMEM".
* __PROCESSING__ danker does the download of the needed Wikipedia dump files (https://dumps.wikimedia.org/LANGwiki/latest/), resolves links, redirects, Wikidata Q-ids, produces a link-file and computes PageRank.
* __OUTPUT__ 
  * LANG-DUMPDATE.links - a link file, the input for PageRank (every line reads from left to right: Q-id left --links to--> Q-id right)
  * LANG-DUMPDATE.links.rank - a series of Wikidata Q-ids with their respective PageRank (sorted descending)

## Usage

* Compute PageRank on the current dump of English Wikipedia:

   ```bash
   ./danker.sh en
   ```
   
   ```bash
   ./danker.sh en BIGMEM
   ```
   
* Compute PageRank on the dumps of all Wikipedia language editions:

   ```bash
   for i in `./lib/getLanguages.sh`; do ./danker.sh "$i"; done
   ```
   
   ```bash
   for i in `./lib/getLanguages.sh`; do ./danker.sh "$i" "BIGMEM"; done
   ```

## License
This software is licensed under GPLv3. (see http://www.gnu.org/licenses/).
