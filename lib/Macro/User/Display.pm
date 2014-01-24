=head1 Macro::User::Display

----------------+--------------+------+-----+---------+-------+
| Field          | Type         | Null | Key | Default | Extra |
+----------------+--------------+------+-----+---------+-------+
| username       | varchar(100) |      | PRI |         |       |
| full_name      | varchar(250) | YES  |     | NULL    |       |
| secondary_name | varchar(250) | YES  |     | NULL    |       |
| quote          | varchar(250) | YES  |     | NULL    |       |
| height         | bigint(20)   | YES  |     | NULL    |       |
| weight         | bigint(20)   | YES  |     | NULL    |       |
| hobbies        | text         | YES  |     | NULL    |       |
| residence      | text         | YES  |     | NULL    |       |
| website        | text         | YES  |     | NULL    |       |
| description    | text         | YES  |     | NULL    |       |
+----------------+--------------+------+-----+---------+-------+

=cut

package Macro::User::Display;

use Macro::DB;
use strict;

sub new {
  my $self = {};
  bless $self;

  our $db = new Macro::DB;
  our $table = 'u_macrocards'; # $db->get_config('users');

  return $self;
}

=item info

=cut

sub info {
  
}

=item verify()

Given a username, verify if it exists or not. Returns the number of 
matching usernames.

=cut

sub verify {
  my $self     = shift @_;
  my $username = shift @_;

  our $db;
  our $table;

  my $sql = "select count(*) from $table where username="
          . $db->quote($username);
  return $db->single($sql);
}

1;
