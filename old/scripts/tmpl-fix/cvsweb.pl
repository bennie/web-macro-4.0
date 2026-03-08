#!/usr/bin/perl -w -I/home/httpd/html/macrophile.com/lib

# Drop the template into CVSweb
# (c) 2000-2003, Phillip Pollard <phil@crescendo.net>

###
### Config
###

my $infile     = 'cvsweb.conf.dist';
my $outfile    = 'cvsweb.conf';

###
### Pre-process
###

use HTML::Template;
use Macro;
use strict;

my $macro = new Macro;
my $cgi   = $macro->{cgi};

###
### Program
###

print 'template ';

my $body = $macro->{'start_table'}  
         . $cgi->Tr($cgi->td({-bgcolor=>'#FFFFFF'},'---split---'))
         . $macro->{'end_table'};

my $raw_body = $macro->html_tmpl(
    title => "Macrophile.com - Macro Code",
    body  => $body,
    time  => "dynamically generated",
  );

$raw_body =~ s/'/\\'/g;
$raw_body =~ /^.+(<body.*?>.+)---split---(.+)<\/body>.+$/s;

my $header = $1;
my $footer = $2;

### Load the config file and apply the design
print "--> $infile ";

my $conf = HTML::Template->new(
             die_on_bad_params => 0,
             filename => $infile
           );

$conf->param(
  header => $header,
  footer => $footer
);

### Save it out
print "--> $outfile ";

open  OUTFILE, ">$outfile";
print OUTFILE $conf->output;
close OUTFILE;

print "--> done!\n";
