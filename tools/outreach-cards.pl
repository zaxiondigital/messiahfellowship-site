#!/usr/bin/perl
# Home "Community Outreach" carousel: 5 cards that match the Outreach menu
# (same names, same order, each opens its page). Was 3 cards incl. a
# "Clothes Distribution" card that led to a missing page.
# Edits the compiled home template (2 cards = 16 new slots, 2 bindings) and
# the prerendered home HTML identically. Run once.
use strict; use warnings;
local $/;
my @C = (   # [title, route, image, alt]
  ['WIDOW CARE MINISTRY',    '/widowcare',   'images/widowcare.jpg',              'Widow Care Ministry'],
  ['MEDICAL MINISTRY',       '/medical',     'images/freehealth.jpg',             'Medical Ministry'],
  ['FLOOD RELIEF',           '/floodrelief', 'images/flood-relief.png',           'Flood Relief'],
  ['KAMALA ARTS &amp; CRAFT','/kamalaarts',  'images/kamalaarts1.jpg',            'Kamala Arts &amp; Craft'],
  ['VEGETABLE DISTRIBUTION', '/vegetables',  'images/vegetable-distribution.jpg', 'Vegetable Distribution'],
);
sub js { my $s = shift; $s =~ s/&amp;/&/g; $s }

# ---------- compiled template ----------
my ($jsf) = glob('main-*.js');
open my $f, '<:raw', $jsf or die $!; my $s = <$f>; close $f;
die "already done" if index($s, 'J("routerLink","/vegetables")') >= 0;
$s =~ m{selectors:\[\["app-homepage"\]\],decls:233,vars:8,consts:.*?dependencies:}s or die 'home not found';
my ($st, $len) = ($-[0], $+[0] - $-[0]);
my $h = substr($s, $st, $len);
my $ti = index($h, 'template:function');
my ($consts, $tpl) = (substr($h, 0, $ti), substr($h, $ti));

$consts =~ s{decls:233,vars:8}{decls:249,vars:10} or die 'decls';
$consts =~ s{\["src","images/freehealth\.jpg","alt","[^"]*"\]}{["src","$C[0][2]","alt","${\ js($C[0][3])}"]} or die 'c63';
$consts =~ s{\["src","images/flood-relief\.png","alt","[^"]*"\]}{["src","$C[1][2]","alt","${\ js($C[1][3])}"]} or die 'c66';
$consts =~ s{\["src","images/cloth-distribution\.jpg","alt","[^"]*"\]}{["src","$C[2][2]","alt","${\ js($C[2][3])}"]} or die 'c67';
$consts =~ s{(\["src","images/hands\.png","alt","Prayer Hands"\])\]}{$1,["src","$C[3][2]","alt","${\ js($C[3][3])}"],["src","$C[4][2]","alt","${\ js($C[4][3])}"]]} or die 'c76';

# shift slots after the last card (>= 220) by 16
$tpl =~ s{\((\d+),"}{'(' . ($1 >= 220 ? $1 + 16 : $1) . ',"'}ge;
# titles
$tpl =~ s{d\(201,"FREE HEALTH CAMP"\)}{d(201,"${\ js($C[0][0])}")} or die 't1';
$tpl =~ s{d\(209,"FLOOD RELIEF CAMP"\)}{d(209,"${\ js($C[1][0])}")} or die 't2';
$tpl =~ s{d\(217,"CLOTHES DISTRIBUTION"\)}{d(217,"${\ js($C[2][0])}")} or die 't3';
# two new cards after the third
my $card = sub { my ($b, $img, $t) = @_;
  sprintf ',c(%d,"div",62),g(%d,"img",%d)(%d,"div",64),c(%d,"div",65)(%d,"span"),d(%d,"%s"),u(),c(%d,"a"),d(%d,"Know More \u203A"),u()()()',
    $b, $b+1, $img, $b+2, $b+3, $b+4, $b+5, $t, $b+6, $b+7 };
my $new = $card->(220, 76, js($C[3][0])) . $card->(228, 77, js($C[4][0]));
$tpl =~ s{(d\(219,"Know More \x5cu203A"\),u\(\)\(\)\(\))}{$1$new} or die 'insert';
# links
$tpl =~ s{G\(57\),J\("routerLink","/medical"\),G\(8\),J\("routerLink","/floodrelief"\),G\(8\),J\("routerLink","/Clothes"\)}
         {G(57),J("routerLink","$C[0][1]"),G(8),J("routerLink","$C[1][1]"),G(8),J("routerLink","$C[2][1]"),G(8),J("routerLink","$C[3][1]"),G(8),J("routerLink","$C[4][1]")} or die 'bindings';
substr($s, $st, $len) = $consts . $tpl;
open my $o, '>:raw', $jsf or die $!; print $o $s; close $o;
print "app template updated\n";

# ---------- prerendered home ----------
open my $in, '<:raw', 'index.html' or die $!; my $p = <$in>; close $in;
$p =~ m{(<div (_ngcontent-ng-c\d+) class="outreach-grid">)(.*?)(</div></div></section>)}s or die 'grid';
my ($open, $att, $inner, $close) = ($1, $2, $3, $4);
my @cards = $inner =~ m{(<div \Q$att\E class="outreach-card" tabindex="0">.*?Know More ›</a></div></div>)}gs;
die 'expected 3 cards, got ' . scalar(@cards) unless @cards == 3;
my $tmpl = $cards[0];
my $out = '';
for my $c (@C) {
  my $x = $tmpl;
  $x =~ s{src="[^"]*"}{src="$c->[2]"};
  $x =~ s{alt="[^"]*"}{alt="$c->[3]"};
  $x =~ s{<span \Q$att\E>[^<]*</span>}{<span $att>$c->[0]</span>};
  $out .= $x;
}
$p =~ s{\Q$open$inner\E}{$open$out} or die 'replace';
open my $po, '>:raw', 'index.html' or die $!; print $po $p; close $po;
print "home page updated\n";
