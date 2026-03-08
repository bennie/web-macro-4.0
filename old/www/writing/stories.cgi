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
my $cgi  = $macro_auth->{cgi};
my $user = $macro_auth->{username} ? $macro_auth->{username} : 'guest';

### Main

my $body;
my $debug;

print $cgi->header();

my $story_id = $cgi->param('story');
my $chapter_id = $cgi->param('chapter');

$body = '[ ' . ($macro_auth->{username} ? "Logged in: $user" : $cgi->a({href=>'/login.cgi?redirect=/writing/stories.cgi'},'Login')) . ' ]' . $cgi->hr;

if ( $story_id and $story_id =~ /^\d+$/ and $chapter_id and $chapter_id =~ /^\d+$/ and $cgi->param('all') eq '1' ) {

  my $story_ref = $w->get_story($story_id);

  $body .= $cgi->b('Story: "' . $cgi->a({-href=>'stories.cgi?story='.$story_id.'&chapter='.$chapter_id},$story_ref->{title})) . '" by ' . $story_ref->{user}
        . $cgi->hr;

  my $chapter_ref = $w->get_chapter($chapter_id);  
  my @story = ( $chapter_ref );
  
  while ( $chapter_ref->{previous_chapter} ) {
    $chapter_ref = $w->get_chapter($chapter_ref->{previous_chapter});
    unshift @story, $chapter_ref;
  }

  for my $ref ( @story ) {
    $body .= $cgi->b('Chapter: ') . '"' . $ref->{title} . '" by ' . $ref->{user}
          .  $cgi->hr
          .  $cgi->blockquote($ref->{body})
          .  $cgi->hr;
  }
  
  $body .= $cgi->small("Displaying the full story up to this point.");

} elsif ( $story_id and $story_id =~ /^\d+$/ ) {

  my $story_ref = $w->get_story($story_id);
  my $chapter_ref;
  
  if ( $chapter_id =~ /^\d+$/ ) { # Pull the called for chapter
    $debug .= "Pulling the chapter from the given id: $chapter_id\n\n";
    $chapter_ref = $w->get_chapter($chapter_id);
  } else { # Figure out the first chapter of the story
    $debug .= "Figuring the chapter from the start of the story id.\n\n";
    my @chapters = $w->list_chapters($story_id,0);  
    $chapter_ref = $chapters[0];
    $chapter_id = $chapter_ref->{id};
  }
  my @next_chapters = $w->list_chapters($story_id,$chapter_id);

  $debug .= "Story: " . Dumper($story_ref) ."\n\nCurrent Chapter: " . Dumper($chapter_ref)
         . "\n\nNext Chapters: " . Dumper(@next_chapters);

  $body .= $cgi->b('Story: "' . $story_ref->{title}) . '" by ' . $story_ref->{user}
        . $cgi->hr
        . $cgi->b('This Chapter: ') . '"' . $chapter_ref->{title} . '" by ' . $chapter_ref->{user}
        . $cgi->hr
        . $cgi->center(
            '[',
            $cgi->a({-href=>'stories.cgi?story='.$story_id},'back to the beginning'),
            '|',
            $cgi->a({-href=>'stories.cgi?story='.$story_id.'&chapter='.$chapter_ref->{previous_chapter}},'back a chapter'),
            '|',
            $cgi->a({-href=>'stories.cgi?all=1&story='.$story_id.'&chapter='.$chapter_id},'whole story to this point'),
            ']')
        . $cgi->hr
        . $cgi->blockquote($chapter_ref->{body})
        . $cgi->hr
        . $cgi->b('Next steps: ')
        . $cgi->start_ul;
        
  for my $next (@next_chapters) {
    $body .= $cgi->li($cgi->a({-href=>'stories.cgi?story='.$story_id.'&chapter='.$next->{id}},'"'.$next->{title}.'"'),'by',$next->{user});
  }
  
  $body .= $cgi->end_ul;
  $body .= $cgi->p('[', ($macro_auth->{username} ? $cgi->a({href=>'add-chapter.cgi?chapter='.$chapter_id},'Add a chapter... ') : $cgi->a({href=>'/login.cgi?redirect=/writing/stories.cgi'},'Login to add a chapter') ), ']');

} else {

  my @stories = $w->list_stories;
  $body .= $cgi->start_ul;

  for my $story (@stories) {
    my $id    = $story->{id};
    my $title = $story->{title};
    $body .= $cgi->li( $cgi->b($cgi->a({-href=>"stories.cgi?story=".$id},$title)),'by',$story->{user} );
  }

  $body .= $cgi->end_ul;
  $body .= '[ '. $cgi->a({href=>'add-story.cgi'},'Add a story...') . ' ]';
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