#!/usr/bin/perl -w -I/var/www/macrophile.com/lib

# This page generates the userlist page from info in the DB.
# (c) 2001-2014, Phillip Pollard <bennie@macrophile.com>

###
### Config
###

my $out_name = 'userlist';

my $tb_users      = 'users';
my $tb_users_data = 'users_data';

my $html_prefix  = '/';
my $image_prefix = '/images/';

my $debug = ( $ARGV[0] and $ARGV[0] eq '--debug=1' ) ? 1:0;

###
### Pre-process
###

use Macro;
use strict;

my $macro = new Macro;
my $cgi   = $macro->{'cgi'};
my $dbh   = $macro->_dbh();

my $actual_tb_users      = $macro->get_config($tb_users);
my $actual_tb_users_data = $macro->get_config($tb_users_data);

###
### Program
###

print "PRE: $actual_tb_users table " if $debug;

my $sql = "select username from $actual_tb_users order by username";
my $sth = $dbh->prepare($sql);
my $ret = $sth->execute;

if ($ret < 1) { die "Bad return code of $ret on SQL $sql\n"; }

my @users; # Grab the userlist

while (my $user = $sth->fetchrow_array) {
  push @users, $user;
}

$ret = $sth->finish;

print "--> $actual_tb_users_data table " if $debug;

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

print "--> raw_pages table " if $debug;

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

print "--> done! (return $ret)\n" if $debug;