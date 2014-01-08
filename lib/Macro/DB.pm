package Macro::DB;

$Macro::DB::VERSION='$Revision: 1.5 $';

use DBI;
use strict;

sub new {
  my     $self = {};
  bless  $self;
  return $self;
}

=head2 Private Methods:

=head3 _dbh()

Returns the current database handle.

=cut

sub _dbh {
  my $self = shift @_;
  unless ( defined $self->{dbh} ) {
    my $db_driver = 'mysql';
    my $db_name   = $LocalAuth::WEB_DB;
    my $db_user   = $LocalAuth::WEB_USER;
    my $db_pass   = $LocalAuth::WEB_PASS;
    my @dbconnect = ("dbi:$db_driver:dbname=$db_name", $db_user, $db_pass);
    $self->{dbh} = DBI->connect(@dbconnect) or die "Connecting: $DBI::errstr";
  }
  return $self->{dbh};
}

### Methods:

# Takes time (num of seconds) and converts it to mysql DB format
sub time {
  my $self = shift @_;
  my @time = localtime(shift @_);

  my $year  = $self->_zero_ten( $time[5] + 1900 );
  my $month = $self->_zero_ten( $time[4] + 1    );
  my $day   = $self->_zero_ten( $time[3]        );
  my $hour  = $self->_zero_ten( $time[2]        );
  my $min   = $self->_zero_ten( $time[1]        );
  my $sec   = $self->_zero_ten( $time[0]        );

  return "$year-$month-$day $hour:$min:$sec";
}

# Returns a singular number back with a 0 pre appended

sub _zero_ten {
  my $self = shift @_;
  my $in   = shift @_;
  if ($in < 10) { $in = '0'.$in; }
  return $in
}

sub get_config { 
  my $self = shift @_;
  my $in   = shift @_;

  my $sql = 'select table_name from config where name = '
          . $self->_dbh()->quote($in);
  my @out = $self->query_row($sql);

  return $out[0];
}

sub query_row {
  my $self = shift @_;
  return $self->row(@_);
}

###################

=ite, column()

Given a query, return the first column.

=cut

sub column {
  my $self = shift @_;
  my $sql  = shift @_;

  my $sth = $self->_dbh()->prepare($sql);
  my $ret = $sth->execute;

  my @out;

  while ( my @ret = $sth->fetchrow_array ) {
    push @out, $ret[0];
  }

  $sth->finish;

  return @out;
}

=item do()

Given a query, perform it and return the return code.

=cut

sub do {
  my $self = shift @_;
  return $self->_dbh()->do(@_);
}

=item handle()

Given a query, return a prepared statement handle.

=cut

sub handle {
  my $self = shift @_;
  return $self->_dbh()->prepare(@_);
}

=item quote()

Quotes the given array for SQL usage.

=cut

sub quote {
  my $self = shift @_;
  return $self->_dbh()->quote(@_);
}

=item row()

Return the first row from a query

=cut


sub row {
  my $self = shift @_;
  my $sql  = shift @_;
  
  my $sth = $self->_dbh()->prepare($sql);
  my $ret = $sth->execute(@_);
  
  return wantarray ? $sth->fetchrow_array() : $sth->fetchrow_hashref();
}

=item single

Return the first value from the first row of a query.

=cut

sub single {
  my $self = shift @_;
  return ($self->row(@_))[0];
}

return 1;
