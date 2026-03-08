#!/usr/bin/perl -w -I/var/www/macrophile.com/lib

# Macrophile.com front page CGI
# (c) 2001-2014, Phillip Pollard <bennoe@macrophile.com>

### Config

my $out_name = 'index';

my $quiet = 0;

# Parse args

for my $arg (@ARGV) {
  $quiet = 1 if $arg eq '--quiet';
}

### Pre-process

use Macro;
use Macro::Forum;
use strict;

my $mf = new Macro::Forum;

my $macro = new Macro;
my $cgi   = $macro->{cgi};
my $dbh   = $macro->_dbh();

my $ftp        = $macro->get_config('ftp');
my $users      = $macro->get_config('users');
my $users_data = $macro->get_config('users_data');

### Program

# Grab user-new info for the body

print "PRE: $users & $users_data tables " unless $quiet;

my $user_new_text;

my $sql = "select a.username, b.name, a.modified from $users a, $users_data b "
        . 'where a.username = b.username and a.modified > date_add(curdate(),interval -7 day) '
        . 'order by a.modified desc, b.name';
my $sth = $dbh->prepare($sql);
my $ret = $sth->execute;

if ($ret > 0) {
  while (my @ret = $sth->fetchrow_array) {
    $ret[2] =~ /^\d{4}-(\d\d)-(\d\d)/;
    my $date = "($1/$2)";
    $user_new_text .= join('&nbsp;',
                        $date,
                        $cgi->a({-href=>'http://'.$ret[0].'.macrophile.com/'},$ret[1])
                      ).$cgi->br;
  }
  $user_new_text = $cgi->Tr($cgi->td({-bgcolor=>'#003300'},$cgi->font({-color=>'#FFFFFF',-face=>'Arial',-size=>1},'Recently updated subdomains:')))
                 . $cgi->Tr($cgi->td({-bgcolor=>'#FFFFFF'},$cgi->font({-face=>'Arial',-size=>1},$user_new_text)));
} else {
  $user_new_text = $cgi->Tr($cgi->td({-bgcolor=>'#003300'},$cgi->font({-color=>'#FFFFFF',-face=>'Arial',-size=>1},'Recently updated subdomains:')))
                 . $cgi->Tr($cgi->td({-bgcolor=>'#FFFFFF'},$cgi->font({-face=>'Arial',-size=>1},'Sorry. Nothing new.')));
}

$ret = $sth->finish;

# Grab recent FTP

print "--> $ftp " unless $quiet;

my $ftp_new_text;

my $lastweek = $macro->db_time(time - (60 * 60 * 24 * 7));

$sql = "select file,href from $ftp where mtime > '$lastweek' and file not like '%.tar.gz' order by mtime desc";
$sth = $dbh->prepare($sql);
$ret = $sth->execute;

if ($ret > 0) {
  my $count = 1;
  while (my ($file, $href) = $sth->fetchrow_array) {
    $ftp_new_text .= $cgi->li($cgi->a({-href=>$href},$file));
    if ($count == 25) { last; } else { $count++ };
  }

  $ftp_new_text = $cgi->Tr($cgi->td({-bgcolor=>'#003300'},$cgi->font({-color=>'#FFFFFF',-face=>'Arial',-size=>1},'Recently loaded FTP files:')))
                . $cgi->Tr($cgi->td({-bgcolor=>'#FFFFFF'},$cgi->ul($ftp_new_text)));

} else {

  $ftp_new_text = $cgi->Tr($cgi->td({-bgcolor=>'#003300'},$cgi->font({-color=>'#FFFFFF',-face=>'Arial',-size=>1},'Recently loaded FTP files:')))
                . $cgi->Tr($cgi->td({-bgcolor=>'#FFFFFF'},'Sorry. Nothing new.'));

}

$ret = $sth->finish;

# Table

my @table;

my $attach = $mf->recent_attachments({ forums => [3,8], limit => 8 });
my @rows = ('row1', 'row2'); # Alternated row styles

my @row1;
my @row2;
my $count = 1;

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

