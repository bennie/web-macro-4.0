use Apache::Filter;
use strict;

package Filter;

# Define the handler function

sub handler {
  my $f = shift;
  my $leftover;
  
  while ($f->read(my $buffer, 1024)) {
    $buffer = $leftover . $buffer if defined $leftover;
    $leftover = undef;
    while ($buffer =~ /([^\r\n]*)([\r\n]*)/g) {
      $leftover = $1, last unless $2;
      $f->print($1, $2);
    }
  }
  $f->print($leftover) if defined $leftover;
  return 'OK';
}

1;
