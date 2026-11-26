#!/usr/bin/perl
# Main menu: remove "Events" (the page is an empty placeholder).
# Header template loses slots 44–45 → later slots −2, decls −2 (the update
# block's only jump, G(5), is before it). Pages lose the <a href="/events">.
# The /events/ page itself stays reachable by direct link; it's removed from the sitemap.
use strict; use warnings;
local $/;
my ($jsf) = glob('main-*.js');
open my $f, '<:raw', $jsf or die $!; my $s = <$f>; close $f;
$s =~ m{selectors:\[\["app-header"\]\],decls:(\d+),vars:2,.*?dependencies:}s or die 'header';
my ($st, $len, $decls) = ($-[0], $+[0] - $-[0], $1);
my $h = substr($s, $st, $len);
$h =~ s{,c\(44,"a",22\),H\("click",function\(\)\{return i\.closeMenu\(\)\}\),d\(45,"Events"\),u\(\)}{} or die 'events (already removed?)';
$h =~ s{decls:$decls}{'decls:' . ($decls - 2)}e or die 'decls';
my $ti = index($h, 'template:function');
my ($hh, $tp) = (substr($h, 0, $ti), substr($h, $ti));
$tp =~ s{(?<![A-Za-z0-9_\$])(c|g|d|It|dt)\((\d+)(?=[,)])}{"$1(" . ($2 >= 46 ? $2 - 2 : $2)}ge;
$tp =~ s{\)\((\d+),}{')(' . ($1 >= 46 ? $1 - 2 : $1) . ','}ge;
substr($s, $st, $len) = $hh . $tp;
open my $o, '>:raw', $jsf or die $!; print $o $s; close $o;
print "app header updated (decls ", $decls - 2, ")\n";
for my $p (glob('*/index.html'), 'index.html', '404.html') {
  next unless -f $p;
  open my $in, '<:raw', $p or die $!; my $x = <$in>; close $in;
  my $c = ($x =~ s{<a _ngcontent-ng-c1659878071 routerlink="/events" href="/events">Events</a>}{}g);
  next unless $c;
  open my $out, '>:raw', $p or die $!; print $out $x; close $out;
  print "$p\n";
}
