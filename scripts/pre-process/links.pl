#!/usr/bin/perl -w -I/var/www/macrophile.com/lib

# This page generates the userlist page from info in the DB.
# (c) 2001-2006, Phillip Pollard <bennie@macrophile.com>

###
### Config
###

my $out_name = 'links';

my $tb_links      = 'links';
my $tb_users      = 'users';
my $tb_users_data = 'users_data';

###
### Pre-process
###

use Macro;
use strict;

my $macro = new Macro;
my $cgi          = $macro->{cgi};
my $dbh          = $macro->_dbh();

my $actual_tb_links      = $macro->get_config($tb_links);
my $actual_tb_users      = $macro->get_config($tb_users);
my $actual_tb_users_data = $macro->get_config($tb_users_data);

###
### Program
###

print "PRE: $actual_tb_users table ";

my $sql = "select username from $actual_tb_users order by username";
my $sth = $dbh->prepare($sql);
my $ret = $sth->execute;

if ($ret < 1) { die "Bad return code of $ret on SQL $sql\n"; }

my @users; # Grab the userlist

while (my $user = $sth->fetchrow_array) {
  push @users, $user;
}

$ret = $sth->finish;

print "--> $actual_tb_users_data table ";

my @chunks; # Grab and organize the data for each user

my @internal_links;
for my $next_trick (@users) {
  my $sql = 'select name, web, title from '
          . "$actual_tb_users_data where username = "
          . $dbh->quote($next_trick);
  my ($name,$web,$title) = $macro->query_row($sql);
  push @internal_links, $cgi->li("($name) ",$cgi->a({-href=>$web},$title));
}

print "--> $actual_tb_links table ";

my %remote;

$sql = "select * from $actual_tb_links";
$sth = $dbh->prepare($sql);
$ret = $sth->execute;

while ( my $ref = $sth->fetchrow_hashref ) { 
  $remote{$ref->{category}}{$ref->{id}} = { %$ref };
}

$sth->finish;

print "--> raw_pages table ";

## Assemble the file

my @body = ( $macro->html_box(
               $cgi->Tr({-bgcolor=>'#003300'},$cgi->td($cgi->font({-size=>4,-color=>'#FFFFFF'},'Internal Links')))
             . $cgi->Tr(
               $cgi->td({-bgcolor=>'#FFFFFF'},
                 $cgi->table({-width=>490,-cellpadding=>0,-cellspacing=>0},
                   $cgi->Tr({-valign=>'top'},
                     $cgi->td($cgi->ul(@internal_links)),
                     $cgi->td({-align=>'right'},
                       $cgi->img({-width=>171,-height=>200,-src=>$macro->{image_prefix}.'hazard.gif'})
                     )
                   )
                 )
               )
             ),500
           )
         );

for my $category ( sort { $b =~ /^community/i <=> $a =~ /^community/i || lc($a) cmp lc($b) } keys %remote ) {
  my $data = $remote{$category};
  my @links;
  for my $id ( sort { lc($data->{$a}->{name}) cmp lc($data->{$b}->{name}) } keys %$data ) {
    push @links,
      $cgi->li(
        $cgi->a({-href=>$data->{$id}->{href}},$data->{$id}->{name}),
        $cgi->blockquote($data->{$id}->{description})
      );
  }
  push @body, $macro->html_box(
                 $cgi->Tr({-bgcolor=>'#003300'},$cgi->td($cgi->font({-size=>4,-color=>'#FFFFFF'},$category)))
               . $cgi->Tr($cgi->td({-bgcolor=>'#FFFFFF'},$cgi->ul(@links))),
               500
             );
}


my $body = join(
             $macro->html_spacer(1,2),
             @body
           );


# Put out :)

$ret = $macro->update_raw_page($out_name,$body);

print "--> done! (return $ret)\n";
