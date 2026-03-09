package Convert::Volume;

$Convert::Volume::VERSION = '$Revision: 1.1 $';
@Convert::Volume::ISA     = qw(Convert::Measure);

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

  $t->{metric} = [ qw/cl l hl kl cm3 dm3 m3 km3/ ];

  $u->{cl}  = [ 'Centiliters'    , 1          ];
  $u->{l}   = [ 'Liters'         , 1000       ];
  $u->{hl}  = [ 'Hectoliters'    , 100000     ];
  $u->{kl}  = [ 'Kiloliters'     , 1000000    ];
  $u->{cm3} = [ 'Centimeters Cu' , 1          ];
  $u->{dm3} = [ 'Decileters Cu'  , 1000       ];
  $u->{m3}  = [ 'Meters Cu'      , 1000000    ];
  $u->{km3} = [ 'Kilometers Cu'  , 1000000000 ];

  $t->{english} = [ qw/floz pt qt gal dpt bsh in3 ft3 yd3/ ];

  $u->{floz} = [ 'Fluid Ounces' , 29.57      ];
  $u->{pt}   = [ 'Pints'        , 473.12     ];
  $u->{qt}   = [ 'Quarts'       , 946.24     ];
  $u->{gal}  = [ 'Gallons'      , 3784.96    ];
  $u->{dpt}  = [ 'Dry Pints'    , 550.6      ];
  $u->{bsh}  = [ 'Bushels'      , 35238.4    ];
  $u->{in3}  = [ 'Cu. Inches'   , 16.387     ];
  $u->{ft3}  = [ 'Cu. Feet'     , 28316.736  ];
  $u->{yd3}  = [ 'Cu. Yards'    , 764551.872 ];

  $t->{common} = [ qw/cl l kl floz pt qt gal ft3/ ];

}

1;
