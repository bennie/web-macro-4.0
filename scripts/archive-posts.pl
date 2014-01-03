#!/usr/bin/perl -I/var/www/macrophile.com/lib

use Macro::Forum;
use strict;

my %moves;

$moves{1}  = 19; # Macro Chat
$moves{3}  = 20; # Macro Art
$moves{8}  = 21; # Macro Art (Adult)
$moves{2}  = 22; # Macro Story
$moves{9}  = 23; # Macro Story (Adult)
$moves{13} = 18; # Collateral Damage
$moves{5}  = 16; # Roleplay
$moves{11} = 17; # Roleplay Adult

my $mf  = new Macro::Forum;
my $old = time - ( 2678400 * 3 ); # 31 days

# needs to be 25 posts at least.
# So count them backwards in order from 25, and then look for anything older than 
# our age limit.

for my $id ( keys %moves ) {
  my %keep;

  my $sth = $mf->_handle('select t.topic_id, topic_title, p.post_id, post_time from phpbb_topics t, phpbb_posts p where t.forum_id=? and t.topic_last_post_id = p.post_id order by post_time desc limit 25',$id);
  while ( my $ref = $sth->fetchrow_arrayref ) {
    $keep{$ref->[0]}++
  }
  $sth = undef;

  $sth = $mf->_handle('select t.topic_id, topic_title, p.post_id, post_time from phpbb_topics t, phpbb_posts p where t.forum_id=? and t.topic_last_post_id = p.post_id and p.post_time < ? order by post_time',$id,$old);
  while ( my $ref = $sth->fetchrow_arrayref ) {
    my $topicid = $ref->[0];
    my $title = $ref->[1];
    my $date  = $ref->[3];

    next if $topicid == 308; # Adult access info in Macro Chat
    next if $topicid == 8575; # Content rules in Collateral Damage

    my $viewdate = scalar(localtime($date));

    print "$topicid) $title : $viewdate\n";

    if ( $keep{$topicid} ) {
      print " -- SKIP THIS FOR FULLNESS\n" 
    } else {
      &move($topicid,$moves{$id});
    }

  }

  &update_forum_counts($moves{$id});
  &update_forum_counts($id);
}

sub move {
  my $topicid = shift @_;
  my $forumid = shift @_;
  die "BAD INFO" unless $topicid =~ /^\d+$/ and $forumid =~ /^\d+$/;
  print " Moving $topicid to forum $forumid (";

  my $dbh = $mf->_dbh;
  my $sth = $dbh->prepare("update phpbb_topics set forum_id=$forumid where topic_id=$topicid");
  my $ret = $sth->execute;

  print "$ret:";
  $ret = $sth = undef;

  $sth = $dbh->prepare("update phpbb_posts set forum_id=$forumid where topic_id=$topicid");
  my $ret = $sth->execute;
  print "$ret)\n";
}

sub update_forum_counts {
  my $forumid = shift @_;
  print " Updating forum $forumid\n";

  my $sth = $mf->_handle('select count(*) from phpbb_topics where forum_id=?',$forumid);
  my $ref = $sth->fetchrow_arrayref;
  my $topics = $ref->[0];
  $sth = $ref = undef;

  $sth = $mf->_handle('select count(*) from phpbb_posts where forum_id=?',$forumid);
  my $ref = $sth->fetchrow_arrayref;
  my $posts = $ref->[0];
  $sth = $ref = undef;

  $sth = $mf->_handle('select post_id from phpbb_posts where forum_id=? order by post_time desc limit 1',$forumid);
  my $ref = $sth->fetchrow_arrayref;
  my $postid = $ref->[0];
  $sth = $ref = undef;

  die unless $topics =~ /^\d+$/ and $posts =~ /^\d+$/ and $postid =~ /^\d+$/ and $forumid =~ /^\d+$/;

  my $dbh = $mf->_dbh;
  my $sth = $dbh->prepare("update phpbb_forums set forum_posts=$posts, forum_topics=$topics, forum_last_post_id=$postid where forum_id=$forumid");
  my $ret = $sth->execute;
}
