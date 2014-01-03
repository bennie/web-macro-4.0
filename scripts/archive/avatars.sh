#!/bin/sh

cd /var/www/macrophile.com/scripts/archive
mv avatars.tar.bz2 avatars.tar.bz2.old
cd /var/www/macrophile.com/forums/images
tar cvf ../../scripts/archive/avatars.tar avatars
cd /var/www/macrophile.com/scripts/archive
bzip2 -vv avatars.tar
