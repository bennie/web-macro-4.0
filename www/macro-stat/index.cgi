#!/usr/bin/perl -I../../lib/

use CGI;
use Convert::Area;
use Convert::Length;
use Convert::Volume;
use Convert::Weight;
use Macro::Template;
use strict;

my $cgi = new CGI;
print $cgi->header;

my $tmpl   = new Macro::Template ('main-template-css');
my $length = new Convert::Length;
my $area   = new Convert::Area;
my $volume = new Convert::Volume;
my $weight = new Convert::Weight;

my @body;

my @starts = qw/s_height s_weight s_height_unit s_weight_unit/;
my @finish = qw/f_height f_weight f_height_unit f_weight_unit/;
my @mods   = qw/l_mod a_mod w_mod/;

my $title;

if ( &paramcheck(@mods,@finish,@starts) ) {
  @body = &additional; # compute additional stats
} elsif ( &paramcheck('type',@starts) ) {
  @body = &compute; # compute basicstats on the new height
} elsif ( &paramcheck(@starts) ) {
  @body = &modify; # Choose how to grow and to what size
} elsif ( &paramcheck('start') ) {
  @body = &basic; # enter the starting size
} else {
  @body = &default;
}

my $body = $cgi->start_form
         . $tmpl->{start_table}
         . ( $title ? $cgi->Tr($cgi->td({-bgcolor=>'#003300'},$cgi->font({-color=>'#FFFFFF',-face=>'Arial',-size=>4},$title))) : '' )
         . $cgi->Tr($cgi->td(@body))
         . $tmpl->{end_table}
         . $cgi->end_form;

print $tmpl->do({
  title        => 'MacroStat',
  body         => $body,
  time         => "This page was dynamically generated",
  year         => ((localtime)[5] + 1900)
});

### Pages

