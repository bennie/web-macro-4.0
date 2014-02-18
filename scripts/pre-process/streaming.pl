#!/usr/bin/perl -w -I/var/www/macrophile.com/lib

# This script scans streaming sites to see what is up and generates the
# streaming page in the DB

# (c) Phillip Pollard <bennie@macrophile.com>

### CONFIG

my $debug = 1;

my $out_name    = 'streaming';

### PROGRAM

use Data::Dumper;
use LWP::Simple;
use Macro;
use strict;

my $macro = new Macro;

# Parse debug

for my $arg (@ARGV) {
  $debug = $1 if $arg =~ /--debug=(.+)/i;
}

### Grab the info

my %sites = (
  'Cougr' => 'http://tv.pumapaw.com/',
  'Beherit' => 'http://beherit.tv.macrophile.com/',
  'Matelk' => 'https://furstre.am/stream/matelk',
  'Tyrnn' => 'http://www.tigerdile.com/stream/tyrnn/?accept_given=1',
  'Wolf' => 'http://wolf.tv.macrophile.com/'
);

my %status;

for my $key ( sort keys %sites ) {
  print "Checking $key : $sites{$key}\n";
  my $page = get($sites{$key});
  print " * Downloaded ".length($page)." bytes.\n";
  my $rtmp = parse_rtmp($page);
  print " * Found the streaming URI: $rtmp\n";
  my ( $ret, $data ) = check_rtmp($rtmp);
  print " * Returned $ret (0 is up, 1 is down, 2 is timeout)\n\n";
  #print $data;
  $status{$key} = $ret == 0 ? 'UP' : 'DOWN';
}

### Generate the page

my $cgi = $macro->{cgi};
my $dbh = $macro->_dbh();

print "\nPRE: streaming sites " if $debug;

# Assemble the file

print "--> raw_pages table " if $debug;

my $body;

for my $key ( sort keys %sites ) {
  $body .= $cgi->p($key,'is',$status{$key},$cgi->a({-href=>$sites{$key}},$sites{$key}));
}

# Store the output

my $ret = $macro->update_raw_page($out_name,$body);

print "--> done! (return $ret)\n" if $debug;

### Subroutines

sub check_rtmp {
  my $uri = shift @_;
  my ( $exit_value, $data );
  eval {
    local $SIG{ALRM} = sub { die "alarm\n" };
    alarm 20;

	my $command = "ffmpeg -i $uri -acodec copy -vcodec copy -y -t 0 /tmp/delete.flv 2>&1";
    print " * $command\n";
    $data = `$command`;

    $exit_value = $? >> 8;
  };
  if ($@) {
    die $@ unless $@ eq "alarm\n"; # Propagate non-alarm errors.
    # We timed out - so it must be down?
    return ( 2, undef ); 
  }  
  # Exit value is shell: 0 is success, 1 is fail
  return $exit_value, $data;
}

# ./rtmpdump --live -r rtmp://stream.tigerdile.com/live/drake-tigerclaw -o /dev/null --stop 2

sub parse_rtmp {
  return $1 if $_[0] =~ /(rtmp\:\/\/[\-\_\.a-z0-9\/]+)/i;
}
