#!/usr/bin/perl
# Adds "Our Pastors" (/pastors/) to the main menu, right after About.
#  - main-*.js: the compiled header template gets a new <a href="/pastors/">
#    (plain link: /pastors/ is a static page, not an app route), later slot
#    indices shift by 2 and decls 73 -> 75 so hydration still matches.
#  - every page's prerendered HTML gets the same <a> after About.
# Safe to re-run: skips files that already have the link.
use strict; use warnings;
my $root = $ARGV[0] // '.';
local $/;

# ---------- compiled template ----------
my ($js) = glob("$root/main-*.js");
open my $f, '<:raw', $js or die $!; my $s = <$f>; close $f;
if ($s !~ m{\["href","/pastors/",3,"click"\]}) {
  $s =~ m{selectors:\[\["app-header"\]\],decls:73,(.*?)dependencies:}s or die 'header not found';
  my ($start, $len) = ($-[0], $+[0] - $-[0]);
  my $h = substr($s, $start, $len);
  my ($tpl_at) = index($h, 'template:function');
  my $consts = substr($h, 0, $tpl_at);
  my $tpl    = substr($h, $tpl_at);
  # new const (index 28)
  $consts =~ s{(,"watch-btn",3,"click"\])\]}{$1,["href","/pastors/",3,"click"]]} or die 'consts';
  $consts =~ s{decls:73}{decls:75} or die 'decls';
  # shift slot indices >= 30
  $tpl =~ s{\((\d+),"}{'(' . ($1 >= 30 ? $1 + 2 : $1) . ',"'}ge;
  # insert after About
  $tpl =~ s{(d\(29,"About"\),u\(\))}{$1,c(30,"a",28),H("click",function(){return i.closeMenu()}),d(31,"Our Pastors"),u()} or die 'about';
  substr($s, $start, $len) = $consts . $tpl;
  open my $o, '>:raw', $js or die $!; print $o $s; close $o;
  print "updated $js\n";
}

# ---------- prerendered pages ----------
my @pages = (glob("$root/*/index.html"), "$root/index.html", "$root/404.html");
for my $p (@pages) {
  next unless -f $p;
  open my $in, '<:raw', $p or die $!; my $h = <$in>; close $in;
  next if $h =~ m{href="/pastors/">Our Pastors</a>};
  my $n = ($h =~ s{(<a (_ngcontent-ng-c\d+) routerlink="/about" href="/about">About</a>)}{$1<a $2 href="/pastors/">Our Pastors</a>});
  unless ($n) { print "no header in $p\n"; next; }
  open my $o, '>:raw', $p or die $!; print $o $h; close $o;
  print "updated $p\n";
}
