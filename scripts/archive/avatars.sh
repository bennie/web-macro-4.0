#!/bin/sh

cd /home/httpd/html/macrophile.com/scripts/archive
mv avatars.tar.bz2 avatars.tar.bz2.old
cd /home/httpd/html/macrophile.com/forums/images
tar cvf ../../scripts/archive/avatars.tar avatars
cd /home/httpd/html/macrophile.com/scripts/archive
bzip2 -vv avatars.tar
