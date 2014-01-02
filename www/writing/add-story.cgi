#!/usr/bin/perl -I/var/www/macrophile.com/lib

use CGI::Carp qw/fatalsToBrowser/;
use Data::Dumper;
use HTML::Template;
use Macro;
use Macro::Auth;
use Writing;
use strict;

my $macro = new Macro;

my $html_prefix  = $macro->{html_prefix};
my $image_prefix = $macro->{image_prefix};
my $start_table  = $macro->{start_table};
my $end_table    = $macro->{end_table};

my $tmpl         = $macro->get_raw_text('main-template-css');

my $w = new Writing;

my $macro_auth = new Macro::Auth;
my $cgi = $macro_auth->{cgi};

my $body;
my $debug = Dumper($macro_auth) . "\n";

### Main

print $cgi->header();

if ( $cgi->param('title') and $cgi->param('description') and $cgi->param('username') and $cgi->param('chapter') ) {

  $body = $cgi->p('Title:',$cgi->param('title'))
        . $cgi->p('Description:',$cgi->param('description'))
        . $cgi->p('Chapter:',$cgi->param('chapter'))
        . $cgi->p('Username:',$cgi->param('username'));

  my $user = $macro_auth->{username};

  my $story_id = $w->create_story({
    user => $user,
    title => $cgi->param('title'),
    description => $cgi->param('description'),
  });

  $debug = "Created Story ID: $story_id\n";

  my $chap_id = $w->create_chapter({
    story => $story_id,
    user => $user,
    title => $cgi->param('title'),
    body => $cgi->param('chapter')
  });

  $debug .= "Created Chapter ID: $chap_id\n";

} else {

  my $user = $macro_auth->{username};

  $body = $cgi->start_form
        . $cgi->p('Title:',$cgi->textfield('title'))
        . $cgi->p('Description:',$cgi->textfield('description'))
        . $cgi->hidden('username',$user)
        . $cgi->p('Starting Chapter:',$cgi->textarea('chapter'))
        . $cgi->submit
        . $cgi->end_form;
        
}

### Print out the page from $body

my $page = HTML::Template->new( die_on_bad_params => 0, scalarref => \$tmpl );

$page->param(
    title        => "Macrophile.com - Stories",
    body         => $body,

    time         => scalar localtime,
    year         => 2011,

    debug        => $cgi->pre($debug),

    html_prefix  => $html_prefix,
    image_prefix => $image_prefix,
    start_table  => $start_table,
    end_table    => $end_table
);

print $page->output;