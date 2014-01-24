#!/usr/bin/perl -I/var/www/macrophile.com/lib

use CGI;
use CGI::Carp qw/fatalsToBrowser/;
use Data::Dumper;
use HTML::Template;
use Macro;
use strict;

my $cgi = new CGI;
my $session = $cgi->cookie('macrophile.com');

my $macro = new Macro;
my $tmpl  = $macro->get_raw_text('main-template-css');

print $cgi->header();

my $debug = Dumper($session);
my $body = $cgi->pre($debug);

my $user = 'unknown';

### Print out the page from $body

my $page = HTML::Template->new( die_on_bad_params => 0, scalarref => \$tmpl );

$page->param(
  title => "Login",
  body  => $body,

  time  => scalar localtime,
  year  => ((localtime)[5]+1900),

  user  => $user,
  debug => $cgi->pre($debug),
);

print $page->output;