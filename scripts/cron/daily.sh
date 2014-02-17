#!/bin/sh

set -e
cd /var/www/macrophile.com/scripts/

for file in pre-process/*.pl; do ./$file --debug=0; done;

./generate-html  --debug=0
./generate-media --debug=0
