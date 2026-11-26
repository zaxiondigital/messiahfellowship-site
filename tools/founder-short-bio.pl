#!/usr/bin/perl
# Home > Pastor Sajja Eliazer: short bio (2 paragraphs) + "Read his story →" (full
# bio is on /pastors/#founder). Template: paragraphs 3–5 (slots 115–120, 6 slots)
# become one <p class="pastor-more"><a href="/pastors/#founder"> (3 slots) →
# later slots −3, first G jump −3, decls −3. Run once.
use strict; use warnings; use utf8;
local $/;
my $P1 = ' is the founder and president of Messiah Fellowship, a ministry that has faithfully served for more than five decades. His life was transformed when his younger son, Ratna Kumar, was miraculously healed, and he surrendered his life to the Gospel.';
my $P2 = 'Known for his bold preaching across Andhra Pradesh and beyond, his television program Mahima Gadiyalu is among the most-watched Christian broadcasts, sharing the message of hope, healing, and salvation.';
my $MORE = 'Read his story →';
sub jsq { my $s = shift; $s =~ s/([^\x00-\x7f])/sprintf('\\u%04X', ord $1)/ge; $s }
sub html { my $s = shift; $s =~ s/&/&amp;/g; $s }

my ($jsf) = glob('main-*.js');
open my $f, '<:encoding(UTF-8)', $jsf or die $!; my $s = <$f>; close $f;
die 'already done' if index($s, '"pastor-more"') >= 0;
$s =~ m{selectors:\[\["app-homepage"\]\],decls:(\d+),vars:10,consts:\[.*?dependencies:}s or die 'home';
my ($st, $len, $decls) = ($-[0], $+[0] - $-[0], $1);
my $h = substr($s, $st, $len);
my $ti = index($h, 'template:function');
my ($consts, $tpl) = (substr($h, 0, $ti), substr($h, $ti));
my ($inner) = $consts =~ m{consts:\[(.*)\],$}s or die 'consts';
my $n = 0; $n++ while $inner =~ m{\G\s*\[(?:[^\[\]"]|"(?:[^"\\]|\\.)*")*\],?}gc;
die 'count' unless pos($inner) == length($inner);
my ($KP, $KA) = ($n, $n + 1);
$consts =~ s{\],$}{,[1,"pastor-more"],["href","/pastors/#founder"]],} or die 'append';
$consts =~ s{decls:$decls}{'decls:' . ($decls - 3)}e or die 'decls';

$tpl =~ s{(d\(111,"Pastor Sajja Eliazer"\),u\(\),d\(112,)"[^"]*"}{$1"${\ jsq($P1)}"} or die 'p1';
$tpl =~ s{d\(114,"[^"]*"\)}{d(114,"${\ jsq($P2)}")} or die 'p2';
my $old = qr{c\(115,"p"\),d\(116,"[^"]*"\),u\(\),c\(117,"p"\),d\(118,"[^"]*"\),u\(\),c\(119,"p"\),d\(120,"[^"]*"\),u\(\)};
my $new = "c(115,\"p\",$KP)(116,\"a\",$KA),d(117,\"" . jsq($MORE) . '"),u()()';
my ($pre, undef, $post) = ($tpl =~ m{^(.*?)($old)(.*)$}s) or die 'block';
$post =~ s{\((\d+),"}{'(' . ($1 >= 121 ? $1 - 3 : $1) . ',"'}ge;
$post =~ s{d\((\d+),`}{'d(' . ($1 >= 121 ? $1 - 3 : $1) . ',`'}ge;
$tpl = $pre . $new . $post;
$tpl =~ s{t&2&&\(G\((\d+)\),J\("routerLink","/men"\)}{'t&2&&(G(' . ($1 - 3) . '),J("routerLink","/men")'}e or die 'G';
substr($s, $st, $len) = $consts . $tpl;
open my $o, '>:encoding(UTF-8)', $jsf or die $!; print $o $s; close $o;
print "app updated (decls ", $decls - 3, ")\n";

open my $in, '<:encoding(UTF-8)', 'index.html' or die $!; my $p = <$in>; close $in;
my $a = '_ngcontent-ng-c2813861141';
$p =~ s{(<span $a class="pastor-name">Pastor Sajja Eliazer</span>)[^<]*</p><p $a>[^<]*</p><p $a>[^<]*</p><p $a>[^<]*</p><p $a>[^<]*</p>}
       {$1${\ html($P1)}</p><p $a>${\ html($P2)}</p><p $a class="pastor-more"><a $a href="/pastors/#founder">$MORE</a></p>}s or die 'html';
open my $po, '>:encoding(UTF-8)', 'index.html' or die $!; print $po $p; close $po;
print "home page updated\n";
