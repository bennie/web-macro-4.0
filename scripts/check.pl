#!/usr/bin/perl

use Digest::MD5 'md5_hex';
use HTML::Parse;
use LWP::UserAgent;
use URI::URL;
use strict;

my $base = shift @ARGV;

$base .= '/' unless $base =~ /\/$/;

die "You must specify a URL\n" unless $base;
die "The URL should begin with 'http://'\n" unless $base =~ /^http:\/\//;

my $ua = LWP::UserAgent->new;
$ua->agent("Macrophile.com Internal Monitoring/0.1 ");

my @urls = ( $base );
my %done;

for my $url ( @urls ) {
  next if $done{$url};
  print STDERR $url;

  my $req = HTTP::Request->new(GET=>$url);
  my $res = $ua->request($req);

  print STDERR ' ... ', $res->code, "\n";

  next unless $res->is_success;

  $done{$url} = md5_hex($res->content);

  if ( $res->header('Content-Type') =~ m@text/html@ ) {
    my $parse = HTML::Parse::parse_html($res->content);
    for my $link ( @{$parse->extract_links} ) {
      my $uri  = new URI::URL $link->[0];
      my $full = $uri->abs($res->base);
      push @urls, $full if is_local($full);
    }
  }
}

#for my $url ( sort keys %done ) {
#  print "$done{$url} : $url\n";
#}

print scalar(keys %done), " files examined\n";
print 'MASTER HASH : ', md5_hex( sort keys %done ), "\n";

# Subs
  
sub is_local {
  my $url = shift @_;
  return $url =~ /^$base/ ? 1 : 0;
}
