#!/usr/bin/perl
# Remove one plain <p> link from the footer (e.g. "Plan Your Visit"):
#   perl tools/footer-remove-item.pl "Plan Your Visit"
# The footer template loses 2 slots (the <p> and its text) at index S, so every
# slot >= S+2 moves down by 2. Updated together:
#   - element / text / template instructions and chained starts in the footer
#   - local refs dt(n), and the same refs inside the form's error templates C1 / b1
#   - the first G() jump of the update block (absolute from slot 0)
#   - decls
#   - hydration data (ng-state "t"/"c" keys) in every prerendered page
#   - the <p> itself in every prerendered page
use strict; use warnings; use utf8;
binmode STDOUT, ':utf8';
my $text = shift or die "usage: footer-remove-item.pl \"Item text\"\n";
local $/;
my ($jsf) = glob('main-*.js');
open my $f, '<:raw', $jsf or die $!; my $s = <$f>; close $f;

$s =~ m{selectors:\[\["app-footer"\]\],decls:(\d+),vars:10,.*?dependencies:}s or die 'footer';
my ($st, $len, $decls) = ($-[0], $+[0] - $-[0], $1);
my $h = substr($s, $st, $len);
my $ti = index($h, 'template:function');
my ($head, $tpl) = (substr($h, 0, $ti), substr($h, $ti));
$tpl =~ m{,c\((\d+),"p"\),d\((\d+),"\Q$text\E"\),u\(\)} or die "\"$text\" not found in footer";
my $S = $1;
my $sh = sub { my $n = shift; $n >= $S + 2 ? $n - 2 : $n };
$tpl =~ s{,c\($S,"p"\),d\(\d+,"\Q$text\E"\),u\(\)}{} or die 'remove';
$tpl =~ s{(?<![A-Za-z0-9_\$])(c|g|d|It|dt)\((\d+)(?=[,)])}{"$1(" . $sh->($2)}ge;
$tpl =~ s{\)\((\d+),}{')(' . $sh->($1) . ','}ge;
$tpl =~ s#(if\(t&2\)\{[^G]*?)G\((\d+)\)#$1 . 'G(' . $sh->($2) . ')'#e or die 'first G';
$head =~ s{decls:$decls}{'decls:' . ($decls - 2)}e or die 'decls';
substr($s, $st, $len) = $head . $tpl;

# error templates of the footer form read the parent's refs by slot
my $n = 0;
for my $fn ('C1', 'b1') {
  $n += ($s =~ s{(function $fn\(e,n\)\{if\(e&1&&\(c\(0,"div"\),It\(1,[A-Za-z0-9]+,2,0,"small",55\)\(2,[A-Za-z0-9]+,2,0,"small",55\),u\(\)\),e&2\)\{Xi\(\);let t=dt\()(\d+)\)}{$1 . $sh->($2) . ')'}e);
}
die "error templates: expected 2, fixed $n" unless $n == 2;
open my $o, '>:raw', $jsf or die $!; print $o $s; close $o;
print "app: removed \"$text\" (slots $S-", $S + 1, "), decls $decls -> ", $decls - 2, "\n";

for my $p (glob('*/index.html'), 'index.html') {
  open my $in, '<:raw', $p or die $!; my $x = <$in>; close $in;
  my $c = 0;
  my $t = $text; utf8::encode($t);
  $c += ($x =~ s{<p (_ngcontent-ng-c\d+)>\Q$t\E</p>}{}g);
  $c += ($x =~ s{\{"t":\{"(\d+)":"t0","(\d+)":"t1"\},"c":\{"\1":\[\],"\2":\[\]\}\}}{
    my ($a, $b) = ($sh->($1), $sh->($2)); qq({"t":{"$a":"t0","$b":"t1"},"c":{"$a":[],"$b":[]}})
  }ge) if $c;
  next unless $c;
  open my $out, '>:raw', $p or die $!; print $out $x; close $out;
  print "$p: $c\n";
}
