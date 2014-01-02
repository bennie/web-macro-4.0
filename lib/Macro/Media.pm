=head1 Macro::Media (Media.pm)

=head1 Summary:

The media archive DB library.

=head1 Usage:

  my $media = new Macro::Media;

=head1 Authorship:

  (c) 2002-2006, Phillip Pollard
  $Revision: 1.9 $ $Date: 2006/08/30 03:00:06 $

=head1 Methods:

=cut

package Macro::Media;
$Macro::Media::VERSION='$Revision: 1.9 $';

### Module dependencies

use Macro;
use strict;

### Do the self->init thingy

sub new {
  my     $self = {};
  bless  $self;

  $self->{formats} = {
    'Movie'       => 'Theatrical Release Movie',
    'Movie Short' => 'Theater Short Feature',
    'Television'  => 'Television Show',

    'Animation'    => 'Traditional 2D animation',
    '3D Animation' => '3D animation',
    
    'Direct Release' => 'Direct to video/DVD, OAV',
    
    'Project'        => 'A student project',
    'Internet'       => 'Internet Release',
    'Unknown'        => 'Unknown Release Format'
  };

  $self->{genres} = {
    'action' => 'Action',
    'comedy' => 'Comedy',
    'adventure' => 'Adventure',
    'fantasy' => 'Fantasy',
    'horror' => 'Horror',
    'thriller' => 'Thriller',
    'Monster' => 'Classic Monster Movie',
    'Sci-fi' => 'Science Fiction',
  };

  $self->{interests} = { # Interest codes and their discriptions
    'Adult' => 'Adult content',
    alien => 'Alien Giant',
    'BE' => 'Breast Enlargement',
    'Clothes Burst' => 'Clothing bursting scene',
    Crush => 'Crush Scene',
    Fat => 'Size by eating',
    FF => 'Female / Female Sexual content',
    Growth => 'Gratuitous Growth Scene',
    Shrink => 'Gratuitous Shrinking Scene',
    Herm => 'Herm conent',
    Hyper => 'Hyperphalia (oversize sexual attributes)',
    Inflation => 'Inflation Scene',
    MF => 'Male / Female Sexual content',
    MM => 'Male / Male Sexual conetne',
    Muscle => 'Muscle growth',
    PE => 'Penis Enlargement',
    Shrink => 'Shrinking scene',
    TG => 'Trans gendered content',
    Animal => 'Animal Giant',
    Dragon => 'Draconic Giant',
    Male => 'Male Giant',
    Female => 'Female Giant',
    Furry => 'Furry content',
    Growing => 'Growth over time',
    Shrinking => 'Shrinking over time',
    'Urban Renewal' => 'Urban Renewal (Destruction)',
    vore => 'Vorareophile Scene (someone eaten)',
    mlittle => 'Male Little Person',
    flittle => 'Female Little Person',
  };
  
  return $self;
}

sub _dbh {
  my $self = shift @_;
  if ( not defined $self->{dbh} ) {
    my $macro = new Macro;
    $self->{dbh} = $macro->_dbh();
  }
  return $self->{dbh};
}

###
### Public Methods
###

=head1 Information Hashes

=head2 attributes

Returns an array or arrayref of unique attribute codes

=cut

sub attributes {
  my $self = shift @_;
  if ( not defined $self->{attributes} ) {
    $self->{attributes} = [];
    my $sth = $self->_dbh()->prepare('select distinct name from media_attributes order by name');
    my $ret = $sth->execute;
    while ( my $ret = $sth->fetchrow_arrayref ) {
      push @{$self->{attributes}}, $ret->[0];
    }
  }
  return wantarray ? @{$self->{attributes}} : $self->{attributes};
}

=head2 formats()

Returns an hashref (or hash) of format codes and their description.

=cut

sub formats {
  my $self = shift @_;
  return wantarray ? %{$self->{formats}} : $self->{formats};
}

=head2 genres()

Returns an hashref (or hash) of genre codes and their description.

=cut

sub genres {
  my $self = shift @_;
  return wantarray ? %{$self->{genres}} : $self->{genres};
}

=head2 interests()

