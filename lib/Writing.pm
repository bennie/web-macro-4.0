package Writing;

use Macro::DB;
use strict;

sub new {
  my     $self = {};
  bless  $self;

  $self->{md} = new Macro::DB;
  $self->{dbh} = $self->{md}->_dbh();

  return $self;
}

=head3 create_chapter({ story => $story, user => $user, title => $title, body => $body })

=cut

sub create_chapter {
  my $self = shift @_;
  my $data = shift @_;
  $data->{previous_chapter} = 0 unless defined $data->{previous_chapter};
  my $sth = $self->{md}->handle('insert into write_chapters (story,user,title,body,previous_chapter,created) values (?,?,?,?,?,now())');
  my $ret = $sth->execute( map { $data->{$_} ? $data->{$_} : '' } qw/story user title body previous_chapter/ );

  my $id = $self->{dbh}->last_insert_id(undef,undef,qw/write_chapters id/);

  return $id;
}

=head3 create_story({ user => $user, title => $title, description => $desc })

=cut

sub create_story {
  my $self = shift @_;
  my $data = shift @_;
  my $sth = $self->{md}->handle('insert into write_stories (user,title,description,created,last_updated) values (?,?,?,now(),now())');
  my $ret = $sth->execute( map { $data->{$_} ? $data->{$_} : '' } qw/user title description/ );

  my $id = $self->{dbh}->last_insert_id(undef,undef,qw/write_stories id/);

  return $id;
}

=head3 get_chapter($id)

Returns the given chapter as a hash ref.

=cut

sub get_chapter {
  my $self = shift @_;
  my $id   = shift @_;
  my $chapter = $self->{md}->row('select * from write_chapters where id = ?',$id);
  return $chapter;
}

=head3 get_story($id)

Returns the given story as a hash ref.

=cut

sub get_story {
  my $self = shift @_;
  my $id   = shift @_;
  my $story = $self->{md}->row('select * from write_stories where id = ?',$id);
  return $story;
}

=head3 list_stories()

Returns an array of hash references for all stories in the database

=cut

sub list_stories {
  my $self = shift @_;
  my $sth = $self->{md}->handle('select * from write_stories order by id');
  my $ret = $sth->execute();
  my @out;
  while ( my $ref = $sth->fetchrow_hashref ) {
    push @out, { %$ref };
  }
  return @out;
}

=head3 list_chapters($story_id,$chapter_id)

Returns an array of all chapters for the given story id and chapter_id.

A chapter id of '0' is the default and will return the starting chapter of a 
story line.

=cut

sub list_chapters {
  my $self = shift @_;
  my $id   = shift @_;
  my $chap = shift @_;
  $chap = 0 unless defined $chap;
  my $sth = $self->{md}->handle('select * from write_chapters where story=? and previous_chapter=? order by id');
  my $ret = $sth->execute($id,$chap);
  #return ($ret,$id,$chap) if $ret eq '0E0';
  my @out;
  while ( my $ref = $sth->fetchrow_hashref ) {
    push @out, { %$ref };
  }
  return @out;
}

return 1;