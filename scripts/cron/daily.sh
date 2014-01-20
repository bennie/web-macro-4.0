#!/bin/sh

cd /var/www/macrophile.com/scripts/cron/

./userlist.pl --debug=0

../make.sh