Returns an hashref (or hash) of interest codes and their description.

=cut

sub interests {
  my $self = shift @_;
  return wantarray ? %{$self->{interests}} : $self->{interests};
}

=head1 Interaction Methods

=head2 get($id)

Returns a hash or hashref of a media entry.

=cut

sub get {
  my $self = shift @_;
  my $id   = shift @_;
  
  my $dbh = $self->_dbh();
  
  my $sql = "select * from media where id=$id";
  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute;
 
  my %media = %{ $sth->fetchrow_hashref };
  
  $sth->finish;

  $media{attributes} = $self->get_attributes($id);
  $media{flags}      = $self->get_flags($id);
  $media{images}     = $self->get_images($id);

  return wantarray ? %media : \%media;
}

=head2 get_attributes($id)

Returns a hash or hashref of attributes information for the given media id.

Format is a key of the attribute id and a value of a hash ref of all named record parameters.

=cut

sub get_attributes {
  my $self = shift @_;
  my $id   = shift @_;
  
  my $dbh = $self->_dbh();
  
  my $sql = "select * from media_attributes where media_id=$id";
  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute;

  my %attr;

  while ( my $ref = $sth->fetchrow_hashref ) {
    $attr{$ref->{attribute_id}} = \%$ref;
  }

  $sth->finish;

  return wantarray ? %attr : \%attr;
}

=head2 get_flags($id)

Returns a hash or hashref of flags for the given media id.

Format is a key of the flag name and a value of when it was created.

=cut

sub get_flags {
  my $self = shift @_;
  my $id   = shift @_;
  
  my $dbh = $self->_dbh();
  
  my $sql = "select * from media_flags where media_id=$id";
  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute;

  my %flags;

  while ( my $ref = $sth->fetchrow_hashref ) {
    $flags{$ref->{flag}} = $ref->{created};
  }

  $sth->finish;

  return wantarray ? %flags : \%flags;
}

=head2 get_images($id)

Returns a hash or hashref of image information for the given media id.

Format is a key of the image id and a value of a hash ref of all named record parameters.

=cut

sub get_images {
  my $self = shift @_;
  my $id   = shift @_;
  
  my $dbh = $self->_dbh();
  
  my $sql = "select * from media_images where media_id=$id";
  my $sth = $dbh->prepare($sql);
  my $ret = $sth->execute;

  my %images;

  while ( my $ref = $sth->fetchrow_hashref ) {
    $images{$ref->{image_id}} = \%$ref;
  }

  $sth->finish;

  return wantarray ? %images : \%images;
}

=head2 ids()

Returns an array or arrray ref of all media ids

=cut

sub ids {
  my $self = shift @_;
  if ( not defined $self->{ids} ) {
    my $sql = "select id from media order by id";
    my $sth = $self->_dbh()->prepare($sql);
    my $ret = $sth->execute;

    my @ids;
    while ( my $ref = $sth->fetchrow_arrayref ) { push @ids, $ref->[0] }

    $sth->finish;
    
    $self->{ids} = \@ids;
  }
  return wantarray ? @{ $self->{ids} } : $self->{ids};
}

=head2 flag_add($media_id,$flag)

Adds that flag to the DB and returns the return code.

=cut

sub flag_add {
  my $self     = shift @_;
  my $media_id = shift @_ || return undef;
  my $flag     = shift @_ || return undef;
  
  my $sql = "insert into media_flags (media_id,flag) values (?,?)";
  my $sth = $self->_dbh()->prepare($sql);
  my $ret = $sth->execute($media_id,$flag);
  
  $sth->finish;

  return $ret;
}

=head2 flag_delete($media_id,$flag)

Removes that flag to the DB and returns the return code.

=cut

sub flag_delete {
  my $self     = shift @_;
  my $media_id = shift @_ || return undef;
  my $flag     = shift @_ || return undef;
  
  my $sql = "delete from media_flags where media_id=? and flag=?";
  my $sth = $self->_dbh()->prepare($sql);
  my $ret = $sth->execute($media_id,$flag);
  
  $sth->finish;

  return $ret;
}

1;