sub additional {
  $title = 'Finish';

  my $l_mod = $cgi->param('l_mod');
  my $a_mod = $cgi->param('a_mod');
  my $w_mod = $cgi->param('w_mod');

  return
    $cgi->p('So, we were talking about your',$cgi->param('f_height'),
      $cgi->param('f_heightunit'),'big self. If you\'re curious, that means 
      that you are',$l_mod,'times taller and',$w_mod,'times heavier, but I 
      digress.'),
    $cgi->p('On to those other stats...'),
    $cgi->hr({-noshade=>undef}),
    ( map { 
      $cgi->param('lname'.$_) 
        ? $cgi->p(
            $cgi->b($cgi->param('lname'.$_).':'),
            ( $cgi->param('length'.$_) * $l_mod ),
            $cgi->param('lunit'.$_)
          ) 
        : ' '
    } (1..4) ),
    ( map { 
      $cgi->param('aname'.$_) 
        ? $cgi->p(
            $cgi->b($cgi->param('aname'.$_).':'),
            ( $cgi->param('area'.$_) * $a_mod ),
            $cgi->param('aunit'.$_)
          ) 
        : ' '
    } (1..4) ),
    ( map { 
      $cgi->param('wname'.$_) 
        ? $cgi->p(
            $cgi->b($cgi->param('wname'.$_).':'),
            ( $cgi->param('weight'.$_) * $w_mod ),
            $cgi->param('wunit'.$_)
          ) 
        : ' '
    } (1..4) ),
    ( map { 
      $cgi->param('vname'.$_) 
        ? $cgi->p(
            $cgi->b($cgi->param('vname'.$_).':'),
            ( $cgi->param('volume'.$_) * $w_mod ),
            $cgi->param('vunit'.$_)
          ) 
        : ' '
    } (1..4) ),
    $cgi->hr({-noshade=>undef});
}

sub basic {
  $title = 'The Basic Stats';
  return 
    $cgi->p('These are the basic stats of your current, non-altered 
self. You will have a chance to add more in later, if you wish. This is 
the basic start.'),
    $cgi->center(
      $cgi->table(
        $cgi->Tr(
          $cgi->td($cgi->b('Height:')),
          $cgi->td($cgi->textfield({-size=>12,-name=>'s_height'})),
          $cgi->td($cgi->popup_menu('s_height_unit',$length->types_with_names))
        ),
        $cgi->Tr(
          $cgi->td($cgi->b('Weight:')),
          $cgi->td($cgi->textfield({-size=>12,-name=>'s_weight'})),
          $cgi->td($cgi->popup_menu('s_weight_unit',$weight->types_with_names))
        ),
      )
    ),
    $cgi->hr({-noshade=>undef}),
    $cgi->center($cgi->submit('Continue'));
}

sub compute {
  my ($s_height,$s_height_unit,$f_height,$f_height_unit);
  my ($s_weight,$s_weight_unit,$f_weight,$f_weight_unit);
  my ($l_mod,$a_mod,$w_mod);
  my $type = lc($cgi->param('type'));

  if ( $type eq 'height' ) {

    $s_height      = $cgi->param('s_height');
    $s_height_unit = $cgi->param('s_height_unit');
    $f_height      = $cgi->param('f_height');
    $f_height_unit = $cgi->param('f_height_unit');

    my $raw_new_height = $length->convert($f_height_unit,$s_height_unit,$f_height);

    $l_mod = $raw_new_height / $s_height;
    $a_mod = $l_mod ** 2;
    $w_mod = $l_mod ** 3;

    $s_weight      = $cgi->param('s_weight');
    $s_weight_unit = $cgi->param('s_weight_unit');
    $f_weight      = $s_weight * $w_mod;
    $f_weight_unit = $s_weight_unit;

  } elsif ( $type eq 'weight' ) {

    $s_weight      = $cgi->param('s_weight');
    $s_weight_unit = $cgi->param('s_weight_unit');
    $f_weight      = $cgi->param('f_weight');
    $f_weight_unit = $cgi->param('f_weight_unit');

    my $raw_new_weight = $weight->convert($f_weight_unit,$s_weight_unit,$f_weight);

    $w_mod = $raw_new_weight / $s_weight;
    $l_mod = $w_mod ** ( 1/3 );
    $a_mod = $l_mod ** 2;

    $s_height      = $cgi->param('s_height');
    $s_height_unit = $cgi->param('s_height_unit');
    $f_height      = $s_height * $l_mod;
    $f_height_unit = $s_height_unit;

  } elsif ( $type eq 'timesheight' ) {

    $s_height      = $cgi->param('s_height');
    $s_height_unit = $cgi->param('s_height_unit');
    $s_weight      = $cgi->param('s_weight');
    $s_weight_unit = $cgi->param('s_weight_unit');

    $l_mod = $cgi->param('multheight');
    $a_mod = $l_mod ** 2;
    $w_mod = $l_mod ** 3;

    $f_height      = $s_height * $l_mod;
    $f_height_unit = $s_height_unit;
    $f_weight      = $s_weight * $w_mod;
    $f_weight_unit = $s_weight_unit;

  } elsif ( $type eq 'timesweight' ) {

    $s_height      = $cgi->param('s_height');
    $s_height_unit = $cgi->param('s_height_unit');
    $s_weight      = $cgi->param('s_weight');
    $s_weight_unit = $cgi->param('s_weight_unit');

    $w_mod = $cgi->param('multweight');
    $l_mod = $w_mod ** ( 1/3 );
    $a_mod = $l_mod ** 2;

    $f_height      = $s_height * $l_mod;
    $f_height_unit = $s_height_unit;
    $f_weight      = $s_weight * $w_mod;
    $f_weight_unit = $s_weight_unit;

  }

  $cgi->delete_all;

  $title = 'The New You';

  return
    $cgi->p('Starting Height:',$s_height,$s_height_unit),
    $cgi->p('Starting Weight:',$s_weight,$s_weight_unit),
    $cgi->p('Finishing Height:',$f_height,$f_height_unit),
    $cgi->p('Finishing Weight:',$f_weight,$f_weight_unit),
    $cgi->hr({-noshade=>undef}),

    $cgi->hidden({-name=>'s_height'      , -value=>$s_height      }),
    $cgi->hidden({-name=>'s_height_unit' , -value=>$s_height_unit }),
    $cgi->hidden({-name=>'s_weight'      , -value=>$s_weight      }),
    $cgi->hidden({-name=>'s_weight_unit' , -value=>$s_weight_unit }),
    $cgi->hidden({-name=>'f_height'      , -value=>$f_height      }),
    $cgi->hidden({-name=>'f_height_unit' , -value=>$f_height_unit }),
    $cgi->hidden({-name=>'f_weight'      , -value=>$f_weight      }),
    $cgi->hidden({-name=>'f_weight_unit' , -value=>$f_weight_unit }),
    $cgi->hidden({-name=>'l_mod'         , -value=>$l_mod         }),
    $cgi->hidden({-name=>'a_mod'         , -value=>$a_mod         }),
    $cgi->hidden({-name=>'w_mod'         , -value=>$w_mod         }),

    $cgi->font({-size=>4},'Additional Stats:'),

    $cgi->dl(
      $cgi->dt('Linear Stats:'),
      $cgi->dd(
        $cgi->p('These stats are stats that are based off of linear measurements.
Chest size, Collar Size, Inseam, Digit Length, Palm width, etc. Enter and
name the various starting lengths that you want adapted to your new
size:'),
        ( map { $cgi->p(
           'Name:',$cgi->textfield({-name=>'lname'.$_,-size=>10}),'is',
           $cgi->textfield({-name=>'length'.$_,-size=>10}),
           $cgi->popup_menu('lunit'.$_,$length->types_with_names)
        ) } ( 1 .. 4 ) )
      ),
      $cgi->dt('Area Stats:'),
      $cgi->dd(
        $cgi->p('How many square feet will that footprint be. How big will that
chest-area be. Enter the starting size.'),
        ( map { $cgi->p(
           'Name:',$cgi->textfield({-name=>'aname'.$_,-size=>10}),'is',
           $cgi->textfield({-name=>'area'.$_,-size=>10}),
           $cgi->popup_menu('aunit'.$_,$area->types_with_names)
        ) } ( 1 .. 4 ) )
      ),
      $cgi->dt('Weight Stats:'),
      $cgi->dd(
        $cgi->p('Weight things. What you could lift, carry, or the
weight of various parts, etc.'),
        ( map { $cgi->p(
           'Name:',$cgi->textfield({-name=>'wname'.$_,-size=>10}),'is',
           $cgi->textfield({-name=>'weight'.$_,-size=>10}),
           $cgi->popup_menu('wunit'.$_,$weight->types_with_names)
        ) } ( 1 .. 4 ) )
      ),
      $cgi->dt('Volume Stats:'),
      $cgi->dd(
        $cgi->p('Volume? Yes, Volume. Now what nice, clean euphamisms can I use on
this. Ummm,... any liquid or dry measure of whatever. How much you rank
before, or whatnot.'),
        ( map { $cgi->p(
           'Name:',$cgi->textfield({-name=>'vname'.$_,-size=>10}),'is',
           $cgi->textfield({-name=>'volume'.$_,-size=>10}),
           $cgi->popup_menu('vunit'.$_,$volume->types_with_names)
        ) } ( 1 .. 4 ) )
      ),
    ),

    $cgi->hr({-noshade=>undef}),
    $cgi->center($cgi->submit('Continue'));

}

sub default {
  $title = $cgi->center($cgi->font({-size=>'+3'},$cgi->tt('MacroSTAT 1.0')));
  return
    $cgi->img({-src=>'/resources/images/computer.gif',-width=>'179',-height=>'211',
    -align=>'left'}),
    $cgi->p('This is a statistical generation program for those of you who
are thinking in Macro sizes. It asks a few questions and helps you
compute all kinds of fun and CORRECT statistics for your Macro self.'),
    $cgi->p('Porportional Growth and Spacial Math are often mis-understood 
by the average person. If a given object doubles in height, most people 
think that it\'s weight merely doubles. This is not correct, it is 8 times
heavier. Basically, as linear measurement grow at a certain rate, volume
based measurements grow at the cube of that rate. (volume is the cube of
the linear sides, remmeber?)'),
    $cgi->p('Enough technical, if you don\'t believe me, check out a 
physics or math book that addresses the subject of growth. Otherwise, you 
can use this little form to generate accurate descriptions of your 
Macro.'),
    $cgi->hidden({-name=>'start',-value=>'true'}),
    $cgi->center($cgi->submit('Start the program'));
}

sub modify {
  $title = 'The Changing Stat';
  return 
    $cgi->p('Starting Height:',$cgi->param('s_height'),$cgi->param('s_height_unit')),
    $cgi->p('Starting Weight:',$cgi->param('s_weight'),$cgi->param('s_weight_unit')),
    ( map { $cgi->hidden({-name=>$_,-value=>$cgi->param($_)}) } @starts ),
    $cgi->hr({-noshade=>undef}),
    $cgi->p('We need one stat of your altered form from which to extrapolate
how much bigger (or smaller) you have become. Most of the time, you can
simply state the new height or weight you wish to be. However, there are
several other options offered. Check and fill out the appropiate method
you wish to use.'),
    $cgi->hr({-noshade=>undef}),
    $cgi->p(
      $cgi->radio_group(-name=>'type',-values=>['height'],-linebreak=>'true',
                        -labels=>{'height'=>' Simple by Height:'}),
      $cgi->blockquote(
        'My new height will be',
        $cgi->textfield({-size=>12,-name=>'f_height'}),
        $cgi->popup_menu('f_height_unit',$length->types_with_names)
      )
    ),
    $cgi->p(
      $cgi->radio_group(-name=>'type',-values=>['weight'],-linebreak=>'true',
                        -labels=>{'weight'=>' Simple by Weight:'}),
      $cgi->blockquote(
        'My new weight will be',
        $cgi->textfield({-size=>12,-name=>'f_weight'}),
        $cgi->popup_menu('f_weight_unit',$weight->types_with_names)
      )
    ),
    $cgi->p(
      $cgi->radio_group(-name=>'type',-values=>['timesheight'],-linebreak=>'true',
                        -labels=>{'timesheight'=>' Multiply by Height:'}),
      $cgi->blockquote(
        'I want to be ',
        $cgi->textfield({-size=>5,-name=>'multheight'}),
        ' times taller.'
      )
    ),
    $cgi->p(
      $cgi->radio_group(-name=>'type',-values=>['timesweight'],-linebreak=>'true',
                        -labels=>{'timesweight'=>' Multiply by Weight:'}),
      $cgi->blockquote(
        'I want to be ',
        $cgi->textfield({-size=>5,-name=>'multweight'}),
        ' times heavier.'
      )
    ),

    $cgi->hr({-noshade=>undef}),
    $cgi->center($cgi->submit('Continue'));
}

### subroutines

sub paramcheck {
  for my $param (@_) {
    return 0 unless $cgi->param($param);
  }
  return 1;
}
