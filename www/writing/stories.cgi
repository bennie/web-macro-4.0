#!/usr/bin/perl -I/var/www/macrophile.com/lib

use CGI;
use CGI::Carp qw/fatalsToBrowser/;
use Data::Dumper;
use HTML::Template;
use Macro;
use Writing;

use strict;

my $macro = new Macro;

my $html_prefix  = $macro->{html_prefix};
my $image_prefix = $macro->{image_prefix};
my $start_table  = $macro->{start_table};
my $end_table    = $macro->{end_table};

my $tmpl         = $macro->get_raw_text('main-template-css');

my $w = new Writing;

my $cgi = new CGI;

### Main

#my $story = $w->get_story(1);
#print Dumper($story), "\n";

print $cgi->header();

my $body; my $debug;

if ( $cgi->param('story') and $cgi->param('story') =~ /^\d+$/ ) {
  my $story_id = $cgi->param('story');
  my $chapter_id = $cgi->param('chapter');
  
  my $story_ref = $w->get_story($story_id);
  my $chapter_ref;
  
  if ( $chapter_id =~ /^\d+$/ ) { # Pull the called for chapter
    $debug .= "Pulling the chapter from the given id: $chapter_id\n\n";
    $chapter_ref = $w->get_chapter($chapter_id);
  } else { # Figure out the first chapter of the story
    $debug .= "Figuring thechapter from the start of the story id.\n\n";
    my @chapters = $w->list_chapters($story_id,0);  
    $chapter_ref = $chapters[0];
    $chapter_id = $chapter_ref->{id};
  }
  my @next_chapters = $w->list_chapters($story_id,$chapter_id);

  $debug .= "Story: " . Dumper($story_ref) ."\n\nCurrent Chapter: " . Dumper($chapter_ref)
         . "\n\nNext Chapters: " . Dumper(@next_chapters);

  $body = '<div class=white>' . $cgi->hr
        . $cgi->center($cgi->b($cgi->a({-href=>'stories.cgi?story='.$story_id},$story_ref->{title})))
        . $cgi->hr
        . $cgi->b('Author: ') . $story_ref->{user} . $cgi->br
        . $cgi->b('Descrition: ') . $story_ref->{description}
        . $cgi->hr
        . $cgi->b('Chapter title: ') . $chapter_ref->{title}
        . $cgi->hr
        . $cgi->b('Chapter text: ') . $cgi->blockquote($chapter_ref->{body})
        . $cgi->hr
        . $cgi->b('Next steps: ');
        
  for my $next (@next_chapters) {
    $body .= $cgi->p($cgi->a({-href=>'stories.cgi?story='.$story_id.'&chapter='.$next->{id}},$next->{title}));
  }
  
  $body .= $cgi->hr
        . $cgi->b($cgi->a({href=>'add-chapter.cgi?chapter='.$chapter_id},'Add a chapter... '))
        . '</div>';

} else {

  my @stories = $w->list_stories;
  $body .= '<div class=white>' . $cgi->hr . $cgi->start_ul;

  for my $story (@stories) {
    my $id    = $story->{id};
    my $title = $story->{title};
    $body .= $cgi->li( $cgi->b($cgi->a({-href=>"stories.cgi?story=".$id},$title)),'by',$story->{user} );
  }

  $body .= $cgi->end_ul . $cgi->hr
        . $cgi->a({href=>'add-story.cgi'},'Add a story... ')
        . '</div>';
  $debug = Dumper(@stories);

}

### Output the page

my $meta = HTML::Template->new(
             die_on_bad_params => 0,
             scalarref => \$tmpl
           );

$meta->param(
  title        => "Macrophile.com - Stories",
  body         => $body,
  debug        => $cgi->pre($debug),

  time         => scalar localtime,
  year         => 2011,

  html_prefix  => $html_prefix,
  image_prefix => $image_prefix,
  start_table  => $start_table,
  end_table    => $end_table
);

print $meta->output;