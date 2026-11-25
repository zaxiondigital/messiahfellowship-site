#!/usr/bin/perl
# Generate colors-map.css: rewrite every off-palette colour in the site's own
# (Angular) <style> blocks to the matching palette colour, by role.
use strict; use warnings;

my $root = shift or die "usage: colormap.pl <site-dir> > out.css\n";
my @files = (glob("$root/index.html"), glob("$root/*/index.html"), glob("$root/styles-*.css"));

# ---- palette mapping by role (source hex -> palette hex) ----
my %TEXT = (
  # maroon family
  '7b2c4a'=>'6e0f4a','6e0f4a'=>'6e0f4a','5b0038'=>'4f0834','5c0a2f'=>'4f0834','4f0834'=>'4f0834',
  '594c54'=>'6e0f4a','746742'=>'6e0f4a',              # big italic quotes -> brand maroon
  '33262e'=>'111111',                                  # section title -> ink
  # gold family
  'a3832e'=>'a3832e','a8841f'=>'a3832e','c8a23a'=>'c8a23a','fffbf0'=>'fffbf0','fffbef'=>'fffbf0',
  # near-black -> ink
  map({$_=>'111111'} qw(000000 111111 141414 121212 161616 10100f 191517 1a1a1a 1b1b1b 1c1c1c)),
  # dark greys -> body text
  map({$_=>'333333'} qw(222222 242424 272727 2b2b2b 2c2c2c 333333)),
  # mid greys -> muted text
  map({$_=>'5c5c5c'} qw(3f3f3f 414141 444444 555555 606060 605f5f 717171 7e7e7e 808080 999999)),
  # light greys used as text (on dark backgrounds)
  map({$_=>'cccccc'} qw(bbbbbb cccccc dcdcdc dbdbdb dddddd)),
  map({$_=>'f5f5f5'} qw(e5e5e5 e9e9e9 eaeae9 eeeeee efefef f1f1f1 f2f2f2 f2f2f0 f5f5f5 f9f9f9 f8f6f7)),
  # light maroon tints used as text on maroon
  map({$_=>'f8eef4'} qw(fff5fb ffe8f7)),
  map({$_=>'f1dde8'} qw(f3e6ed efdbe8)),
  # status
  'ff4500'=>'c2410c','ff0000'=>'b91c1c',
);
my %BG = (
  '7b2c4a'=>'6e0f4a','6e0f4a'=>'6e0f4a','5b0038'=>'4f0834','5c0a2f'=>'4f0834','4f0834'=>'4f0834','33262e'=>'4f0834',
  # gold backgrounds -> deeper gold so white / cream text passes contrast (5.05:1)
  'a3832e'=>'876b22','a8841f'=>'876b22','c8a23a'=>'c8a23a','746742'=>'876b22','fffbf0'=>'fffbf0','fffbef'=>'fffbf0',
  map({$_=>'111111'} qw(000000 111111 141414 121212 161616 10100f 191517 1a1a1a 1b1b1b 1c1c1c 222222 242424 272727 2b2b2b 2c2c2c 333333)),
  map({$_=>'5c5c5c'} qw(3f3f3f 414141 444444 555555 606060 605f5f 717171 7e7e7e 808080 999999 594c54)),
  map({$_=>'f5f5f5'} qw(eeeeee efefef f1f1f1 f2f2f2 f2f2f0 f5f5f5 f9f9f9 f8f6f7)),
  map({$_=>'ebebeb'} qw(e5e5e5 e9e9e9 eaeae9 dcdcdc dbdbdb dddddd bbbbbb cccccc)),
  map({$_=>'f8eef4'} qw(fff5fb ffe8f7)),
  map({$_=>'f1dde8'} qw(f3e6ed efdbe8)),
  'ff4500'=>'c2410c','ff0000'=>'b91c1c',
);
my %BORDER = (
  '7b2c4a'=>'6e0f4a','6e0f4a'=>'6e0f4a','5b0038'=>'4f0834','5c0a2f'=>'4f0834','4f0834'=>'4f0834','33262e'=>'4f0834',
  'a3832e'=>'a3832e','a8841f'=>'a3832e','c8a23a'=>'c8a23a','fffbf0'=>'fffbf0',
  map({$_=>'333333'} qw(000000 111111 141414 121212 161616 1a1a1a 1b1b1b 222222 242424 272727 2b2b2b 333333 3f3f3f 414141 444444 555555 606060)),
  map({$_=>'cccccc'} qw(717171 7e7e7e 808080 999999 bbbbbb cccccc)),
  map({$_=>'e5e5e5'} qw(dcdcdc dbdbdb dddddd e5e5e5 e9e9e9 eaeae9 eeeeee efefef f1f1f1 f2f2f2 f5f5f5 f9f9f9)),
  'ff4500'=>'c2410c','ff0000'=>'b91c1c',
);
my %NAMED = (black=>'000000', white=>'ffffff', gray=>'808080', grey=>'808080', red=>'ff0000', silver=>'c0c0c0', whitesmoke=>'f5f5f5');

