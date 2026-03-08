package Convert::Area;

$Convert::Area::VERSION = '0.01';
@Convert::Area::ISA     = qw(Convert::Measure);

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
  my $u = $self->{units} = {};
  my $t = $self->{types} = {};

  $t->{metric} = [ qw/cm2 m2 hct km2/ ];

  $u->{cm2} = [ 'Centimeter Sq' , 1           ];
  $u->{hct} = [ 'Hectare'       , 100000000   ];
  $u->{m2}  = [ 'Meters Sq'     , 10000       ];
  $u->{km2} = [ 'Kilometers Sq' , 10000000000 ];

  $t->{english} = [ qw/in2 ft2 yd2 acre mile2/ ];

  $u->{in2}   = [ 'Inches Sq' , 6.4516       ];
  $u->{ft2}   = [ 'Feet Sq'   , 929.0304     ];
  $u->{yd2}   = [ 'Yards Sq'  , 8361.2736    ];
  $u->{acre}  = [ 'Acre'      , 40468564.224 ];
  $u->{mile2} = [ 'Mile Sq'   , 25899881103  ];

  $t->{common} = [ qw/ft2 in2 acre mile2 cm2 m2 km2/ ];

#area:Rood:10117141.056

}

1;
