#!/bin/sh

set -e

cd /var/www/macrophile.com/scripts/

./generate-users
./generate-thumbnails

./pre-process/art.pl
./pre-process/index.pl
./pre-process/store.pl
./pre-process/stories.pl

./generate-html