sub norm {   # returns (hex6, alpha-or-undef) or ()
  my $c = lc shift;
  if ($c =~ /^#([0-9a-f]{3})$/)       { my $h = join '', map { $_ x 2 } split //, $1; return ($h, undef) }
  if ($c =~ /^#([0-9a-f]{4})$/)       { my @d = split //, $1; return ((join '', map { $_ x 2 } @d[0..2]), hex($d[3] x 2)/255) }
  if ($c =~ /^#([0-9a-f]{6})$/)       { return ($1, undef) }
  if ($c =~ /^#([0-9a-f]{6})([0-9a-f]{2})$/) { return ($1, hex($2)/255) }
  if ($c =~ /^rgba?\(\s*(\d+)[ ,]+(\d+)[ ,]+(\d+)(?:[ ,\/]+([\d.]+%?))?\s*\)$/) {
    my $a = $4; $a = defined $a ? ($a =~ s/%$// ? $a/100 : $a) : undef;
    return (sprintf('%02x%02x%02x', $1, $2, $3), $a);
  }
  return ($NAMED{$c}, undef) if $NAMED{$c};
  return ();
}
sub out_color { my ($h, $a) = @_;
  return "#$h" unless defined $a && $a < 1;
  return sprintf('rgba(%d, %d, %d, %s)', hex(substr($h,0,2)), hex(substr($h,2,2)), hex(substr($h,4,2)), 0+sprintf('%.3f',$a));
}
my $COLRE = qr/#[0-9a-fA-F]{3,8}\b|rgba?\([^)]*\)|\b(?:black|white|gray|grey|red|silver|whitesmoke)\b/;

my (%seen, @out, %stats);
sub handle_rule {
  my ($sel, $body, $media) = @_;
  return if $sel =~ /^\s*(?:from|to|\d+%)/;              # keyframe steps
  # buttons are coloured only by buttons.css
  return if $sel =~ /cta-btn|submit-btn|meet-pastor|btn-outline|button-outline|give-btn|watch-btn|nav-buttons|hero-content[^,{]*button|card[^,{]*button|mission-content[^,{]*\ba\b|offer-bottom[^,{]*\ba\b|contact-right[^,{]*button/;
  for my $decl (split /;/, $body) {
    next unless $decl =~ /^\s*([a-z-]+)\s*:\s*(.+?)\s*$/s;
    my ($prop, $val) = (lc $1, $2);
    next if $val =~ /gradient|url\(/;
    my ($role, @targets);
    if    ($prop =~ /^(color|fill|stroke|caret-color|text-decoration-color|-webkit-text-fill-color)$/) { $role='TEXT'; @targets=($prop) }
    elsif ($prop =~ /^background(-color)?$/)  { $role='BG'; @targets=('background-color') }
    elsif ($prop =~ /^border(-(top|right|bottom|left))?(-color)?$/) { $role='BORDER'; my $side=$2; @targets=($side ? "border-$side-color" : 'border-color') }
    elsif ($prop =~ /^outline(-color)?$/)     { $role='BORDER'; @targets=('outline-color') }
    else { next }
    my @cols = ($val =~ /($COLRE)/g); next unless @cols == 1;
    my ($h, $a) = norm($cols[0]); next unless $h;
    my $map = $role eq 'TEXT' ? \%TEXT : $role eq 'BG' ? \%BG : \%BORDER;
    my $to = $map->{$h}; next unless $to; next if $h eq 'ffffff';
    $stats{"$role $h->$to"}++;
    next if $to eq $h && !defined $a;                      # already on palette
    my $line = join '', map { $sel . '{' . $_ . ':' . out_color($to, $a) . '!important}' } @targets;
    my $key = "$media\x00$line"; next if $seen{$key}++;
    push @out, [$media, $line];
  }
}

for my $f (@files) {
  open my $fh, '<:raw', $f or die $!; local $/; my $txt = <$fh>; close $fh;
  my @css = $f =~ /\.css$/ ? ($txt) : ($txt =~ /<style[^>]*>(.*?)<\/style>/gs);
  for my $css (@css) {
    $css =~ s{/\*.*?\*/}{}gs;
    # walk top level, descending one level into @media
    my $pos = 0; my $len = length $css;
    my $parse; $parse = sub {
      my ($s, $media) = @_;
      while ($s =~ /\G\s*([^{}]+?)\s*\{/gc) {
        my $head = $1;
        if ($head =~ /^\@media/) {
          my $depth = 1; my $start = pos $s;
          while ($depth && $s =~ /\G[^{}]*([{}])/gc) { $depth += $1 eq '{' ? 1 : -1 }
          my $inner = substr($s, $start, pos($s) - $start - 1);
          $parse->($inner, $head);
        } elsif ($head =~ /^\@/) {                          # @font-face, @keyframes, @supports: skip block
          my $depth = 1; while ($depth && $s =~ /\G[^{}]*([{}])/gc) { $depth += $1 eq '{' ? 1 : -1 }
        } else {
          $s =~ /\G([^}]*)\}/gc or last;
          handle_rule($head, $1, $media);
        }
      }
    };
    $parse->($css, '');
  }
}

# ---- print grouped by media ----
my %by; my @order;
for (@out) { my ($m, $l) = @$_; push @order, $m unless exists $by{$m}; push @{$by{$m}}, $l }
print "/* Generated by colormap.pl – maps every original colour rule to the palette in colors.css. Do not edit by hand. */\n";
for my $m (@order) {
  if ($m eq '') { print "$_\n" for @{$by{$m}} }
  else { print "$m\{\n"; print "  $_\n" for @{$by{$m}}; print "}\n" }
}
print STDERR "$_ x$stats{$_}\n" for sort { $stats{$b} <=> $stats{$a} } keys %stats;
print STDERR "rules emitted: ", scalar(@out), "\n";
