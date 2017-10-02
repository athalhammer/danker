# danker - FAQ

1. __The source code of danker is licensed under GPL v3. What about the output?__

   _The output of danker has no license. It can be used without attribution. However, if you use the PageRank scores in an academic work, it would be nice if you would provide reference to this page and cite the following paper:_

   ```@InCollection{Thalhammer2016,
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
