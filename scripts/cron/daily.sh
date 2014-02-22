#!/bin/sh

set -e
cd /var/www/macrophile.com/scripts/

for file in pre-process/*.pl; do ./$file --quiet; done;

./generate-html  --quiet
./generate-media --quiet
