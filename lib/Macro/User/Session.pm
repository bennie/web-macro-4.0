=head1 Macro::User::Session

=cut

package Macro::User::Session;

$Macro::User::Session::VERSION='$Revision: 1.4 $';

### Module dependencies

use Digest::MD5 'md5_hex';
use Macro::DB;

use strict;
use warnings;

sub new {
  my $self = {};
  bless $self;

  $self->{db}    = new Macro::DB;
  $self->{debug} = 0;

  return $self;
}

sub _debug {
  my $self = shift @_;
  print 'DEBUG: ', @_, "\n" if $self->{debug} > 0;
}

###
### Public Methods
###

=item check($user,$pass)

=cut

sub check {
  my $self = shift @_;
  my $user = shift @_;
  my $pass = shift @_;

  return 0 unless $self->verify_user($user);

  return $self->{db}->single(
    'select count(*) from phpbb_users where username='
    . $self->{db}->quote($user)
    . ' and user_password='
    . $self->{db}->quote(md5_hex($pass))
  );
}

=item verify_sid($sid)

Given an SID it checks to verify its status. Returns 1 if good, 0 if bad.

=cut

sub verify_sid {
  my $self = shift @_;
  my $sid  = shift @_;

  my $db = $self->{db};

  my $sql = 'select session_user_id from phpbb_sessions where session_logged_in=1 and session_id='
          . $db->quote($sid);
  my $id  = $db->single($sql);

  $self->_debug($id,':',$sql);

  return undef unless defined $id and $id > 0; # id -1 is anonymous/guest

  $sql = 'update phpbb_sessions set session_time=' . time . ' where session_id='
       . $db->quote($sid);
  my $ret = $db->do($sql);

  return $id;
}

sub verify_user {
  my $self = shift @_;
  my $user = shift @_;
  return $self->{db}->single("select count(*) from phpbb_users where username=".$self->{db}->quote($user));
}

sub user {
  my $self = shift @_;
  my $id   = shift @_;
  return $self->{db}->single("select username from phpbb_users where user_id=$id");
}

1;
