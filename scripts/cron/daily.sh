#!/bin/sh

set -e
cd /var/www/macrophile.com/scripts/

./cron/userlist.pl --debug=0

for file in pre-process/*.pl; do ./$file; done;

./generate-html
./generate-media
