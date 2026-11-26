#!/usr/bin/perl
# Footer > Ministries: remove "Family Blessing Prayer" (no longer held).
# The footer template loses slots 34-35, so every slot >= 36 moves down by 2:
#   element/text/template instructions, local refs dt(n), the first G() jump
#   of the update block, decls 110 -> 108, and the hydration data (ng-state
#   "t"/"c" keys 87/101 -> 85/99) in every prerendered page. Run once.
use strict; use warnings;
local $/;
my ($jsf) = glob('main-*.js');
open my $f, '<:raw', $jsf or die $!; my $s = <$f>; close $f;
die 'already done' if index($s, 'd(35,"Family Blessing Prayer")') < 0;
$s =~ m{selectors:\[\["app-footer"\]\],decls:110,vars:10,.*?dependencies:}s or die 'footer';
my ($st, $len) = ($-[0], $+[0] - $-[0]);
my $h = substr($s, $st, $len);
my $ti = index($h, 'template:function');
my ($head, $tpl) = (substr($h, 0, $ti), substr($h, $ti));
$head =~ s{decls:110}{decls:108} or die 'decls';

$tpl =~ s{,c\(34,"p"\),d\(35,"Family Blessing Prayer"\),u\(\)}{} or die 'remove';
my $sh = sub { my $n = shift; $n >= 36 ? $n - 2 : $n };
# named instructions with a slot index first: c( g( d( It( dt(
$tpl =~ s{(?<![A-Za-z0-9_\$])(c|g|d|It|dt)\((\d+)(?=[,)])}{"$1(" . $sh->($2)}ge;
# chained element starts: )(83,"div",38)
$tpl =~ s{\)\((\d+),}{')(' . $sh->($1) . ','}ge;
# update block: first jump is from slot 0 → absolute
$tpl =~ s#(if\(t&2\)\{[^G]*?)G\((\d+)\)#$1 . 'G(' . $sh->($2) . ')'#e or die 'first G';
substr($s, $st, $len) = $head . $tpl;
open my $o, '>:raw', $jsf or die $!; print $o $s; close $o;
print "app template updated\n";

for my $p (glob('*/index.html'), 'index.html', '404.html') {
  next unless -f $p;
  open my $in, '<:raw', $p or die $!; my $x = <$in>; close $in;
  my $c = 0;
  $c += ($x =~ s{<p (_ngcontent-ng-c1297960268)>Family Blessing Prayer</p>}{}g);
  $c += ($x =~ s{\{"t":\{"87":"t0","101":"t1"\},"c":\{"87":\[\],"101":\[\]\}\}}{{"t":{"85":"t0","99":"t1"},"c":{"85":[],"99":[]}}}g);
  next unless $c;
  open my $out, '>:raw', $p or die $!; print $out $x; close $out;
  print "$p: $c\n";
}
# NOTE (applied by hand after the first run): the two error-message templates
# C1 / b1 read the parent's local refs by slot too: dt(81) -> dt(79), dt(100) -> dt(98).
