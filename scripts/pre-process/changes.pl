#!/usr/bin/perl -w -I/var/www/macrophile.com/lib

# This page generates the changes.txt from info in the DB.
# (c) 2001-2014, Phillip Pollard <bennie@macrophile.com>

###
### Config
###

my $in_table   = 'change_log';
my $out_name   = 'changes';

my $debug = ( $ARGV[0] and $ARGV[0] eq '--debug=1' ) ? 1:0;

###
### Pre-process
###

use Macro;
use strict;

my $macro = new Macro;
my $cgi   = $macro->{cgi};

my $change_log = $macro->get_config($in_table);

###
### Program
###

print "PRE: $change_log table " if $debug;

my $sql   = "select change_time, change_desc from $change_log order by id desc";
my $sth   = $macro->_dbh()->prepare($sql);
my $ret   = $sth->execute;

if ($ret < 1) { die "Bad return code of $ret on SQL $sql\n"; }

my $outtext;
while (my ($time,$desc) = $sth->fetchrow_array) {
  $outtext .= $cgi->dt($cgi->b($time)) 
           .  $cgi->dd($desc);
}

$ret = $sth->finish;

print "--> raw_pages table " if $debug;

my $body = $cgi->table({ class=>"innertable", cellspacing=>0, cellpadding=>3 },
             $cgi->Tr($cgi->td({-class=>'innertablehead'},'The Change Log')),
             $cgi->Tr($cgi->td($cgi->dl($outtext)))
           );

# Put out :)

$ret = $macro->update_raw_page($out_name,$body);

print "--> done! (return $ret)\n" if $debug;