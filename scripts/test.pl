#!/usr/bin/perl

use Convert::Length;
use Term::Query qw/query/;
use strict;

my $conv = new Convert::Length;

$conv->{debug} = query('Debug level?','d',0);
my $inches = query('Height in inches?','d',72);

my $common = $conv->types;
my $lookup = $conv->types_with_names;

print "Autoloader test:\n";
print "$inches inches is ", $conv->in_to_m($inches), " meters.\n";
print "\nStraight test:\n";

for my $type ( @$common ) {
  print "$inches inches is ", $conv->convert('in',$type,$inches), " $lookup->{$type}.\n";
}

