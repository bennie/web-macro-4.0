#!/usr/bin/perl -I/var/www/macrophile.com/lib

use CGI::Carp qw/fatalsToBrowser/;
use Data::Dumper;
use HTML::Template;
use Macro;
use Macro::Auth;
use Writing;
use strict;

my $macro = new Macro;
my $tmpl  = $macro->get_raw_text('main-template-css');

my $w = new Writing;

my $macro_auth = new Macro::Auth;
my $cgi        = $macro_auth->{cgi};
my $user       = $macro_auth->{username} ? $macro_auth->{username} : 'guest';

my $body;
my $debug = Dumper($macro_auth) . "\n";

### Main

print $cgi->header();

if ( $cgi->param('title') and $cgi->param('description') and $cgi->param('username') and $cgi->param('chapter') ) {

  $body = $cgi->p('Title:',$cgi->param('title'))
        . $cgi->p('Description:',$cgi->param('description'))
        . $cgi->p('Chapter:',$cgi->param('chapter'))
        . $cgi->p('Username:',$cgi->param('username'));

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
  title => "Add a Story",
  body  => $body,

  time  => scalar localtime,
  year  => ((localtime)[5]+1900),

  user  => $user,
  debug => $cgi->pre($debug),
);

print $page->output;