#!/usr/bin/perl -w -I/var/www/macrophile.com/lib

# This script reads info from individual accounts concerning the users.
# If there is none, defaults are generated.

# This is then stored in the DB, and from which the userlist page is generated.

# (c) 2001-2014, Phillip Pollard <bennie@macrophile.com>

### CONFIG

my $quiet = 0;

my $users_table = 'users';
my $data_table  = 'users_data';
my $out_name    = 'userlist';

# Email Domain of userids
my $domain = "\@macrophile.com";

# Web Directory Name and Indexfile
my $webdir = "public_html";
my $index  = "index.html";
my $info   = ".info";

# Dummy image (for people without a pic)
my $dummyimg = "http://www.macrophile.com/images/no-image.gif";

my $html_prefix  = '/';
my $image_prefix = '/images/';

### PROGRAM

use Data::Dumper;
use Macro;
use strict;

my $macro = new Macro;

# Parse args

for my $arg (@ARGV) {
  $quiet = 1 if $arg eq '--quiet';
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
  print "\n* $username\n\n" unless $quiet;

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
      $variable =~ tr/\cM//d if $variable; # zap pesky ^M

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

  unless ( $quiet ) {
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

### Generate the page

my $cgi = $macro->{cgi};
my $dbh = $macro->_dbh();

my $actual_tb_users      = $macro->get_config($users_table);
my $actual_tb_users_data = $macro->get_config($data_table);

print "\nPRE: $actual_tb_users table --> $actual_tb_users_data table " unless $quiet;

my @chunks; # Grab and organize the data for each user

for my $next_trick (@users) {
  my $sql = 'select name, email, web, title, img, comment from '
          . "$actual_tb_users_data where username = "
          . $dbh->quote($next_trick);
  my ($name,$email,$web,$title,$img,$comment) = $macro->query_row($sql);

  $email =~ s/\@/&nbsp;&#64;&nbsp;/g; # stop spammers

  push @chunks, $cgi->td({-bgcolor=>'#CCCCCC'},
                  $cgi->table(
                    $cgi->Tr(
                      $cgi->td(
                        $cgi->b(
                          $cgi->font({-size=>4},
                            $name
                          )
                        )
                      ),
                      $cgi->td(
                        $email
                      ),
                    ),
                    $cgi->Tr(
                      $cgi->td(
                        $cgi->img({-height=>100,-width=>100,-src=>$img})
                      ),
                      $cgi->td(
                        $cgi->a({-href=>$web},$title),
                        $cgi->p($comment)
                      ),
                    )
                  )
                );

}

print "--> raw_pages table " unless $quiet;

# Assemble the table;

my $table;

while (@chunks) {
  my $l = shift @chunks;
  my $r = shift @chunks || $cgi->td('&nbsp;');
  $table .= $cgi->Tr($l,$r);
}

# Assemble the file

my $body = '<p class="subnav" align="center">[&nbsp;<b>Original</b>&nbsp;|&nbsp;<a class="subnav" href="A.html">A</a>&nbsp;|&nbsp;<a class="subnav" href="B.html">B</a>&nbsp;|&nbsp;<a class="subnav" href="C.html">C</a>&nbsp;|&nbsp;<a class="subnav" href="D.html">D</a>&nbsp;|&nbsp;<a class="subnav" href="E.html">E</a>&nbsp;|&nbsp;<a class="subnav" href="F.html">F</a>&nbsp;|&nbsp;<a class="subnav" href="G.html">G</a>&nbsp;|&nbsp;<a class="subnav" href="H.html">H</a>&nbsp;|&nbsp;<a class="subnav" href="I.html">I</a>&nbsp;|&nbsp;<a class="subnav" href="J.html">J</a>&nbsp;|&nbsp;<a class="subnav" href="K.html">K</a>&nbsp;|&nbsp;<a class="subnav" href="L.html">L</a>&nbsp;|&nbsp;<a class="subnav" href="M.html">M</a>&nbsp;|&nbsp;<a class="subnav" href="N.html">N</a>&nbsp;|&nbsp;<a class="subnav" href="O.html">O</a>&nbsp;|&nbsp;<a class="subnav" href="P.html">P</a>&nbsp;|&nbsp;<a class="subnav" href="Q.html">Q</a>&nbsp;|&nbsp;<a class="subnav" href="R.html">R</a>&nbsp;|&nbsp;<a class="subnav" href="S.html">S</a>&nbsp;|&nbsp;<a class="subnav" href="T.html">T</a>&nbsp;|&nbsp;<a class="subnav" href="U.html">U</a>&nbsp;|&nbsp;<a class="subnav" href="V.html">V</a>&nbsp;|&nbsp;<a class="subnav" href="W.html">W</a>&nbsp;|&nbsp;<a class="subnav" href="X.html">X</a>&nbsp;|&nbsp;<a class="subnav" href="Y.html">Y</a>&nbsp;|&nbsp;<a class="subnav" href="Z.html">Z</a>&nbsp;|&nbsp;<a class="subnav" href="Misc.html">Misc</a>&nbsp;]</p>'
         . $cgi->table($table);

# Put out :)

$ret = $macro->update_raw_page($out_name,$body);

print "--> done! (return $ret)\n" unless $quiet;

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