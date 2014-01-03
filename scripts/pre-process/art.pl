#!/usr/bin/perl -w -I/var/www/macrophile.com/lib

# This page generates the art page from info in the DB.
# (c) 2006, Phillip Pollard <bennie@macrophile.com>

use Image::Size;
use Macro;
use Macro::Forum;
use String::ShellQuote;
use strict;

### Conf

my $debug = 0;

my $name      = 'art';
my $sourcedir = '/home/httpd/html/macrophile.com/forums/files';
my $thumbdir  = '/home/httpd/html/macrophile.com/main/images/preview';
my $htmldir   = '/images/preview';

my @rows = ('row1', 'row2'); # Alternated row styles

my $num_thumbnails = 16; # Number of thumbnails for each forum;

my @forums = qw/3 8/;
my %forums = (
  3 => 'Macro Art',
  8 => 'Macro Art (Adult)',
);


### Main

my $macro = new Macro;
my $cgi = $macro->{cgi};

my $mf = new Macro::Forum;

### Sort out the thumbnails

print 'PRE: phpbb_attachments';

my %attach;
$attach{'Macro Art'} = $mf->recent_attachments({ forum => 3, limit => 16 });
$attach{'Macro Art (Adult)'} = $mf->recent_attachments({ forum => 8, limit => 16 });

### Build the page

my $body = "<table class=\"innertable\" cellspacing=\"0\" cellpadding=\"3\">\n<tr><td colspan=\"4\" class=\"innertablehead\">Art</td></tr>\n\n";

###

print "--> raw_pages table ";

my @table;
my @row1;
my @row2;
my $count = 1;

for my $forum ( @forums ) {
  my $attach = $mf->recent_attachments({ forum => $forum, limit => $num_thumbnails });
  for my $key ( sort { $a <=> $b } keys %$attach ) {
    my ( $image, $desc ) = $mf->attachment_html($attach->{$key});

    my $class = $rows[0];
    $class .= ' br' if $count < 4;
    push @row1, $cgi->td({-class=>$class,-align=>'center',-valign=>'top',-width=>155},$image);
    push @row2, $cgi->td({-class=>$class,-align=>'center',-valign=>'top',-width=>155},$desc);

    if ( $count++ == 4 ) {
      push @table, $cgi->Tr(@row1);
      push @table, $cgi->Tr(@row2);
      $count = 1;
      @row1 = ();
      @row2 = ();
      push @rows, shift @rows;
    }
  }
  $body .= "<tr><td class=\"innertablesubhead\" colspan=\"4\">Recent Forum Uploads - $forums{$forum}</td></tr>\n"
        .  join('',@table)
        .  "\n\n";
  @table = ();
}

$body .= "</td></tr></table>\n";

### Generate the page

my $ret = $macro->update_raw_page($name,$body);

print "--> done! (return $ret)\n";


### Subs

sub debug {
  if ( $debug ) {
    for my $line (@_) {
      chomp $line;
      print "DEBUG: $line\n";
    }
  }
}

sub files {
  opendir INDIR, $_[0] || die "Can't open directory: $_[0]";
  my @files = grep !/^..?$/, readdir INDIR;
  closedir INDIR;
  return @files;
}
