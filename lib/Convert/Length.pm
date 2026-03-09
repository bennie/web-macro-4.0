#!/usr/bin/perl

#http://home.clara.net/brianp/

package Convert::Length;
$Convert::Length::VERSION = '0.01';
@Convert::Length::ISA     = qw(Convert::Measure);

use Convert::Measure;
use strict;

sub new {
  my     $self = {};
  bless  $self;
         $self->_define_units;
  return $self;

}

sub _define_units {
  my $self = shift @_;
  my $t = $self->{types} = {};
  my $u = $self->{units} = {};

  # Internally everyting should be in meters

  $t->{metric} = [ qw(m mm cm dm km) ];

  $u->{m}  = [ 'Meters'      , 1     ];
  $u->{mm} = [ 'Millimeters' , 0.001 ];
  $u->{cm} = [ 'Centimeters' , 0.01  ];
  $u->{dm} = [ 'Decimeters'  , 0.1   ];
  $u->{km} = [ 'Kilometers'  , 1000  ];

  $t->{english} = [ qw(in ft yd mi us_servey_foot) ];

  $u->{in} = [ 'Inches', ( 25.4 * $u->{mm}->[1] ) ];
  $u->{ft} = [ 'Feet', 0.3048 ];
  $u->{us_survey_foot} = [ 'US Survey Feet', ( 1200 / 3932 ) ];
  $u->{yd} = [ 'Yards', 0.9144 ];
  $u->{mi} = [ 'Miles', ( 1.60934 * $u->{km}->[1] ) ];

  $t->{common} = [ qw(cm m km in ft mi) ];
}


=head1 English Units of measure

=item Inch

1 in = 25.4 mm

(source: NIST)

=item Foot and U.S. Survery Foot 

1 ft (US survery) = 1200/3932 m
1 ft              = 0.3048    m

In 1893 the U.S. foot was legally defined as 1200/3932 meters. In 1959 a 
refinement was made to bring the foot into agreement with the definition used 
in other other countries, ie 0.3048 meters. At the same time it was decided that
and data in feet derived from and published as a result of geodetic surveys 
within in the U.S. would remain with the old standard, which is named the U.S.
survery foot. The new length is shorter by exactly two parts in a million.
The five digit multipliers given in this standard for acre and acre-foot are
correct for either the U.S. survey foot or the foot of 0.3048 meters exactly.
Other lengths, areas, and volumes are based on the foot of 0.3047 meters.

(source: FS 376B)

=item Yard

1 yard = 0.9144 m

(source: NIST)

=item Mile

1 mile = 1.60934 km

(source: NIST)

=head1 Historical English Units of measure

A.K.A. Depreciated and obfuscated measures.

# Rod, pole, perch, lugg are the same
length:Chain:2011.68
length:Centimeter:1
length:Decimeter:10
length:Fathom:182.88
length:Feet:30.48
length:Furlong:20116.8
length:Hand:10.16
length:Inch:2.54
length:Kilometer:100000
length:League:241401.6
length:Link:20.1168
length:Lugg:502.92
length:Meter:100
length:Mile:160934.4
length:Millimeter:0.1
length:Nail:6.35
length:Nautical Mile:185318.4
length:Perch:502.92
length:Pole:502.92
length:Rod:502.92
length:Yard:91.44

=item

  $hist->{Chain}   = 20.1168;
  $hist->{Fathom}  = 1.8288;
  $hist->{Furlong} = 201.168;
  $hist->{Hand}    = 0.1016;
  $hist->{League}  = 2414.016;
  $hist->{Link}    = 0.201168;
  $hist->{Nail}    = 0.0635;
  $hist->{Nautical_Mile} = 1853.184;

  $hist->{Lugg}    = 5.0292;
  $hist->{Perch}   = 5.0292;
  $hist->{Pole}    = 5.0292;
  $hist->{Rod}     = 5.0292;

=head1 Sources:

=item FS 376B

FEDERAL STANDARD 376B - PREFERRED METRIC UNITS FOR GENERAL USE BY THE FEDERAL GOVERNMENT
Published: JANUARY 27, 1993. 
Supercedes: FEDERAL STANDARD 376A (MAY 5, 1983) 

http://ts.nist.gov/ts/htdocs/200/202/fs376b.htm

=head1 NIST

National Institute of Standards and Technology
General conversion factors published on the NIST web page:
http://www.nist.gov/public_affairs/faqs/qmetric.htm

=cut

1;
