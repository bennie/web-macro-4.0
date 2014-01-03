#!/usr/bin/perl -I/var/www/macrophile.com/lib

# This script reads info from individual accounts concerning the users.
# If there is none, defaults are generated

### CONFIG

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

use Macro;
use strict;

my $macro = new Macro;

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

foreach my $name (@users) {

  my ($username,$passwd,$uid,$gid,$quota,$finger,$dgoc,$dir,$shell) =
     (getpwnam $name);

  # Defaults

  my $comment = 'User has yet to configure .info file.';
  my $email   = $name.$domain;
  my $img     = $dummyimg;
  my $title   = &cap($name).'\'s Page';
  my $web     = 0;

  # Check for web dir
  if ($web == 0) {
    my $internaldir = $dir."/".$webdir;
    if (-d $internaldir) {
      $web = 'http://'.$username.'.macrophile.com/'
    }

    # Read title (if they have a web page in their web dir)
    my $webpage = $internaldir."/".$index;
    if (-r $webpage) {
      open (WEBFILE, $webpage);
      my $whole;
      while (my $line = <WEBFILE>) {$whole=$whole.$line}
      close (WEBFILE);
      $whole =~ /<title>(.+)<\/title>/i;
      if (length $1) { $title = $1; }
    }
  }

  # Read info file?
  my $infofile = $dir.'/'.$webdir.'/'.$info;

  if (-r $infofile) {
    open (INFOFILE, $infofile);
    while (my $line = <INFOFILE>) {
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
    close (INFOFILE);
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
  #if ($ret == 1 || $ret eq "0E0") { print "Bad return value of $ret on
  #SQL statement: $sql\n"; }

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
