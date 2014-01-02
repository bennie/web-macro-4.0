package Macro::Forum;

$Macro::Forum::VERSION='$Revision: 1.22 $';

use CGI;
use DBI;
use LocalAuth;
use Macro::Util qw/safe_username/;

use strict;

sub new {
  my $self = {};
  bless $self;
  return $self;
}

=head2 Private Methods:

=head3 _cgi()

Returns the current CGI handle if called.

=cut

sub _cgi {
  my $self = shift @_;
  unless ( defined $self->{cgi} ) {
    $self->{cgi} = new CGI;
  }
  return $self->{cgi};
}

=head3 _dbh()

Returns the current database handle.

=cut

sub _dbh {
  my $self = shift @_;
  unless ( defined $self->{dbh} ) {
    my $db_driver = 'mysql';
    my $db_host   = $LocalAuth::FORUM_HOST;
    my $db_name   = $LocalAuth::FORUM_DB;
    my $db_user   = $LocalAuth::FORUM_USER;
    my $db_pass   = $LocalAuth::FORUM_PASS;
    my @dbconnect = ("dbi:$db_driver:dbname=$db_name:host=$db_host", $db_user, $db_pass);
    $self->{dbh} = DBI->connect(@dbconnect) or die "Connecting: $DBI::errstr";
  }
  return $self->{dbh};
}

=head3 _handle($sql,@binds)

Returns either the statement handle or the return value and statement handle if queried
as an array.

=cut

sub _handle {
  my $self = shift @_;
  my $dbh = $self->_dbh();
  my $sth = $dbh->prepare(shift @_);
  my $ret = $sth->execute(@_);  
  return wantarray ? ($ret,$sth) : $sth;
} 

=head2 Public Methods:

=head3 attachment($attach_id) 

Return an attahcment ref for the given id.

=cut

sub attachment {
  my $self = shift @_;
  my $id   = shift @_;
  return $self->recent_attachments({ attachid => $id });
}

=head3 attachment_html($attach_ref)

Returns an image block and a description block for pages for a given attachment.

=cut

sub attachment_html {
  my $self = shift @_;
  my $ref  = shift @_;
  my $cgi  = $self->_cgi();
  
  my $file = $ref->{physical_filename};
  my $post = $ref->{post_msg_id};
  my $href = 'http://forums.macrophile.com/viewtopic.php?p='.$post.'#'.$post;

  my %post = $self->post($post);
  my $forum_id = $post{forum_id};
  my $topic_id = $post{topic_id};
  my $user_id = $post{poster_id};
  my $time = scalar(localtime($post{post_time}));
  
  my $image = $cgi->font({-size=>1},$time) . $cgi->br
            . ( $post{forum_id} == 8 ? '<!--[adultimg]-->' : '' )
            . $cgi->a({-href=>$href},
                $cgi->img($self->thumbnail($ref->{attach_id}))
              )
            . ( $post{forum_id} == 8 ? '<!--[/adultimg]-->' : '' );

  #my $desc = $cgi->p( map { $_ . ':' . $attach->{$key}->{$_} . $cgi->br } keys %{$attach->{$key}} );
  
  my %topic = $self->topic($topic_id);
  my %user  = $self->user($user_id);

  my $desc = $cgi->a({-href=>$href},$cgi->b($ref->{real_filename})) . $cgi->br
           . 'By: ' . $cgi->a({-href=>'http://users.macrophile.com/'.safe_username($user{username})},$user{username}) . $cgi->br
           . 'Topic: ' . $cgi->a({-href=>'http://forums.macrophile.com/viewtopic.php?t='.$topic_id},$topic{topic_title});

  return ( $image, $desc );
}

=head3 recent_attachments($conf)

Accepts as hashref of parameters:

  forum: $forum_number - restruct the search to a particular forum
  limit: $limit - only return a certain number of images, default is all.
  forums: $forumarrayref - limit the search to these forums
  userid: $userid - limit search to this user's attachments
  attachid: $attachid - return info on a specific attachment
=cut

