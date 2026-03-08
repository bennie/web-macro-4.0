=head1 Macro::User::Admin

This module performs administrative actions reguarding a user.

=cut

package Macro::User::Admin;
       $Macro::User::Admin::VERSION='$Revision: 1.1 $';

use Macro::DB;
use Digest::MD5 qw/md5_hex/;
use strict;

sub new {
  my $self = {};
  bless $self;

  $self->{db}      = new Macro::DB;
  $self->{table}   = 'u_users'; # $self->{db}->get_config('users');

  return $self;
}

=item adduser()

Give a hasref of a username, password and email, add the user to the user 
table.

=cut

sub adduser {
  my $self = shift @_;
  my $conf = shift @_;

  my $db    = $self->{db};
  my $table = $self->{table};

  return 0 if $self->verify($conf->{username}) > 0;

  my $u = $db->quote($conf->{username});
  my $p = $db->quote(md5_hex($conf->{username},$conf->{password}));
  my $e = $db->quote($conf->{email});

  my $sql = "insert into $table (username,password,email) values ($u,$p,$e)";

  return $db->do($sql);
}

=item verify()

Given a username, verify if it exists or not. Returns the number of 
matching usernames.

=cut

sub verify {
  my $self     = shift @_;
  my $username = shift @_;

  my $db    = $self->{db};
  my $table = $self->{table};

  my $sql = "select count(*) from $table where username="
          . $db->quote($username);
  return $db->single($sql);
}

1;
