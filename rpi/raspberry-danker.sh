#!/usr/bin/env bash
#    danker - PageRank on Wikipedia/Wikidata
#    Copyright (C) 2019  Andreas Thalhammer
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Asumes AWS Cli and according settings 
export MEM_PERC="90%"
export S3_BUCKET="danker"

filename=$(./danker.sh ALL)
VER=$(echo "$filename" | sed "s/.allwiki.links//")
aws s3 cp s3://"$S3_BUCKET"/index.html .
cat ./rpi/template | sed "s/VERSION/$VER/" > tmp
perl -i -p0e 's/  "distribution":\[/`cat tmp`/se' index.html
aws s3 cp index.html s3://"$S3_BUCKET"/ --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp "$VER.allwiki.links.rank.bz2" s3://"$S3_BUCKET"/ --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp "$VER.allwiki.links.stats.txt" s3://"$S3_BUCKET"/ --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
