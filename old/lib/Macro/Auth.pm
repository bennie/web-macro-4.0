package Macro::Auth;

use CGI;
use DBI;
use Digest::MD5 qw/md5_hex/;
use LocalAuth;
use strict;

sub new {
  my     $self = {};
  bless  $self;

  my %out = ( username => undef );
  $out{cgi} = new CGI;

  # Check for "our" auth first, and handle that if present

  if ( $out{cgi}->cookie('new_macro_session') ) {
    $out{cookie} = $out{cgi}->cookie('new_macro_session');

    $out{sql} = 'select username, expire, last_modified from sessions where session_id=?';

    my $dbh = DBI->connect('dbi:mysql:dbname='.$LocalAuth::WEB_DB, $LocalAuth::WEB_USER, $LocalAuth::WEB_PASS)
                or $out{error} = "DB Connect Error: $DBI::errstr" && return \%out;

    my $sth = $dbh->prepare($out{sql});
    my $ret = $sth->execute($out{cookie});

    if ( $ret == 1 ) {
      $out{uuid} = $out{cookie};
      my $ref = $sth->fetchrow_arrayref;
      $out{username}      = $ref->[0];
      $out{expire}        = $ref->[0];
      $out{last_modified} = $ref->[0];
    } else {
      $out{error} = "Bad DB return code of $ret";
    }

    $sth->finish;
    $dbh->disconnect;
    
    return \%out;
  }

  # Handle phpbb3 cookies and auth on that as a fallback
 
  $out{cookie_sid}     = $out{cgi}->cookie('macrophile_bb_sid');
  $out{cookie_t}       = $out{cgi}->cookie('macrophile_bb_t');
  $out{cookie_data}    = $out{cgi}->cookie('macrophile_bb_data');
  $out{cookie_session} = $out{cgi}->cookie('macrophile_bb_session');

  my $dbh; # only populate if needed, close when done

  # Values

  $out{keyid}  = md5_hex($1) if $out{cookie_data} =~ /11:"autologinid";s:32:"([\da-f]+)"/;
  $out{userid} = $2 if $out{cookie_data} =~ /6:"userid";(i|s:-?\d+):"?(\d+)"?;\}/;
  $out{sid}    = $1 if $out{cookie_sid} =~ /([\da-f]{32})/;  

  # always-login cookie

  if ( $out{userid} and $out{keyid} and not $out{username} ) {
    $out{sql} = 'select username from phpbb_users u, phpbb_sessions_keys s where u.user_active=1 and u.user_id = s.user_id and u.user_id=? and s.key_id=?';

    $dbh = DBI->connect('dbi:mysql:dbname='.$LocalAuth::FORUM_DB, $LocalAuth::FORUM_USER, $LocalAuth::FORUM_PASS)
             or $out{error} = "DB Connect Error: $DBI::errstr" && return \%out;

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
    $out{sql} = 'select username from phpbb_users u, phpbb_sessions s where u.user_id = s.session_user_id and session_logged_in=1 and session_id=? and session_user_id=?';

    unless ( defined $dbh ) {
      $dbh = DBI->connect('dbi:mysql:dbname='.$LocalAuth::FORUM_DB, $LocalAuth::FORUM_USER, $LocalAuth::FORUM_PASS)
               or $out{error} = "DB Connect Error: $DBI::errstr" && return \%out;
    }

    my $sth = $dbh->prepare($out{sql});
    my $ret = $sth->execute($out{sid},$out{userid});

    if ( $ret == 1 ) {
      $out{username} = $sth->fetchrow_arrayref->[0];
    } else {
      $out{error} = "Bad DB return code of $ret";
    }

    $sth->finish;
  }

  $dbh->disconnect if defined $dbh;

  # Final check

  if ( $out{userid} < 0 ) { # -1 is guest
    $out{userid} = undef
    $out{username} = undef
  }

  return \%out;
}

1;