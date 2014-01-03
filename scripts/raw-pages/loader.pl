#!/usr/bin/perl -I/var/www/macrophile.com/lib

# (c) 2001-2006, Phillip Pollard <bennie@macrophile.com>

use Macro::DB;
use strict;

my $db  = new Macro::DB;
my $dbh = $db->_dbh();

for my $file ( @ARGV ) {
  next unless -f $file;
  next unless $file =~ /^(.+)\.txt/;
  my $id = $1;

  print STDERR "Updating $file (id: $id)\n";

  open INFILE, "<$file";
  my $body;
  while (my $line = <INFILE>) { $body .= $line };
  close INFILE;

  my $sql = 'update raw_pages set body='
          . $dbh->quote($body)
          . ' where name='
          . $dbh->quote($id);
  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute;

  #print STDERR "SQL: $sql\n";

  print STDERR "Returned $ret\n";
}
