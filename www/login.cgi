#!/usr/bin/perl -I/var/www/macrophile.com/lib

use Authen::Passphrase::PHPass;
use CGI;
use CGI::Carp qw/fatalsToBrowser/;
use Data::Dumper;
use Data::UUID;
use HTML::Template;
use LocalAuth;
use Macro;
use strict;

# +---------------+-------------+------+-----+-------------------+-------+
# | Field         | Type        | Null | Key | Default           | Extra |
# +---------------+-------------+------+-----+-------------------+-------+
# | username      | varchar(50) | NO   | PRI | NULL              |       | 
# | session_id    | varchar(50) | NO   |     | NULL              |       | 
# | expire        | varchar(20) | NO   |     | NULL              |       | 
# | last_modified | timestamp   | NO   |     | CURRENT_TIMESTAMP |       | 
# +---------------+-------------+------+-----+-------------------+-------+

my $cgi = new CGI;
my $session = $cgi->cookie('macrophile.com');

my $user = 'unknown';

### Debug the input

my $debug = Dumper($session);

for my $param ( $cgi->param ) {
  $debug .= $param .' : '. $cgi->param($param)."</ br>\n";
}

### Default vars

my $username = $cgi->param('username');
my $password = $cgi->param('password');
my $redirect = $cgi->param('redirect');

my $cookie; # Session cookie to write
my $crypt; # Password crypt if pulled from DB
my $error; # Report any login check errors
my $match; # Set true if the authen check work

### Check password if submitted

if ( $username and $password ) {
  $debug .= $cgi->p('Checking password against phpBB');
  $crypt = get_password_hash($username);
  $crypt =~ s/H/P/;
  $debug .= $cgi->p($cgi->b('crypt:'),$crypt);
}

if ( $crypt ) {
  my $ppr = Authen::Passphrase::PHPass->from_crypt($crypt);
  $match = $ppr->match($password);
  $error = 'Incorrect password.' unless $match;
} else {
  $error = 'User does not exist.' if $username;
}
  
$debug .= $cgi->p($cgi->b('match:'),$match);

### Create session if a good login

if ( $match ) {
  my $ug   = new Data::UUID;
  my $uuid = $ug->create_str();

  my $expire = time + ( 60 * 3600 );

  my $dbh = DBI->connect('dbi:mysql:dbname='.$LocalAuth::WEB_DB, $LocalAuth::WEB_USER, $LocalAuth::WEB_PASS)
              or die "DB Connect Error: $DBI::errstr";  
  my $sth = $dbh->prepare('select count(*) from sessions where username=?');
  my $ret = $sth->execute($username);
  my $count = $sth->fetchrow_arrayref->[0];
  
  if ( $count ) {
    $sth = $dbh->prepare('update sessions set session_id=?, expire=? where username=?');
  } else {
    $sth = $dbh->prepare('insert into sessions (session_id,expire,username) values (?,?,?)');
  }
  my $ret = $sth->execute($uuid,$expire,$username);

  $error = "Session insert returned: $ret" unless $ret = 1;
  
  $cookie = $cgi->cookie(-name=>'new_macro_session', -value=> $uuid, -expires=>'+1y', -domain=>'macrophile.com' );
}

### If authentication was good, redirect!

if ( $match and not $error ) {
  my $location = 'http://new.macrophile.com' . $cgi->param('redirect');
  print $cgi->redirect( -uri=> $location, -cookie=> $cookie );
}

### Otherwise, login

my $body = ( $error ? $cgi->p($cgi->i($error)) : '' )
      . $cgi->start_form
      . ( $cgi->param('redirect') ? $cgi->hidden('redirect',$cgi->param('redirect')) : '' )
      . $cgi->table(
          $cgi->Tr($cgi->td('Username:'),$cgi->td($cgi->textfield('username'))),
          $cgi->Tr($cgi->td('Password:'),$cgi->td($cgi->password_field('password')))
        )
      . $cgi->submit
      . $cgi->end_form;

### Print out the page from $body

print $cookie ? $cgi->header(-cookie=>$cookie) : $cgi->header();

my $macro = new Macro;
my $tmpl  = $macro->get_raw_text('main-template-css');
my $page  = HTML::Template->new( die_on_bad_params => 0, scalarref => \$tmpl );

$page->param(
  title => "Login",
  body  => $body,

  time  => scalar localtime,
  year  => ((localtime)[5]+1900),

  user  => $user,
  debug => $cgi->pre($debug),
);

print $page->output;

### Subroutines

sub get_password_hash {
  my $usr = shift @_;
  my $dbh = DBI->connect('dbi:mysql:dbname='.$LocalAuth::FORUM_DB, $LocalAuth::FORUM_USER, $LocalAuth::FORUM_PASS)
              or die "DB Connect Error: $DBI::errstr";  
  my $sth = $dbh->prepare('select user_password from phpbb3_users where username=?');
  my $ret = $sth->execute($usr);
  my $ref = $sth->fetchrow_arrayref;
  return $ref ? $ref->[0] : undef;
}

sub create_session {
}