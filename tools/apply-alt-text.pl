#!/usr/bin/perl
# Sets descriptive alt text from tools/alt-text.tsv (src<TAB>alt) for images
# whose alt is empty, in the app bundle and in every prerendered page. Safe to re-run.
use strict; use warnings;
local $/;
open my $t, '<:raw', 'tools/alt-text.tsv' or die $!; my %A = map { split /\t/ } grep { /\t/ } split /\r?\n/, <$t>; close $t;
my ($js) = glob('main-*.js');
open my $f, '<:raw', $js or die $!; my $s = <$f>; close $f;
my $n = 0;
for my $src (keys %A) { (my $a = $A{$src}) =~ s/&/&/g; $n += ($s =~ s{\["src","\Q$src\E","alt",""}{["src","$src","alt","$a"}g); }
open my $o, '>:raw', $js or die $!; print $o $s; close $o;
print "app: $n\n";
for my $p (glob('*/index.html'), 'index.html') {
  open my $in, '<:raw', $p or die $!; my $h = <$in>; close $in; my $c = 0;
  for my $src (keys %A) { (my $a = $A{$src}) =~ s/&/&amp;/g; $c += ($h =~ s{(src="\Q$src\E"[^>]*?\balt=)""}{$1"$a"}g); }
  next unless $c; open my $out, '>:raw', $p or die $!; print $out $h; close $out; print "$p: $c\n";
}