sub recent_attachments {
  my $self = shift @_;
  my $conf = shift @_ || {};
  
  my $limit = $conf->{limit};
  if ( $limit ) { 1 while $limit =~ s/\D//gi; }

  my $dbh = $self->_dbh();
 
  my @constraints;

  push @constraints, 'b.forum_id='.$dbh->quote($conf->{forum}) if $conf->{forum};
  push @constraints, 'b.forum_id in ('. join(',',@{$conf->{forums}}) .')' if ref $conf->{forums};
  push @constraints, 'b.poster_id='.$dbh->quote($conf->{userid}) if $conf->{userid};
  push @constraints, 'a.attach_id='.$dbh->quote($conf->{attachid}) if $conf->{attachid};
  
  my $sql = "select a.post_msg_id, a.attach_id, a.physical_filename, a.real_filename, a.download_count,
             a.attach_comment, b.forum_id from phpbb3_attachments a, phpbb3_posts b where 
             a.post_msg_id = b.post_id and a.post_msg_id != 0 "
           . ( scalar(@constraints) ? ' and ' . join(' and ',@constraints) : '' )
           . ' order by a.post_msg_id desc, a.attach_id';

  $sql .= " limit $limit" if $limit;

  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute();

  my $out = {};
  my $count++;

  while ( my $ref = $sth->fetchrow_hashref ) {
    $out->{$count++} = { %$ref };
  }
  
  return $out;
}

=head3 recent_posts($conf)

Accepts as hashref of parameters:

  forum: $forum_number - restruct the search to a particular forum
  limit: $limit - only return a certain number of stories, default is all.
  forums: $forumarrayref - limit the search to these forums
  userid: $userid - limit search to this user's stories

=cut

sub recent_posts {
  my $self = shift @_;
  my $conf = shift @_ || {};
  
  my $limit = $conf->{limit};
  if ( $limit ) { 1 while $limit =~ s/\D//gi; }

  my $dbh = $self->_dbh();
 
  my @constraints;

  push @constraints, 'a.forum_id='.$dbh->quote($conf->{forum}) if $conf->{forum};
  push @constraints, 'a.forum_id in ('. join(',',@{$conf->{forums}}) .')' if ref $conf->{forums};
  push @constraints, 'a.topic_poster='.$dbh->quote($conf->{userid}) if $conf->{userid};

  my $sql = 'select a.topic_id, a.forum_id, a.topic_title, a.topic_poster as poster_id, a.topic_replies, a.topic_time, '
          . 'b.post_id, b.post_subject '
          . 'from phpbb3_topics a, phpbb3_posts b '
          . 'where a.topic_first_post_id=b.post_id'
          . ( scalar(@constraints) ? ' and ' . join(' and ',@constraints) : '' )
          . ' order by a.topic_id desc';
          
  $sql .= " limit $limit" if $limit;

  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute();

  my $out = {};
  my $count++;

  while ( my $ref = $sth->fetchrow_hashref ) {
    my @time = split ' ', scalar(localtime($ref->{topic_time})); 
    $ref->{pretty_time} = "$time[1] $time[2], $time[4]";
    $out->{$count++} = { %$ref };
  }
  
  return $out;
}

=head3 forum($forum_id)

Returns a hash or hashref of the given forum id's information.

=cut

sub forum {
  my $self = shift @_;
  my $for  = shift @_;

  my $sql = 'select * from phpbb3_forums where forum_id=?';

  my $dbh = $self->_dbh();
  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute($for);

  my $ref = $sth->fetchrow_hashref;
  my %out = %$ref;
  
  $sth->finish;
  
  return wantarray ? %out : \%out;
}

=head3 post($post_id)

Returns a hash or hashref of the given post id's information.

=cut

sub post {
  my $self = shift @_;
  my $post = shift @_;

  my $sql = 'select * from phpbb3_posts where post_id=?';

  my $dbh = $self->_dbh();
  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute($post);

  my $ref = $sth->fetchrow_hashref;
  my %out = %$ref;
  
  $sth->finish;
  
  return wantarray ? %out : \%out;
}

=head3 post_attachments($post_id)

Returns an array or arrayref of attachment IDs for the given post

=cut

sub post_attachments {
  my $self = shift @_;
  my $post = shift @_;

  my $sql = 'select attach_id from phpbb3_attachments where post_id=?';

  my $dbh = $self->_dbh();
  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute($post);

  my @out;

  while ( my $ref = $sth->fetchrow_arrayref ) {
    push @out, $ref->[0];
  }
  
  $sth->finish;
  
  return wantarray ? @out : \@out;

}

=head3 thumbnail($attach_id)

Returns thumbnail information for a given attachment id.

=cut

sub thumbnail {
  my $self = shift @_;
  my $id   = shift @_;

  my $sql = 'select * from thumbnails where attach_id=?';

  my $dbh = $self->_dbh();
  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute($id);

  my $out = {};

  if ( $ret == 1 ) {
    my $ref = $sth->fetchrow_hashref;
    $out->{src}    = 'http://www.macrophile.com/images/preview/' . $ref->{physical_filename};
    $out->{width}  = $ref->{width};
    $out->{height} = $ref->{height};
  } else {
    $out->{src}  = 'http://www.macrophile.com/images/icons/unknown.gif';
    $out->{width} = 32;
    $out->{height} = 32;
  }
  
  $out->{border} = 0;
  $out->{hspace} = 2;
  $out->{vspace} = 2;
  
  return $out;
}

=head3 topic($topic_id)

Returns a hash or hashref of the given topic id's information.

=cut

sub topic {
  my $self  = shift @_;
  my $topic = shift @_;

  my $sql = 'select * from phpbb3_topics where topic_id=?';

  my $dbh = $self->_dbh();
  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute($topic);

  my $ref = $sth->fetchrow_hashref;
  my %out = %$ref;
  
  $sth->finish;
  
  return wantarray ? %out : \%out;
}

=head3 topic_posts($topic_id)

Returns an array or arrayref of all posts within a given topic.

=cut

sub topic_posts {
  my $self  = shift @_;
  my $topic = shift @_;

  my $sql = 'select post_id from phpbb3_posts where topic_id=? order by post_id';

  my $dbh = $self->_dbh();
  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute($topic);

  my @out;

  while ( my $ref = $sth->fetchrow_arrayref ) {
    push @out, $ref->[0];
  }
  
  $sth->finish;
  
  return wantarray ? @out : \@out;
}

=head3 user($user_id,[$conf])

Returns a hash or hashref of the given user id's information.

Information in the hasref includes the following fields:

  user_id, user_active, username, user_password, user_session_time,
  user_session_page, user_lastvisit, user_regdate, user_level, user_posts, 
  user_timezone, user_style, user_lang, user_dateformat, user_new_privmsg,
  user_unread_privmsg, user_last_privmsg, user_emailtime, user_viewemail,
  user_attachsig, user_allowhtml, user_allowbbcode, user_allowsmile,
  user_allowavatar, user_allow_pm, user_allow_viewonline, user_notify
  user_notify_pm, user_popup_pm, user_rank, user_avatar, user_avatar_type,
  user_email, user_icq, user_website, user_from, user_sig, user_sig_bbcode_uid,
  user_aim, user_yim, user_msnm, user_occ, user_interests, user_actkey,
  user_newpasswd, user_custom_title, user_custom_title_status, last_modified, 
  pretty_regdate

An optional configuration hashref will lookup up addition information:

  'attachments' => 1 - Will add count_attach, and an attachments subhash to the user hash.
 
     The attachments hash will be keyed by attach_id and the subhash for each key will contain:

       attach_id, post_id, user_id_1, physical_filename, real_filename, 
       download_count, comment, extension, mimetype, filesize, filetime,
       thumbnail

=cut

sub user {
  my $self = shift @_;
  my $user = shift @_;
  my $conf = shift @_;

  my $sql = 'select * from phpbb3_users where user_id=?';

  my $dbh = $self->_dbh();
  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute($user);

  my $ref = $sth->fetchrow_hashref;
  my %out = %$ref;
  
  $sth->finish;

  $out{pretty_regdate} = scalar(localtime($out{user_regdate}));
  1 while $out{pretty_regdate} =~ s/\s+/&nbsp;/g;
  
  if ( $conf->{attachments} ) {
    $sth = $dbh->prepare('select * from phpbb3_attachments where post_msg_id > 0 and poster_id=?');
    $ret = $sth->execute($user);
    while ( my $ref = $sth->fetchrow_hashref() ) {
      $out{attachments}{$ref->{attach_id}} = \%$ref;
    }
    $out{count_attach} = scalar(keys %{$out{attachments}});
  }
  
  return wantarray ? %out : \%out;
}

=head3 users($conf)

Returns a hash or hashref of all ACTIVE usernames keyed by user_id.

Conf:

  active : set to 0 to remove active restriction
  post   : set to true to require the user to have posts

=cut

sub users {
  my $self = shift @_;
  my $conf = shift @_ || {};

  my @constraints = ( 'user_inactive_time=0' );
  @constraints = () if defined $conf->{active} and $conf->{active} eq '0';

  push @constraints, 'user_posts > 0' if $conf->{posts};

  my $dbh = $self->_dbh();
  my $sql = 'select user_id, username from phpbb3_users';
  
  if ( scalar(@constraints) > 0 ) {
    $sql .= ' where ' . join(' and ', @constraints)
  }

  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute();

  my %out;

  while ( my $ref = $sth->fetchrow_arrayref ) {
    $out{$ref->[0]} = $ref->[1];
  }
  
  $sth->finish;  
  return wantarray ? %out : \%out;
}

return 1;
