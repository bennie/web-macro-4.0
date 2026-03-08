#!/usr/bin/perl -w -I/var/www/macrophile.com/lib

# Drop the template into Phorum
# (c) 2000-2008, Phillip Pollard <phil@crescendo.net>

###
### Config
###

my $header_in  = 'phpbb.overall_header.tpl';
my $footer_in  = 'phpbb.overall_footer.tpl';

my $header_out = '../../forums/templates/macrophile/overall_header.tpl';
my $footer_out = '../../forums/templates/macrophile/overall_footer.tpl';

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

my $raw_body = $macro->html_tmpl(
    title => "Macrophile.com - Macro Code",
    body  => '---split---',
    time  => "dynamically generated",
    year  => 2008
  );

$raw_body =~ s/'/\\'/g;
$raw_body =~ /^.+<body.*?>(.+)---split---(.+)$/is;

my $header = $1;
my $footer = $2;

### apply the design

print "--> $header_out, ";
my $h = HTML::Template->new( filename => $header_in );
$h->param( header => $header );
&chuckit($header_out,$h->output);

print "$footer_out ";
my $f = HTML::Template->new( filename => $footer_in );
$f->param( footer => $footer );
&chuckit($footer_out,$f->output);

print "--> done!\n";

### subroutines

sub chuckit {
  my $outfile = shift @_;
  my $output  = shift @_;
  
  open  OUTFILE, ">$outfile";
  print OUTFILE $output;
  close OUTFILE;
}
