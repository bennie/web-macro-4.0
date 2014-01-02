use Apache2::Const -compile => qw/OK SERVER_ERROR/;
use Apache2::RequestRec;
use Apache2::RequestIO;
use Apache::Session::MySQL;
use APR::Table;
use DBI;
use strict;

require Digest::MD5;

package Auth;

sub handler {
  my $r  = shift;

  my $debug = 0;
  my $session_length = 3600;
  my $guest_user = 'Guest';

  my ($id,$userid,$phpbbsid,$username,@debug);
  
  # Parse Cookies
  
  my $cookies = $r->headers_in->get('Cookie');
  
  for my $cookie ( split /; /, $cookies ) {
    $phpbbsid = $1 if $cookie =~ /macrophile_bb_sid=([\da-f]{32})/;
    $userid = $1 if $cookie =~ /macrophile_bb_u=(\d+)/;
    $id = $1 if $cookie =~ /macrophile_bb_session=([\da-f]{32})/;
  }

  push(@debug,"Found Session cookie! ($id)") if $debug;
  push(@debug,"Found User Data! ($userid:$phpbbsid)") if $debug and ($phpbbsid or $userid);

  # Build session
  
  my $dbh = DBI->connect(qw/dbi:mysql:dbname=DBNAME USERNAME PASSWORD/);
  my %session;
  
  eval {
    tie %session, 'Apache::Session::MySQL', $id, { Handle => $dbh, LockHandle => $dbh };
  };

  if ($@) {
    tie %session, 'Apache::Session::MySQL', undef, { Handle => $dbh, LockHandle => $dbh };
    push(@debug,"BAD SESSION! Got new.") if $debug;
  }
  
  push(@debug,"Got Session! ($session{_session_id})") if $debug;

  # Check session

  my $check = 0;
  $check++ unless defined $session{adult};    # All session fields should be there
  $check++ unless defined $session{expire};   # "
  $check++ unless defined $session{userid};   # "
  $check++ unless defined $session{username}; # "

  $check++ if $userid == -1; # Guest userid, they likely just logged out of phpBB
  $check++ if $session{username} eq $guest_user; # Guest user, check to see if they're not guest anymore
  $check++ if $r->request_time > $session{expire}; # Expired session
  $check++ if $session{userid} ne $userid; # Changed userid. Bad juju and/or logout

  push(@debug, "Session is good. Skipping checks. ($check)") if ( $debug and $check == 0 );
  
  if ( $check ) {  
    push(@debug, "Checking session. ($check)") if $debug;
    $session{adult}    = 0;
    $session{userid}   = $userid;
    $session{username} = $guest_user;
    
    # Set expiration

    push(@debug, "Apache: Request time " . $r->request_time );    

    if ( not defined $session{expire} or $r->request_time > $session{expire} ) {
      $session{expire} = $r->request_time + $session_length;
      push(@debug,"Set session to expire: $session{expire}") if $debug;
    }
      
    # Get username

    if ( $phpbbsid and $userid and $userid != -1 and not $username ) { # via active phpbb session
      my $sth = $dbh->prepare('select username from phpbb3_users u, phpbb3_sessions s where u.user_id = s.session_user_id and session_id=? and session_user_id=?');
      my $ret = $sth->execute($phpbbsid,$userid);
      push(@debug,"Username via phpbbsid SQL query returned $ret") if $debug;
      if ( $ret eq "1" ) {
        $username = $sth->fetchrow_arrayref->[0];
        push(@debug,"Found Username ($username)") if $debug;
      }
    }

    if ( $username ) {
      $session{username} = $username;
    }

    # Check adult status
    
    if ( $userid and $userid != -1 ) {
      my $sth = $dbh->prepare('select count(*) from phpbb3_user_group where group_id=161 and user_id=? and user_pending != 1');
      my $ret = $sth->execute($userid);
      push(@debug,"Adult SQL query returned $ret") if $debug;
      if ( $ret eq "1" ) {
        my $count = $sth->fetchrow_arrayref->[0];
        if ( $count > 0 ) {
          $session{adult} = 1;
          push(@debug,"$username is an adult ($count)") if $debug;
        } else {
          push(@debug,"$username is not an adult ($count)") if $debug;
        }
      }
    }
  }

  my %sesscopy = %session;
  untie(%session); # Do it now to reduce locks if possible

  # Create a session cookie if new or changed session
  
  if ( $id ne $sesscopy{_session_id} ) {
    $r->headers_out->set("Set-Cookie" => "macrophile_bb_session=$sesscopy{_session_id}; path=/");
    push(@debug,"Setting Cookie! ($session{_session_id})") if $debug;
  }
  
  # Run the page

  $r->content_type('text/html');

  my $current_page = $r->uri; 
  $current_page=~s/\/(.*)\??/$1/;  
  push(@debug,"You asked for $current_page") if $debug;

  push(@debug,"Cookies: $cookies") if $debug;
  if ( $debug ) { for my $key ( sort keys %ENV ) { push(@debug,"ENV: $key : $ENV{$key}"); } }
  if ( $debug ) { for my $key ( sort keys %sesscopy ) { push(@debug,"SESS: $key : $sesscopy{$key}"); } }

  my $debug_message = $debug ? join("<br />\n",@debug) : '';

  my $base = $r->hostname =~ /users2?\.macrophile\.com/ ? '/var/www/macrophile.com/users/' : '/var/www/macrophile.com/main/';
  
  open INFILE, '<', $base . $current_page or return Apache2::Const::SERVER_ERROR;
  while ( my $line = <INFILE> ) {
    $line =~ s/<\/body>/<div class="fineprint">$debug_message<\/font><\/body>/ if $debug;
    $line =~ s/<!--\[username\]-->/$sesscopy{username}/g;
    $line =~ s/<!--\[adultimg\]-->.*?<!--\[\/adultimg\]-->/<img width="125" height="150" src="http:\/\/www.macrophile.com\/images\/adult.jpg" \/>/g unless $sesscopy{adult};
    $r->print($line);
  }
  close INFILE;

  return Apache2::Const::OK;
}

1;
