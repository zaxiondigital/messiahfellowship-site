#!/usr/bin/perl
# Home: the "Family Blessing Prayer" banner (no longer held) becomes a
# "Worship with us on YouTube" feature in the same banner-card frame.
# Edits the compiled home template (12 slots -> 20, later slots +8) and the
# prerendered home HTML identically. Styles: cta-banner.css (.yt-card). Run once.
use strict; use warnings; use utf8;
local $/;
my $CH    = 'https://www.youtube.com/@MessiahFellowship';
my $LIVE  = "$CH/live";
my $SUB   = "$CH?sub_confirmation=1";
my $VIDS  = "$CH/videos";
my %T = (
  eyebrow => 'Live every Sunday',
  title   => 'Worship with us on YouTube',
  text    => 'Can’t be with us in person? Join our services live from anywhere in the world, and watch sermons, worship and church events any time.',
  times   => 'Sunday services: 8:00am · 10:30am · 6:00pm (India time)',
  live    => '▶ Watch Live',
  sub     => 'Subscribe',
  vids    => 'Browse all videos ›',
);
sub jsq { my $s = shift; $s =~ s/([^\x00-\x7f])/sprintf('\\u%04X', ord $1)/ge; $s }
sub html { my $s = shift; $s =~ s/&/&amp;/g; $s }

# ---------- compiled template ----------
my ($jsf) = glob('main-*.js');
open my $f, '<:encoding(UTF-8)', $jsf or die $!; my $s = <$f>; close $f;
die 'already done' if index($s, '"yt-card"') >= 0;
$s =~ m{selectors:\[\["app-homepage"\]\],decls:249,vars:10,consts:.*?dependencies:}s or die 'home not found';
my ($st, $len) = ($-[0], $+[0] - $-[0]);
my $h = substr($s, $st, $len);
my $ti = index($h, 'template:function');
my ($consts, $tpl) = (substr($h, 0, $ti), substr($h, $ti));

$consts =~ s{decls:249}{decls:257} or die 'decls';
$consts =~ s{\[1,"card","banner-card"\]}{[1,"card","banner-card","yt-card"]} or die 'c45';
$consts =~ s{\["src","images/family-blessing\.jpg","alt","Family Blessing Prayer",1,"card-tower"\]}{["src","images/about-img.jpg","alt","",1,"card-tower"]} or die 'c46';
$consts =~ s{\[1,"overlays"\]}{[1,"overlays","yt-content"]} or die 'c47';
# new consts appended: 78.. (current last index is 77)
my @new = (
  '[1,"yt-eyebrow"]',                                                                            # 78
  '[1,"yt-times"]',                                                                              # 79
  '[1,"yt-actions"]',                                                                            # 80
  qq{["href","$LIVE","target","_blank","rel","noopener",1,"yt-btn","yt-btn-live"]},              # 81
  qq{["href","$SUB","target","_blank","rel","noopener",1,"yt-btn","yt-btn-sub"]},                # 82
  qq{["href","$VIDS","target","_blank","rel","noopener",1,"yt-link"]},                          # 83
  qq{["href","$LIVE","target","_blank","rel","noopener","aria-label","Watch live on YouTube","tabindex","-1",1,"yt-play"]}, # 84
);
$consts =~ s{(\["src","images/vegetable-distribution\.jpg","alt","Vegetable Distribution"\])\]}{$1,${\ join(',', @new)}]} or die 'consts append';

# old block 151..162 -> new block 151..170
my $old = qr{c\(151,"div"\)\(152,"div",45\),g\(153,"img",46\),c\(154,"div",47\)\(155,"h3"\),d\(156,"Family Blessing Prayer"\),u\(\),c\(157,"p"\),d\(158,"[^"]*"\),g\(159,"br"\),d\(160,`[^`]*`\),u\(\),c\(161,"span"\),d\(162,"Friday 6:30pm"\),u\(\)\(\)\(\)\(\)};
my $newblk = join '',
  'c(151,"div")(152,"div",45),g(153,"img",46),c(154,"div",47)',
  '(155,"span",78),d(156,"', jsq($T{eyebrow}), '"),u(),',
  'c(157,"h3"),d(158,"', jsq($T{title}), '"),u(),',
  'c(159,"p"),d(160,"', jsq($T{text}), '"),u(),',
  'c(161,"p",79),d(162,"', jsq($T{times}), '"),u(),',
  'c(163,"div",80)(164,"a",81),d(165,"', jsq($T{live}), '"),u(),c(166,"a",82),d(167,"', jsq($T{sub}), '"),u()(),',
  'c(168,"a",83),d(169,"', jsq($T{vids}), '"),u()(),',
  'g(170,"a",84),u()()';   # closes yt-card (152) and its wrapper (151)
# shift everything after the block first (old numbers >= 163 -> +8)
$tpl =~ s{\((\d+),"}{'(' . ($1 >= 163 ? $1 + 8 : $1) . ',"'}ge;
$tpl =~ s{d\((\d+),`}{'d(' . ($1 >= 163 ? $1 + 8 : $1) . ',`'}ge;
$tpl =~ s{$old}{$newblk} or die 'block';
# bindings use relative jumps: prayer card (139) -> first outreach card (196, now 204)
$tpl =~ s{G\(57\),J\("routerLink","/widowcare"\)}{G(65),J("routerLink","/widowcare")} or die 'advance';
substr($s, $st, $len) = $consts . $tpl;
open my $o, '>:encoding(UTF-8)', $jsf or die $!; print $o $s; close $o;
print "app template updated\n";

# ---------- prerendered home ----------
open my $in, '<:encoding(UTF-8)', 'index.html' or die $!; my $p = <$in>; close $in;
my $a = '_ngcontent-ng-c2813861141';
$p =~ s{<div $a class="card banner-card"><img [^>]*family-blessing\.jpg[^>]*><div $a class="overlays">.*?</span></div></div>}{
  qq{<div $a class="card banner-card yt-card"><img loading="lazy" decoding="async" $a src="images/about-img.jpg" alt="" class="card-tower">}
. qq{<div $a class="overlays yt-content">}
. qq{<span $a class="yt-eyebrow">} . html($T{eyebrow}) . qq{</span>}
. qq{<h3 $a>} . html($T{title}) . qq{</h3>}
. qq{<p $a>} . html($T{text}) . qq{</p>}
. qq{<p $a class="yt-times">} . html($T{times}) . qq{</p>}
. qq{<div $a class="yt-actions"><a $a href="$LIVE" target="_blank" rel="noopener" class="yt-btn yt-btn-live">} . html($T{live}) . qq{</a>}
. qq{<a $a href="$SUB" target="_blank" rel="noopener" class="yt-btn yt-btn-sub">} . html($T{sub}) . qq{</a></div>}
. qq{<a $a href="$VIDS" target="_blank" rel="noopener" class="yt-link">} . html($T{vids}) . qq{</a></div>}
. qq{<a $a href="$LIVE" target="_blank" rel="noopener" aria-label="Watch live on YouTube" tabindex="-1" class="yt-play"></a></div>}
}se or die 'html block';
open my $po, '>:encoding(UTF-8)', 'index.html' or die $!; print $po $p; close $po;
print "home page updated\n";
