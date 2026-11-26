#!/usr/bin/perl
# Gives every <img> an alt attribute, in both the compiled app templates
# (main-*.js consts) and the prerendered pages, so they stay identical.
#   - banner photos behind a page title and icons next to their own text are
#     decorative: alt=""  (screen readers skip them)
#   - meaningful images get a description (%ALT)
# Also fixes the Women's Ministry photo that was labelled "Men's Ministry".
# Safe to re-run.
use strict; use warnings;
my $root = $ARGV[0] // '.';
my %ALT = (
  'images/logo.png'      => 'Messiah Fellowship',
  'images/signature.png' => 'Chairman’s signature',
);
my %ALT_JS = (   # same text, \u escapes as the app bundle uses
  'images/logo.png'      => 'Messiah Fellowship',
  'images/signature.png' => 'Chairman’s signature',
);
local $/;

# ---------- app templates ----------
my ($js) = glob("$root/main-*.js");
open my $f, '<:raw', $js or die $!; my $s = <$f>; close $f;
my $n = 0;
$s =~ s{\["src","([^"]+\.(?:jpe?g|png|svg|webp|gif))"((?:,[^\]]*)?)\]}{
  my ($src, $rest) = ($1, $2);
  if ($rest =~ /"alt"/) { "[\"src\",\"$src\"$rest]" }
  else { $n++; my $alt = $ALT_JS{$src} // ''; "[\"src\",\"$src\",\"alt\",\"$alt\"$rest]" }
}ge;
my $w = ($s =~ s{\["src","images/womens\.jpg","alt","Men\\u2019s Ministry"\]}{["src","images/womens.jpg","alt","Women\\u2019s Ministry"]}g);
open my $o, '>:raw', $js or die $!; print $o $s; close $o;
print "app: $n images given alt, women's photo fixed: $w\n";

# ---------- prerendered pages ----------
for my $p (glob("$root/*/index.html"), "$root/index.html") {
  open my $in, '<:raw', $p or die $!; my $h = <$in>; close $in;
  my $c = 0;
  $h =~ s{<img\b([^>]*)>}{
    my $a = $1;
    if ($a =~ /\balt\s*=/ || $a !~ /\bsrc="([^"]+)"/) { "<img$a>" }
    else { $c++; my $alt = $ALT{$1} // ''; $a =~ s{\s*/$}{}; "<img$a alt=\"$alt\">" }
  }ge;
  $c += ($h =~ s{(src="images/womens\.jpg" alt=")Men’s Ministry"}{$1Women’s Ministry"}g);
  next unless $c;
  open my $out, '>:raw', $p or die $!; print $out $h; close $out;
  print "$p: $c\n";
}
