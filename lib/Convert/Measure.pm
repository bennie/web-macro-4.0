#!/usr/bin/perl

#http://home.clara.net/brianp/

package Convert::Measure;
$Convert::Measure::VERSION = '0.01';

use strict;

### Main

sub _debug {
  my $self = shift @_;
  return 0 unless $self->{debug} > 0;
  print STDERR 'DEBUG: ', @_, "\n";
  return 1;
}

sub _get_name {
  my $self = shift @_;
  my $unit = shift @_;
  if ( $self->{units}->{$unit} ) {
    $self->_debug("Got value $self->{units}->{$unit}->[0] for '$unit'");
    return $self->{units}->{$unit}->[0];
  }
  warn "No such unit: '$unit'";
  return undef;
}

sub _get_val {
  my $self = shift @_;
  my $unit = shift @_;
  if ( $self->{units}->{$unit} ) {
    $self->_debug("Got value $self->{units}->{$unit}->[1] for '$unit'");
    return $self->{units}->{$unit}->[1];
  }
  warn "No such unit: '$unit'";
  return undef;
}

=item convert()

Convert from one value to another.

  my $feet = $c->convert('in','ft',$inches);

=cut

sub convert {
  my $self     = shift @_;
  my $type_in  = shift @_;
  my $type_out = shift @_;
  my $value    = shift @_;

  return undef unless $type_in and $type_out; # no type
  return $value if $type_in eq $type_out;     # same type

  my $in  = $self->_get_val($type_in); 
  my $out = $self->_get_val($type_out);

  return undef unless $in and $out;

  $self->_debug("Converting: ( $value * $in ) / $out ");
  return ( $value * $in ) / $out;
}

=item types()

List types:

  my @metric = @{ $c->types('metric') };

=cut

sub types {
  my $self = shift @_;
  my $category = shift @_ || 'common';
  return $self->{types}->{$category} if $self->{types}->{$category};
  warn "No such type category: '$category'";
  return [ ];
}

=items types_with_names()

Return a hashref of all of the types and their full name.

=cut

sub types_with_names {
  my $self = shift @_;
  my $types = $self->types(@_);  
  my $out = {};
  map { $out->{$_} = $self->_get_name($_) } @$types;
  return $out;
}

sub AUTOLOAD {
  my $self = shift @_;
  my $name = our $AUTOLOAD;
     $name =~ /.*::(.*?)$/; 
     $name = $1;

  if ( $name =~ /^(\w+)_to_(\w+)$/ ) {
    $self->_debug("Call for $name means convert from $1 to $2");
    return $self->convert($1,$2,shift @_);
  }

  die "Call for nonexistant method: $AUTOLOAD";
}

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
