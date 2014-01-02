package Macro::Auth;

$Macro::Auth::VERSION='$Revision: 1.8 $';

use CGI;
use DBI;
use Digest::MD5 qw/md5_hex/;
use LocalAuth;
use strict;

sub new {
  my     $self = {};
  bless  $self;

  # Conf
  
  my $cookie_prefix = 'macrophile_bb';
  my $table_prefix  = 'phpbb';

  my $db_driver = 'mysql';
  my $db_name   = $LocalAuth::FORUM_DB;
  my $db_host   = $LocalAuth::FORUM_HOST;
  my $db_user   = $LocalAuth::FORUM_USER;
  my $db_pass   = $LocalAuth::FORUM_PASS;

  # Do it

  my %out = ( username => undef );

  my @db_connect = ("dbi:$db_driver:dbname=$db_name:host=$db_host", $db_user, $db_pass);

  my $dbh = DBI->connect(@db_connect)
    or $out{error} = "DB Connect Error: $DBI::errstr" && return \%out;

  $out{cgi} = new CGI;
 
  $out{cookie_sid}     = $out{cgi}->cookie($cookie_prefix.'_sid');
  $out{cookie_t}       = $out{cgi}->cookie($cookie_prefix.'_t');
  $out{cookie_data}    = $out{cgi}->cookie($cookie_prefix.'_data');
  $out{cookie_session} = $out{cgi}->cookie($cookie_prefix.'_session');

  # Values

  $out{keyid}  = md5_hex($1) if $out{cookie_data} =~ /11:"autologinid";s:32:"([\da-f]+)"/;
  $out{userid} = $2 if $out{cookie_data} =~ /6:"userid";(i|s:-?\d+):"?(\d+)"?;\}/;
  $out{sid}    = $1 if $out{cookie_sid} =~ /([\da-f]{32})/;  

  # always-login cookie

  if ( $out{userid} and $out{keyid} and not $out{username} ) {
    $out{sql} = 'select username from '.$table_prefix.'_users u, '.$table_prefix.'_sessions_keys s where u.user_active=1 and u.user_id = s.user_id and u.user_id=? and s.key_id=?';

    my $sth = $dbh->prepare($out{sql});
    my $ret = $sth->execute($out{userid},$out{keyid});

    if ( $ret == 1 ) {
      $out{username} = $sth->fetchrow_arrayref->[0];
    } else {
      $out{error} = "Bad DB return code of $ret";
    }

    $sth->finish;
  }

  # by session

  if ( $out{sid} and $out{userid} and $out{userid} != -1 and not $out{username} ) {
    $out{sql} = 'select username from '.$table_prefix.'_users u, '.$table_prefix.'_sessions s where u.user_id = s.session_user_id and session_logged_in=1 and session_id=? 
and session_user_id=?';

    my $sth = $dbh->prepare($out{sql});
    my $ret = $sth->execute($out{sid},$out{userid});

    if ( $ret == 1 ) {
      $out{username} = $sth->fetchrow_arrayref->[0];
    } else {
      $out{error} = "Bad DB return code of $ret";
    }

    $sth->finish;
  }

  $dbh->disconnect;

  # Final check

  if ( $out{userid} < 0 ) {
    $out{userid} = undef
    $out{username} = undef
  }

  return \%out;
}

1;
