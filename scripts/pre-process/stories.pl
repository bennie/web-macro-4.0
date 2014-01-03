#!/usr/bin/perl -w -I/var/www/macrophile.com/lib

# This page generates the art page from info in the DB.
# (c) 2006, Phillip Pollard <bennie@macrophile.com>

use Macro;
use Macro::Forum;
use Macro::Util qw/safe_username/;
use strict;

### Conf

my $debug = 0;
my $name  = 'stories';

my @forums = qw/2 9/;
my %forums = (
  2 => 'Macro Story',
  9 => 'Macro Story (Adult)',
);

my %usernames;

### Main

my $macro = new Macro;
my $cgi = $macro->{cgi};

my $mf = new Macro::Forum;

### Sort out the thumbnails

print 'PRE: phpbb_attachments';

### Build the page

my $body = "<table class=\"innertable\" cellspacing=\"0\" cellpadding=\"3\">\n\n";

###

print "--> raw_pages table ";

my @table;

for my $forum ( @forums ) {
  my @rows  =  qw/row1 row2/; # Alternated row styles
  @table = ( $cgi->Tr(
                   $cgi->td({-class=>'innertablesubhead br'},'Author'),
                   $cgi->td({-class=>'innertablesubhead br'},'Date'),
                   $cgi->td({-class=>'innertablesubhead br'},'Replies'),
                   $cgi->td({-class=>'innertablesubhead br'},'Title'),
             )
  );

  my $attach = $mf->recent_posts({ forum => $forum, limit => 10 });
  for my $key ( sort { $a <=> $b } keys %$attach ) {
    my $class = $rows[0] . ' br';
    push @rows, shift @rows;

    my $subject = $attach->{$key}->{post_subject};
    $subject =~ s/\s/&nbsp;/g;

    my $username = &username($attach->{$key}->{poster_id});
    my $userlink = safe_username($username);
    $username =~ s/\s/&nbsp;/g;

    my $time = $attach->{$key}->{pretty_time};
    $time =~ s/\s/&nbsp;/g;

    push @table, $cgi->Tr(
                   $cgi->td({-class=>$class},$cgi->a({-href=>'http://users.macrophile.com/'.$userlink},$username)),
                   $cgi->td({-class=>$class,-align=>'center'},$time),
                   $cgi->td({-class=>$class,-align=>'right'},$attach->{$key}->{topic_replies}),
                   $cgi->td({-class=>$class},$cgi->b($cgi->a({-href=>'http://forums.macrophile.com/viewtopic.php?t='.$attach->{$key}->{topic_id}},$subject)))
                 );
  }
  $body .= "<tr><td class=\"innertablehead\" colspan=\"4\">Recent Forum Stories - $forums{$forum}</td></tr>\n"
        .  join('',@table)
        .  "\n\n";
}

$body .= "</td></tr></table>\n";

### Generate the page

my $ret = $macro->update_raw_page($name,$body);

print "--> done! (return $ret)\n";


### Subs

sub debug {
  if ( $debug ) {
    for my $line (@_) {
      chomp $line;
      print "DEBUG: $line\n";
    }
  }
}

sub username {
  my $id = shift @_ || return '';
  unless ( $usernames{$id} ) {
    my $ref = $mf->user($id);
    $usernames{$id} = $ref->{username};
  }
  return $usernames{$id};
}
