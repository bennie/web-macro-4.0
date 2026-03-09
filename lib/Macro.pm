package Macro;

### The macrophile util module

$Macro::VERSION='$Revision: 1.4 $';

### Module dependencies

use CGI;
use Macro::DB;
use HTML::Template;

use strict;

### Do the self->init thingy

sub new {
  my     $self = {};
  bless  $self;
         $self->_initialize();
  return $self;
}

sub _initialize {
  my $self = shift @_;

  # Shared CGI module
  $self->{'cgi'} = new CGI;

  # Odd config
  $self->{'html_prefix'}  = 'http://www.macrophile.com/';
  $self->{'image_prefix'} = 'http://www.macrophile.com/images/';

  $self->{'start_table'} = "<table border='0' bgcolor='#003300' cellpadding='1' "
                 . "cellspacing='0'>\n<tr><td>\n<table border='0' "
                 . "bgcolor='#FFFFFF' cellpadding='5' cellspacing='0'>\n";
  $self->{'end_table'} = "</table>\n</td></tr>\n</table>\n<img height='1' "
                 . "width='1' vspace='1' src='/images/space.gif'><br>\n";


  # Default info set for templates
  $self->{'tmpl_name'} = 'main-template';
  $self->{'tmpl_base'} = { 
     'title' => 'Default Title',
     'body'  => 'Default Body',
     'time'  => 'default time generation string',
     'image_prefix'  => $self->{'image_prefix'},
     'html_prefix'   => $self->{'html_prefix'},
     'start_table'   => $self->{'start_table'},  
     'end_table'     => $self->{'end_table'}
  };

}

sub _dbh {
  my $self = shift @_;
  unless ( defined $self->{dbh} ) {
    $self->{md} = new Macro::DB;
    $self->{dbh} = $self->{md}->_dbh();
  }
  return $self->{dbh};
}

### Shared Routines:

# Takes time (num of seconds) and converts it to mysql DB format
sub db_time {
  my $self = shift @_;
  my @time = localtime(shift @_);

  my $year  = $self->db_zero_ten( $time[5] + 1900 );
  my $month = $self->db_zero_ten( $time[4] + 1    );
  my $day   = $self->db_zero_ten( $time[3]        );
  my $hour  = $self->db_zero_ten( $time[2]        );
  my $min   = $self->db_zero_ten( $time[1]        );
  my $sec   = $self->db_zero_ten( $time[0]        );

  return "$year-$month-$day $hour:$min:$sec";
}

# Returns a singular number back with a 0 pre appended

sub db_zero_ten {
  my $self = shift @_;
  my $in   = shift @_;
  if ($in < 10) { $in = '0'.$in; }
  return $in
}

# Returns a nice preety box

sub html_box {
  my $self  = shift @_;
  my $text  = shift @_;
  my $width = shift @_;

  my $cgi = $self->{'cgi'};

  if ($width > 10) {
    return $cgi->table({-bgcolor=>'#003300', -cellpadding=>1,
                        -border=>0,          -cellspacing=>0  },
             $cgi->Tr(
               $cgi->td(
                 $cgi->table({-bgcolor=>'#FFFFFF', -cellpadding=>5,
                              -border=>0,          -cellspacing=>0,
                              -width=>$width },
                   $text
                 )
               )
             )
           );
  } else {
    return $cgi->table({-bgcolor=>'#003300', -cellpadding=>1,
                        -border=>0,          -cellspacing=>0  },
             $cgi->Tr(
               $cgi->td(
                 $cgi->table({-bgcolor=>'#FFFFFF', -cellpadding=>5,
                              -border=>0,          -cellspacing=>0  },
                   $text
                 )
               )
             )
           );
  }
}

# Returns the page templted from the main template with the given params

sub html_tmpl {
  my $self = shift @_;
  my %in   = @_;

  # overwrite defaults with input
  my %param = %{ $self->{'tmpl_base'} };
  for my $next_trick (keys %in) {
    $param{$next_trick} = $in{$next_trick};
  }

  my $tmpl = $self->get_raw_text($self->{'tmpl_name'});
  my $meta = HTML::Template->new(
               die_on_bad_params => 0,
               scalarref => \$tmpl
             );
  $meta->param(%param);

  return $meta->output;
}


# Returns a single space

sub html_spacer {
  my $self   = shift @_;
  my $hspace = shift @_ || 1;
  my $vspace = shift @_ || 1;

  return $self->{cgi}->img({
           -height=>1,-width=>1,-hspace=>$hspace,-vspace=>$vspace,
           -src=>$self->{image_prefix}.'space.gif'});
}


# Returns the actual table name read from the config table.

sub get_config { 
  my $self = shift @_;
  my $in   = shift @_;

  my $sql = 'select table_name from config where name = '
          . $self->_dbh()->quote($in);
  my @out = $self->query_row($sql);

  return $out[0];
}

# Returns the appropriate text keyed on the name given

sub get_raw_text {
  my $self = shift @_;
  my $name = shift @_;

  my $raw_text = $self->get_config('raw_text');

  my $sql = "select value from $raw_text where name = "
          . $self->_dbh()->quote($name);
  my @out = $self->query_row($sql);

  return $out[0];
} 

# Returns only one row of a DB query as an array

sub query_row {
  my $self = shift @_;
  my $dbh = $self->_dbh();
  return $self->{md}->row(@_);
}

# Used to update changes to the raw-page parts which are used to assemble 
# the actual page with the template.

sub update_raw_page {
  my $self = shift @_;
  my $name = shift @_;
  my $body = shift @_;

  my $table = $self->get_config('raw_pages');

  my $sql = "update $table set body = "
          . $self->_dbh()->quote($body)
          . ' where name = '
          . $self->_dbh()->quote($name);
  my $sth = $self->_dbh()->prepare($sql);
  my $ret = $sth->execute;

  return $ret;
}

### The required true
return 1;
