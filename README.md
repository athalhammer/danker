danker
======

__danker__ is a compilation of Bash and Python3 scripts that enables the computation of PageRank on Wikipedia on normal off-the-shelf hardware (e.g., a quad-core CPU, 8 GB of memory and 250 GB hard disk storage). The total size of danker is < 200 lines of code.

* __INPUT__ Wikipedia language edition , e.g. "en".
* __PROCESSING__ danker does the download of the needed Wikipedia dump files (https://dumps.wikimedia.org/LANGwiki/latest/), resolves links, redirects, Wikidata Q-ids, produces a link-file and computes PageRank.
* __OUTPUT__ A series of Wikidata Q-ids with their respective PageRank (sorted descending)

## Usage

* Compute PageRank on the current dump of English Wikipedia:

   ```bash
   ./danker.sh en
   ```
* Compute PageRank on the dumps of all Wikipedia language editions:

   ```bash
   for i in `./lib/getLanguages.sh`; do ./danker.sh $i; done
   ```


## License
This software is licensed under GPLv3. (see http://www.gnu.org/licenses/).
