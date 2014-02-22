#!/bin/sh

set -e

cd /var/www/macrophile.com/scripts/

./generate-users
./generate-thumbnails

./pre-process/art.pl --quiet
./pre-process/index.pl --quiet
./pre-process/store.pl --quiet
./pre-process/stories.pl --quiet

./generate-html
