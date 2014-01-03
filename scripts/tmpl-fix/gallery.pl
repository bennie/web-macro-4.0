#!/usr/bin/perl -w -I/home/httpd/html/macrophile.com/lib

# Drop the template into the gallery
# (c) 2003-2006, Phillip Pollard <bennie@macrophile.com>

###
### Config
###

my $outfile = '../../main/ftp/gallery.tmpl';

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
         . $cgi->Tr(
             $cgi->td({-bgcolor=>'#003300'},
               $cgi->font({-color=>'#FFFFFF',-face=>'Arial',-size=>4},
                 "<tmpl_var name='title'>"
               )
             )
           )
         . $cgi->Tr($cgi->td({-bgcolor=>'#FFFFFF'},"\n\n<tmpl_var name='body'>\n\n"))
         . $macro->{'end_table'};

my $raw_body = $macro->html_tmpl(
    title => "Macrophile.com - Gallery - <tmpl_var name='title'>",
    body  => $body,
    time  => "<tmpl_var name='time'>",
    year  => "<tmpl_var name='year'>",
  );

### Save it out

print "--> $outfile ";

open  OUTFILE, ">$outfile";
print OUTFILE $raw_body;
close OUTFILE;

print "--> done!\n";
