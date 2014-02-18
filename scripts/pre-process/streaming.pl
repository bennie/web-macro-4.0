#!/usr/bin/perl -w -I/var/www/macrophile.com/lib

# This script scans streaming sites to see what is up and generates the
# streaming page in the DB

# (c) Phillip Pollard <bennie@macrophile.com>

### CONFIG

my $debug = 1;

my $out_name = 'streaming';
my $timeout = 10;

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
  'Beherit' => 'http://beherit.tv.macrophile.com/',
  'Cougr'   => 'http://tv.pumapaw.com/',
  'Matelk'  => 'https://furstre.am/stream/matelk',
  'Robomax' => 'http://www.livestream.com/robomax',
  'Tyrnn'   => 'http://www.tigerdile.com/stream/tyrnn/?accept_given=1',
  'Wolf'    => 'http://wolf.tv.macrophile.com/'
);

$sites{test} = 'http://www.tigerdile.com/stream/blackears/?accept_given=1';

my %status;

for my $key ( sort keys %sites ) {
  print "Checking $key : $sites{$key}\n";
  my $page = get($sites{$key});
  print " * Downloaded ".length($page)." bytes.\n";
  my $rtmp = parse_rtmp($page);
  print " * Found the streaming URI: $rtmp\n";
  my $ret = check_rtmp($rtmp);
  print " * Returned $ret bytes of stream data\n\n";
  #print $data;
  $status{$key} = $ret > 0 ? 'UP' : 'DOWN';
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

  unlink('/tmp/delete.flv') if -f '/tmp/delete.flv';

  my $command = $uri =~ /tigerdile/i
              ? "rtmpdump --live -r $uri -o /tmp/delete.flv --timeout $timeout 2>&1 & sleep $timeout ; kill \$!"
              : "ffmpeg -i $uri -acodec copy -vcodec copy -y -t $timeout /tmp/delete.flv 2>&1 & sleep $timeout ; kill \$!";

  print " * $command\n";
  $data = `$command`;

  return 0 unless -f '/tmp/delete.flv';
  
  my @stat = stat '/tmp/delete.flv';
  return $stat[7];
}

sub parse_rtmp {
  return $1 if $_[0] =~ /(rtmp\:\/\/[\-\_\.a-z0-9\/]+)/i;
}
