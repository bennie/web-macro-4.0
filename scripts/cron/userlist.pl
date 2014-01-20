#!/usr/bin/perl -I/var/www/macrophile.com/lib

# This script reads info from individual accounts concerning the users.
# If there is none, defaults are generated

### CONFIG

my $debug = 1;

my $users_table = 'users';
my $data_table  = 'users_data';

# Email Domain of userids
my $domain = "\@macrophile.com";

# Web Directory Name and Indexfile
my $webdir = "public_html";
my $index  = "index.html";
my $info   = ".info";

# Dummy image (for people without a pic)
my $dummyimg = "http://www.macrophile.com/images/no-image.gif";

### PROGRAM

use Data::Dumper;
use Macro;
use strict;

my $macro = new Macro;

# Parse debug

for my $arg (@ARGV) {
  $debug = $1 if $arg =~ /--debug=(.+)/i;
}

# Grab the users

my $users = $macro->get_config($users_table);
my $sql   = "select username from $users order by username";
my $sth   = $macro->_dbh()->prepare($sql);
my $ret   = $sth->execute;

if ($ret < 1) { die "Bad return code of $ret on SQL $sql\n"; }

my @users;
while (my ($name) = $sth->fetchrow_array) { 
  push @users, $name;
}

$sth->finish;

# Grab the info and load the DB

foreach my $username (@users) {
  print "\n* $username\n\n" if $debug;

  # Defaults
  my $comment = 'User has yet to configure .info file.';
  my $email   = $username.$domain;
  my $img     = $dummyimg;
  my $name    = $username;
  my $title   = undef;
  my $web     = "http://$username.macrophile.com/";

  # Handle ".info" file
  my $raw = `curl --silent http://$username.macrophile.com/.info`;
  my @lines = split "\n", $raw;

  for my $line (@lines) {
      chomp($line);
      my ($nameof, $variable) = split /=/, $line, 2;
      $nameof =~ tr/A-Z/a-z/;
      $variable =~ tr/\cM//d; # zap pesky ^M

      if ($nameof eq 'comment') { $comment = $variable };
      if ($nameof eq 'email'  ) { $email   = $variable };
      if ($nameof eq 'img'    ) { $img     = $variable };
      if ($nameof eq 'name'   ) { $name    = $variable };
      if ($nameof eq 'title'  ) { $title   = $variable };
      if ($nameof eq 'web'    ) { $web     = $variable };

    }

  # Fallback for a title

  unless ( $title ) { # Try to pull from their page
    my $raw = `curl --silent $web`;
    $title = $1 if $raw =~ /<title>\s*(.+?)\s*<\/title>/i;
  }

  $title = &cap($name).'\'s Page' unless $title;

  # Summary

  if ( $debug ) {
    print " - comment : $comment\n";
    print " - email   : $email\n";
    print " - img     : $img\n";
    print " - name    : $name\n";
    print " - title   : $title\n";
    print " - web     : $web\n\n";
  }

  # Load into the DB

  my $table = $macro->get_config($data_table);
  my $dbh   = $macro->_dbh();

  $sql = "select name from $table where username = "
       . $dbh->quote($username);
  $sth = $dbh->prepare($sql);
  $ret = $sth->execute;
         $sth->finish;

  if ($ret < 1) {
    $sql = "insert into $table (comment,email,img,name,title,username,web) values ("
         . $dbh->quote($comment)     . ','
         . $dbh->quote($email)       . ','
         . $dbh->quote($img)         . ','
         . $dbh->quote(&name($name)) . ','
         . $dbh->quote($title)       . ','
         . $dbh->quote($username)    . ','
         . $dbh->quote($web)         . ')';
  } else {
    $sql = "update $table set "
         . 'comment = ' . $dbh->quote($comment)     . ', '
         . 'email   = ' . $dbh->quote($email)       . ', '
         . 'img     = ' . $dbh->quote($img)         . ', '
         . 'name    = ' . $dbh->quote(&name($name)) . ', '
         . 'title   = ' . $dbh->quote($title)       . ', '
         . 'web     = ' . $dbh->quote($web)         . '  '
         . 'where username = '
         . $macro->{'dbh'}->quote($username);
  }

  $sth = $dbh->prepare($sql);
  $ret = $sth->execute;

  # Update the same and it throws, WTF?
  unless ($ret eq 1 || $ret eq "0E0") { print "Bad return value of $ret on SQL statement: $sql\n"; }

  $sth->finish;
}

### Subroutines

sub cap {
  my $in = shift @_;

  my ($frontletter, $rest) = (split //, $in, 2);
  $frontletter =~ tr/a-z/A-Z/;
  $rest =~ tr/A-Z/a-z/;
  
  return $frontletter.$rest;
}

sub name {
  my     $name =  shift @_      ;
  chomp  $name                  ;
         $name =  &cap($name)   ;
         $name =~ s/\s/&nbsp;/g ;
  return $name                  ;
}
