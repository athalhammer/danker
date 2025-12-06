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


# Expects to be executed from ./danker "root" dir
# Expects AWS Cli and according settings 
export TMPDIR="./rpi_tmp"
export MEM_PERC="90%"

S3_BUCKET="danker"
INDEX_FILE="index.html"
ENV="rpi_env"

# Parse flags
KEEP=false
while getopts "k" opt; do
  case $opt in
    k) KEEP=true ;;
    *) echo "Usage: $0 [-k]" && exit 1 ;;
  esac
done

# prepare python
python3 -m venv "$ENV"
# shellcheck source=/dev/null
source "./$ENV/bin/activate"
pip install .
pip install -r requirements.txt


# Compute PageRank and upload
mkdir "$TMPDIR"
filename=$(./danker.sh ALL -k)
bzip2 "$filename.rank"
ver=${filename//.links/}
aws s3 cp s3://"$S3_BUCKET/$INDEX_FILE" .
(sed "s/FILENAME/$filename/" | sed "s/VERSION/$ver/") < ./rpi/template > tmp
perl -i -p0e 's/  "distribution":\[/`cat tmp`/se' "$INDEX_FILE"
date=$(date -I)
sed "s/\"dateModified\": \"\(.*\)\",/\"dateModified\": \"$date\",/" -i index.html
aws s3 cp "$INDEX_FILE" s3://"$S3_BUCKET"/ --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp "$filename.rank.bz2" s3://"$S3_BUCKET"/ --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp "$filename.stats.txt" s3://"$S3_BUCKET"/ --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers

# Prepare sitelinks and upload
# 2024-10-24: NOT NEEDED - use <http://wikiba.se/ontology#sitelinks> on Wikidata live endpoint instead.
#
#filename="${filename%.*}".sitelinks.count
#sort -k1,1 ./*.site.links | cut -f 1 | uniq -c | awk '{print $2 "\t" $1}' > "$filename"
#bzip2 "$filename"
#aws s3 cp "$filename".bz2 s3://"$S3_BUCKET"/ --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
# If -k flag is not set, remove the links file, otherwise compress it

if [ "$KEEP" = false ]; then
    rm "$filename"
else
    bzip2 "$filename"
fi
rm -rf "$TMPDIR" $ENV tmp "$INDEX_FILE"
