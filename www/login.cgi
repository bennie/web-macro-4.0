#!/usr/bin/perl -I/var/www/macrophile.com/lib

use Authen::Passphrase::PHPass;
use CGI;
use CGI::Carp qw/fatalsToBrowser/;
use Data::Dumper;
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

### Prep the DBs

my @webdb = ('dbi:mysql:dbname='.$LocalAuth::WEB_DB, $LocalAuth::WEB_USER, $LocalAuth::WEB_PASS);

### Print a page

my $error; # Report any login check errors
my $match; # Set true if the authen check work
my $redirect; # Go back to where we were told

### Check password if submitted

if ( $cgi->param('username') and $cgi->param('password') ) {

  $debug .= $cgi->p('Checking password out of phpBB');
  my $crypt = check_password($cgi->param('username'));
  $crypt =~ s/H/P/;
  $debug .= $cgi->p($cgi->b('crypt:'),$crypt);

  if ( $crypt ) {
    my $ppr = Authen::Passphrase::PHPass->from_crypt($crypt);
    $match = $ppr->match($cgi->param('password'));
    $error = 'Incorrect password.'
  } else {
    $error = 'User does not exist.'
  }

  $debug .= $cgi->p($cgi->b('match:'),$match);
}  

### If authentication was good, redirect!

if ( $match ) {
  my $location = 'http://new.macrophile.com' . $cgi->param('redirect');
  print $cgi->redirect($location);
}

### Otherwise, login

my $body = ( $error ? $cgi->i($error) : '' )
      . $cgi->start_form
      . ( $cgi->param('redirect') ? $cgi->hidden('redirect',$cgi->param('redirect')) : '' )
      . $cgi->textfield('username')
      . $cgi->password_field('password')
      . $cgi->submit
      . $cgi->end_form;

### Print out the page from $body

print $cgi->header();

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

sub check_password {
  my $usr = shift @_;
  my $dbh = DBI->connect('dbi:mysql:dbname='.$LocalAuth::FORUM_DB, $LocalAuth::FORUM_USER, $LocalAuth::FORUM_PASS)
              or die "DB Connect Error: $DBI::errstr";  
  my $sth = $dbh->prepare('select user_password from phpbb3_users where username=?');
  my $ret = $sth->execute($usr);
  my $ref = $sth->fetchrow_arrayref;
  return $ref ? $ref->[0] : undef;
}