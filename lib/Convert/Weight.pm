package Convert::Weight;

$Convert::Weight::VERSION = '$Revision: 1.2 $';
@Convert::Weight::ISA     = qw(Convert::Measure);

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

  $t->{metric} = [ qw/g kg mton/ ];

  $u->{g}  = [ 'Grams', 1 ];
  $u->{kg} = [ 'Kilograms', 1000 ];
  $u->{mton} = [ 'Metric Tons', 1000000 ];

  $t->{english} = [ qw/oz lb ton/ ];

  $u->{oz} = [ 'Ounces', 28.35 ];
  $u->{lb} = [ 'Pounds', 453.6 ];
  $u->{ton} = [ 'Tons', 907200 ]; # short ton - 2000lbs

  $t->{common} = [ qw/g kg mton oz lb ton/ ];

=item junk  

weight:Clove:3175.2
weight:Dram:1.771875
weight:Dram (Apothecary):3.888
weight:Grain:0.0648
weight:Grain (Troy):0.0486
weight:Hundredweight:50803.2
weight:Libra Mercatoria:466.56
weight:Long Ton:1016064
weight:Megaton:0
weight:Milligram:0.001
weight:Ounce (Troy):31.104
weight:Pennyweight:1.5552
weight:Pound (London):466.56
weight:Pound (Tower):349.92
weight:Pound (London):466.56
weight:Pound (Trade):373.248
weight:Pound (Wool):453.0816
weight:Sack:165110.4
weight:Scruple:1.296
weight:Stone:6350.4
weight:Stone (Butcher's):36741.6
weight:Stone (London):5832
weight:Tod:12700.8

=cut

}

1;
