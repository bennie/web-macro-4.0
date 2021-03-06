#!/usr/bin/perl -I /var/www/macrophile.com/lib
# (c) ????-2014 Phillip Pollard, <bennie@macrophile.com>

my $quiet = 0;
my $skip_non_html = 1;

# Parse args

for my $arg (@ARGV) {
  $quiet = 1 if $arg eq '--quiet';
}

use Digest::MD5 'md5_hex';
use HTML::Parse;
use LWP::UserAgent;
use Macro::DB;
use URI::URL;
use strict;

my $ua = LWP::UserAgent->new;
$ua->agent("Macrophile.com Internal Monitoring/0.1 ");

my $db    = new Macro::DB;
my $users = $db->get_config('users');

my @users = $db->column("select username from $users");

for my $user ( @users ) {
  print STDERR sprintf '%12.12s', "$user:" unless $quiet;
  my ($count,$hash) = &scan_url("http://localhost/~$user");
  print STDERR "  $hash : ", sprintf('%6.6s',$count), " : " unless $quiet;
  my $sql = "update $users set hash='$hash', num_files='$count' where username='$user'";
  my $ret = $db->do($sql);
  print STDERR $ret unless $quiet;

  if ( $ret == 1 ) {
    my $ret = $db->do("update $users set modified = now() where username='$user'");
    print STDERR " update!" unless $quiet;
  }

  print STDERR "\n" unless $quiet;
}

# subs

sub scan_url {
  my $base = shift @_;
  $base .= '/' unless $base =~ /\/$/;

  my @urls = ( $base );
  my %done = ();

  for my $url ( @urls ) {
    if ( $done{$url} ) {
      &debug("SKIP (seen it) $url");
      next;
    }

    &debug("Checking: $url");

    my $req = HTTP::Request->new(GET=>$url);
    my $res = $ua->request($req);

    if ( $res->header('Content-Type') =~ m@text/html@ ) {
      
      $done{$url} = md5_hex($res->content); # Hash the HTML

      my $parse = HTML::Parse::parse_html($res->content);
      for my $link ( @{$parse->extract_links} ) {
        my $uri  = new URI::URL $link->[0];
        my $full = $uri->abs($res->base);
        $full =~ s/www.macrophile.com/localhost/;

        next unless is_local($base,$full);

        if ( $full =~ /\.html?$/i or $full =~ /\/$/ or $full =~ /gallery\.cgi$/ ) {
          &debug("GOOD! $full");
          push @urls, $full;
        } else {
          if ( $skip_non_html ) {
            &debug("SKIP (not HTML) $full");
            $done{$full} = 1;
          } else {
            &debug("GOOD! (non HTML) $full");
            push @urls, $full;
          }
        }
      }
    } else {
      $done{$url} = $res->code; # Result code for non-HTML
    }
  }

  &debug("Building Key:\n", join("\n",( map {$_.':'.$done{$_}} sort keys %done )));
  return scalar(keys %done), md5_hex( map {$_.':'.$done{$_}} sort keys %done );
}
  
sub debug {
  print 'DEBUG: ', @_, "\n" unless $quiet;
}

sub is_local {
  my $base = shift @_;
  my $url  = shift @_;
  &debug("COMPARE $base and $url");
  return $url =~ /^$base/ ? 1 : 0;
}
