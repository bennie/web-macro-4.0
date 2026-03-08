#!/usr/bin/perl -I/var/www/macrophile.com/lib

use CGI qw/Standard -noDebug/;
use Macro::User::Session;
use Term::Query qw/query/;

my $cgi = new CGI;

my $s = new Macro::User::Session;

my $user  = query('User? : ');
my $pass  = query('Pass? : ');

my $ret = $s->new_session($cgi,$user,$pass);
#my $ret = "SKIPPING";

print "Creation of session returned $ret\n";

$ret = $s->check_session($cgi);

print "Checking the session returned $ret\n";
