#!/usr/bin/perl -w -I/home/httpd/html/macrophile.com/lib

# Drop the template into Phorum
# (c) 2000-2003, Phillip Pollard <phil@crescendo.net>

###
### Config
###

my $header_in  = 'phorum.header.dist';
my $footer_in  = 'phorum.footer.dist';

my $header_out = '../../main/bb/m_include/header.php';
my $footer_out = '../../main/bb/m_include/footer.php';

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
  );

$raw_body =~ s/'/\\'/g;
$raw_body =~ /^.+(<body.*?>.+)---split---(.+)$/is;

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
