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

for my $key ( qw/username chapter title body/ ) { $debug .= $key .' : '. $cgi->param($key) ."\n\n"; }

if ( $cgi->param('username') and $cgi->param('chapter') and $cgi->param('title') and $cgi->param('body') ) {

  my $user = $cgi->param('username');
  my $previous_chapter_ref = $w->get_chapter($cgi->param('chapter'));
  my $story_ref = $w->get_story($previous_chapter_ref->{story});

  my $chap_id = $w->create_chapter({
    story => $previous_chapter_ref->{story},
    user => $user,
    title => $cgi->param('title'),
    body => $cgi->param('body'),
    previous_chapter => $previous_chapter_ref->{id}
  });

  $debug .= "Created: " . $chap_id . "\n\n";

  $body = "Created Chapter $chap_id\n";

} elsif ( $cgi->param('chapter') ) {

  my $user = $macro_auth->{username};
  my $previous_chapter_ref = $w->get_chapter($cgi->param('chapter'));
  my $story_ref = $w->get_story($previous_chapter_ref->{story});
  
  $debug .= "Previous Chapter: " . Dumper($previous_chapter_ref) . "\n\n"
         . "Story Ref: " . Dumper($story_ref);

  $body = $cgi->p("Adding to the story:",$story_ref->{title})
        . $cgi->start_form( -action => 'add-chapter.cgi' )
        . $cgi->hidden('username',$user)
        . $cgi->hidden('chapter',$cgi->param('chapter'))
        . $cgi->p('Chapter Title:',$cgi->textfield('title'))
        . $cgi->p('Chapter:',$cgi->textarea( -name => 'body', -rows => 25, -cols => 80 ))
        . $cgi->submit
        . $cgi->end_form;
        
} else {

 # uhh... shouldn't be here without a clean link

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