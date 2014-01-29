#!/usr/bin/perl -I/var/www/macrophile.com/lib
#!/opt/local/bin/perl -I/Users/phil/Documents/work/web-macro-4.0/lib

use CGI::Carp qw/fatalsToBrowser/;
use Data::Dumper;
use Macro::Auth;
use Macro::Template;
use Writing;
use strict;

my $tmpl = new Macro::Template ('main-template-css');

my $w = new Writing;

my $macro_auth = new Macro::Auth;
my $cgi        = $macro_auth->{cgi};
my $user       = $macro_auth->{username} ? $macro_auth->{username} : 'guest';

### Main

#my $story = $w->get_story(1);
#print Dumper($story), "\n";

print $cgi->header();

my $body; 
my $debug;

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

  $body = $cgi->hr
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
        . $cgi->b($cgi->a({href=>'add-chapter.cgi?chapter='.$chapter_id},'Add a chapter... '));

} else {

  my @stories = $w->list_stories;
  $body .= '[ ' . ($macro_auth->{username} ? "Logged in: $user" : $cgi->a({href=>'/login.cgi?redirect=/writing/stories.cgi'},'Login')) .' | '. $cgi->a({href=>'add-story.cgi'},'Add a story...') . ' ]'
        . $cgi->hr . $cgi->start_ul;

  for my $story (@stories) {
    my $id    = $story->{id};
    my $title = $story->{title};
    $body .= $cgi->li( $cgi->b($cgi->a({-href=>"stories.cgi?story=".$id},$title)),'by',$story->{user} );
  }

  $body .= $cgi->end_ul;
  $debug .= Dumper(@stories);

}

### Output the page

print $tmpl->do({
  title => "Interactive Stories",
  body  => $body,

  time  => scalar localtime,
  year  => ((localtime)[5]+1900),

  user  => $user,
  debug => $cgi->pre($debug) . $cgi->pre(Dumper($macro_auth)),
});