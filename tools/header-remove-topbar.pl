#!/usr/bin/perl
# Remove the top strip (service times bar) from the header on every page.
# Header template loses slots 0-9 (div.top-bar + 2 spans) → later slots -10,
# first G jump -10, decls -10. Prerendered pages lose <div class="top-bar">…</div>. Run once.
use strict; use warnings;
local $/;
my ($jsf) = glob('main-*.js');
open my $f, '<:raw', $jsf or die $!; my $s = <$f>; close $f;
$s =~ m{selectors:\[\["app-header"\]\],decls:65,vars:2,.*?dependencies:}s or die 'header (already done?)';
my ($st, $len) = ($-[0], $+[0] - $-[0]);
my $h = substr($s, $st, $len);
$h =~ s{decls:65}{decls:55} or die 'decls';
$h =~ s{t&1&&\(c\(0,"div",0\)\(1,"span"\)\(2,"b"\),d\(3,"Sunday:"\),u\(\),d\(4,"[^"]*"\),u\(\),c\(5,"span"\),d\(6,""\),c\(7,"b"\),d\(8,"Prayer Tower:"\),u\(\),d\(9,"[^"]*"\),u\(\)\(\),c\(10,"div",1\)}
       {t&1&&(c(10,"div",1)} or die 'top bar';
my $ti = index($h, 'template:function');
my ($hh, $tp) = (substr($h, 0, $ti), substr($h, $ti));
$tp =~ s{(?<![A-Za-z0-9_\$])(c|g|d|It|dt)\((\d+)(?=[,)])}{"$1(" . ($2 >= 10 ? $2 - 10 : $2)}ge;
$tp =~ s{\)\((\d+),}{')(' . ($1 >= 10 ? $1 - 10 : $1) . ','}ge;
$tp =~ s{t&2&&\(G\(15\)}{t&2&&(G(5)} or die 'G';
substr($s, $st, $len) = $hh . $tp;
open my $o, '>:raw', $jsf or die $!; print $o $s; close $o;
print "app header updated\n";
for my $p (glob('*/index.html'), 'index.html', '404.html') {
  next unless -f $p;
  open my $in, '<:raw', $p or die $!; my $x = <$in>; close $in;
  my $c = ($x =~ s{<div (_ngcontent-ng-c1659878071) class="top-bar">.*?</span></div>}{}s);
  next unless $c;
  open my $out, '>:raw', $p or die $!; print $out $x; close $out;
  print "$p\n";
}
