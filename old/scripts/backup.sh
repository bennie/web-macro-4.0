#!/bin/sh
# (c) ????-2007, Phillip Pollard <bennie@macrophile.com>

echo "--> Saving the DB";

/var/www/macrophile.com/scripts/db-save/dump.sh;

echo "--> Saving the avatars";

/var/www/macrophile.com/scripts/archive/avatars.sh;