my $recent = $cgi->table({ class=>"innertable", cellspacing=>0, cellpadding=>3 },
               "<tr><td class=\"innertablehead\" colspan=\"4\">Recent Art Uploads</td></tr>",
               @table
             );

# build the body

print "--> raw_pages table " unless $quiet;

my $body = $cgi->table({-width=>775},
             $cgi->Tr({-valign=>'top'},
               $cgi->td({-wdith=>600},

                 $macro->{'start_table'},
                 $cgi->Tr($cgi->td({-bgcolor=>'#003300'},$cgi->font({-size=>4,-face=>"Arial",-color=>'#FFFFFF'},'What\'s new?'))),
                 $cgi->Tr(
                   $cgi->td({-bgcolor=>'#FFFFFF'},

                     $cgi->p('Holy crap! An actual front page update?'),
                     $cgi->p('The most obvious change is the preview below of recently uploaded files. This goes along with the <a href="/html/art.html">art preview page</a> that you get to by clicking the art link to the left. It updates through the day with the latest posts.'),
                     $cgi->p('The older tilde style unix accounts have been moved over to their own sub domains. For exampole, Duncan\'s website used to be at http://www.macrophile.com/~duncanroo, but now it is at <a href="http://duncanroo.macrophile.com">http://duncanroo.macrophile.com</a>. There are redirects in place to keep all the old bookmarks working.'),
                     $cgi->p('The reason for the move is I am slowly in the process of creating accounts for every user on the discussion board. In the art previews below you can click on the author names to view the placeholder pages. For example, Xilimyth now has a web page at: <a href="http://users.macrophile.com/Xilimyth/">http://users.macrophile.com/Xilimyth/</a> Look for improvement and more and more customizations for the end users.'),
                     $cgi->p('That\'s all for now. Enjoy the bigness.')
                     
                   )
                 ),
                 $macro->{'end_table'},

                 $cgi->img({-height=>1,-width=>1,-hspace=>300,-src=>'/images/space.gif'}),

                 $recent,
                 
               ),
               $cgi->td({-align=>'right'},

                 $macro->html_box($user_new_text,175),
                 $cgi->img({-height=>1,-width=>1,-src=>'/images/space.gif'}),
                 $macro->html_box($ftp_new_text,175),
                 $cgi->img({-height=>1,-width=>1,-src=>'/images/space.gif'}),
                 $macro->html_box(
                   $cgi->Tr(
                     $cgi->td({-bgcolor=>'#003300'},
                       $cgi->font({-color=>'#FFFFFF',-face=>'Arial',-size=>1},
                         'One shots:'
                       )
                     )
                   )
                 . $cgi->Tr(
                     $cgi->td({-bgcolor=>'#FFFFFF'},
                       $cgi->ul(
                         $cgi->li(
                           $cgi->a({-href=>'http://forums.macrophile.com/'},'bb')
                         ),
                         $cgi->li(
                           $cgi->a({-href=>'/html/changes.html'},'change log')
                         ),
                         $cgi->li(
                           $cgi->a({-href=>'/ftp/cache'},'ftp')
                         ),
                         $cgi->li(
                           $cgi->a({-href=>'/html/legal.html'},'legal')
                         ),
                         $cgi->li(
                           $cgi->a({-href=>'/html/stats.html'},'stats')
                         )
                       )
                     )
                   ),
                   175
                 ),
                 $cgi->img({-height=>1,-width=>1,-src=>'/images/space.gif'}),
                 $macro->html_box(
                   $cgi->Tr(
                     $cgi->td({-bgcolor=>'#003300'},
                       $cgi->font({-color=>'#FFFFFF',-face=>'Arial',-size=>1},
                         'Link Button:'
                       )
                     )
                   )
                 . $cgi->Tr(
                     $cgi->td({-bgcolor=>'#FFFFFF',-align=>'center'},
                       $cgi->img({-width=>88,-height=>31,-vspace=>5,
                                  -src=>'/images/linkbutton.gif'})
                     )
                   ),
                   175
                 )

               )
             )
           );


# Put out :)

$ret = $macro->update_raw_page($out_name,$body);

print "--> done! (return $ret)\n" unless $quiet;