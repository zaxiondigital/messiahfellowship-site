#!/usr/bin/perl
# Ministries menu: add "Christian Matrimony" (/matrimony/) after Messiah Bible College.
# Header template: 2 new slots (a + text) at 28 → later slots +2, decls +2;
# new const ["href","/matrimony/",3,"click"] (plain link: /matrimony/ is a static page).
use strict; use warnings;
local $/;
my ($jsf) = glob('main-*.js');
open my $f, '<:raw', $jsf or die $!; my $s = <$f>; close $f;
die 'already done' if index($s, '"/matrimony/"') >= 0;
$s =~ m{selectors:\[\["app-header"\]\],decls:(\d+),vars:2,.*?dependencies:}s or die 'header';
my ($st, $len, $decls) = ($-[0], $+[0] - $-[0], $1);
my $h = substr($s, $st, $len);
$h =~ s{decls:$decls}{'decls:' . ($decls + 2)}e or die 'decls';
$h =~ s{(\["href","/pastors/",3,"click"\])\]}{$1,["href","/matrimony/",3,"click"]]} or die 'const';
# const index of the new entry = index of /pastors/ + 1
my ($consts) = $h =~ m{consts:\[(.*?)\],template:}s or die 'consts';
my $i = 0; my $kp;
while ($consts =~ m{\G\s*(\[(?:[^\[\]"]|"(?:[^"\\]|\\.)*")*\]),?}gc) { $kp = $i if $1 eq '["href","/pastors/",3,"click"]'; $i++ }
my $K = $kp + 1;
my $ti = index($h, 'template:function');
my ($hh, $tp) = (substr($h, 0, $ti), substr($h, $ti));
$tp =~ s{(?<![A-Za-z0-9_\$])(c|g|d|It|dt)\((\d+)(?=[,)])}{"$1(" . ($2 >= 28 ? $2 + 2 : $2)}ge;
$tp =~ s{\)\((\d+),}{')(' . ($1 >= 28 ? $1 + 2 : $1) . ','}ge;
$tp =~ s{(d\(27,"Messiah Bible College"\),u\(\))}{$1,c(28,"a",$K),H("click",function(){return i.closeMenu()}),d(29,"Christian Matrimony"),u()} or die 'insert';
substr($s, $st, $len) = $hh . $tp;
open my $o, '>:raw', $jsf or die $!; print $o $s; close $o;
print "app header updated (const $K, decls ", $decls + 2, ")\n";
for my $p (glob('*/index.html'), 'index.html', '404.html') {
  next unless -f $p;
  open my $in, '<:raw', $p or die $!; my $x = <$in>; close $in;
  next if index($x, 'href="/matrimony/">Christian Matrimony') >= 0;
  my $c = ($x =~ s{(<a (_ngcontent-ng-c1659878071) routerlink="/bible-college" href="/bible-college">Messiah Bible College</a>)}{$1<a $2 href="/matrimony/">Christian Matrimony</a>});
  next unless $c;
  open my $out, '>:raw', $p or die $!; print $out $x; close $out;
  print "$p\n";
}
