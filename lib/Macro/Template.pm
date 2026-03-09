package Macro::Template;
$Macro::Template::VERSION='1.0.3 (4/28/2001)';

use HTML::Template;
use Macro::DB;
use strict;
use warnings;

sub new {
  my ($class, $arg) = @_;
  my $self = {};
  bless $self, $class;

  my %opt;
  if (ref $arg eq 'HASH') {
    %opt = %{$arg};
  } elsif (ref $arg) {
    $self->{db} = $arg;
  }

  $self->{db} ||= new Macro::DB;
  $self->{template_file} = $opt{template_file} if $opt{template_file};

  # Odd config
  $self->{'html_prefix'}  = defined $opt{html_prefix}  ? $opt{html_prefix}  : 'http://www.macrophile.com/';
  $self->{'image_prefix'} = defined $opt{image_prefix} ? $opt{image_prefix} : 'http://www.macrophile.com/images/';

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
     'year'  => (( localtime )[5] + 1900 ),
     'image_prefix'  => $self->{'image_prefix'},
     'html_prefix'   => $self->{'html_prefix'},
     'start_table'   => $self->{'start_table'},  
     'end_table'     => $self->{'end_table'}
  };

  return $self;
}

sub do {
  my $self = shift @_;
  my %in = $_[0] ? %{ shift @_ } : ();

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

sub get_raw_text {
  my $self = shift @_;
  my $name = shift @_;

  if ($self->{template_file}) {
    local $/;
    open my $fh, '<', $self->{template_file}
      or die "Unable to open template file $self->{template_file}: $!";
    my $raw = <$fh>;
    close $fh;
    return $raw;
  }

  my $raw_text = $self->{db}->get_config('raw_text');

  my $sql = "select value from $raw_text where name = "
          . $self->{db}->quote($name);
  return $self->{db}->single($sql);
}

1;
