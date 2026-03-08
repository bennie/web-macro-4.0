#!/bin/sh
# (c) ????-2006, Phillip Pollard <bennie@macrophile.com>

mysql -u DBUSER -pDBPASS DBNAME -e "select a.username as user, c.username as ignoring from phpbb_users a, phpbb_ignore b, phpbb_users c where a.user_id = b.user_id and b.user_ignore = c.user_id order by a.username, c.username"
mysql -u DBUSER -pDBPASS DBNAME -e "select count(*) as count, a.username as user from phpbb_users a, phpbb_ignore b where a.user_id = b.user_ignore group by b.user_ignore order by count desc, user"

