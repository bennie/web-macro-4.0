#!/usr/bin/perl -I/var/www/macrophile.com/lib

# (c) 2003-2006, Phillip Pollard <bennie@macrophile.com>

use Macro::DB;
use strict;

my $db  = new Macro::DB;
my $dbh = $db->_dbh();

my $sql = 'select name, body from raw_pages';
my $sth = $dbh->prepare($sql);
my $ret = $sth->execute;

while ( my $ref = $sth->fetchrow_arrayref ) {
  my $name = $ref->[0] . '.txt';
  $name =~ s/ /-/g;
  print STDERR "Writing $name\n";
  open  OUTFILE, ">$name";
  print OUTFILE $ref->[1];
  close OUTFILE;
}
