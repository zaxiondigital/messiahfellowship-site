#!/usr/bin/perl
# Home: move "Worship with us on YouTube" out of the maroon "A Place to Grow
# in Faith" section into its own light section right after it:
#   <section.yt-section> <div.yt-wrap> [div.yt-text ...] [a.yt-media img + play + badge]
# Slots stay in creation order (151..173 instead of 151..170, later +3).
# Run once, after tools/youtube-section.pl. Styles: cta-banner.css (.yt-section).
use strict; use warnings; use utf8;
local $/;
my $CH = 'https://www.youtube.com/@MessiahFellowship';
my %T = (
  eyebrow => 'Live every Sunday',
  title   => 'Worship with us on YouTube',
  text    => 'Can’t be with us in person? Join our services live from anywhere in the world, and watch sermons, worship and church events any time.',
  times   => 'Sunday services: 8:00am · 10:30am · 6:00pm (India time)',
  live    => '▶ Watch Live',
  sub     => 'Subscribe',
  vids    => 'Browse all videos ›',
  badge   => '2,500+ videos · 38K+ subscribers',
);
sub jsq { my $s = shift; $s =~ s/([^\x00-\x7f])/sprintf('\\u%04X', ord $1)/ge; $s }
sub html { my $s = shift; $s =~ s/&/&amp;/g; $s }

# ---------- compiled template ----------
my ($jsf) = glob('main-*.js');
open my $f, '<:encoding(UTF-8)', $jsf or die $!; my $s = <$f>; close $f;
die 'already done' if index($s, '"yt-section"') >= 0;
$s =~ m{selectors:\[\["app-homepage"\]\],decls:257,vars:10,consts:.*?dependencies:}s or die 'home';
my ($st, $len) = ($-[0], $+[0] - $-[0]);
my $h = substr($s, $st, $len);
my $ti = index($h, 'template:function');
my ($consts, $tpl) = (substr($h, 0, $ti), substr($h, $ti));

$consts =~ s{decls:257}{decls:260} or die 'decls';
# 84 (old play link) becomes the media link; new consts 85..90
$consts =~ s{\["href","\Q$CH\E/live","target","_blank","rel","noopener","aria-label","Watch live on YouTube","tabindex","-1",1,"yt-play"\]}
            {["href","$CH/live","target","_blank","rel","noopener","aria-label","Watch the live service on YouTube",1,"yt-media"]} or die 'c84';
my @new = ('[1,"yt-section"]', '[1,"yt-wrap"]', '[1,"yt-text"]',
           '["src","images/about-img.jpg","alt","",1,"yt-thumb"]', '[1,"yt-play"]', '[1,"yt-badge"]');   # 85..90
$consts =~ s{(\[1,"yt-eyebrow"\],\[1,"yt-times"\],\[1,"yt-actions"\],\[[^\]]*"yt-btn-live"\],\[[^\]]*"yt-btn-sub"\],\[[^\]]*"yt-link"\],\[[^\]]*"yt-media"\])\]}
            {$1,${\ join(',', @new)}]} or die 'consts';

my $old = qr{g\(150,"br"\),c\(151,"div"\)\(152,"div",45\),g\(153,"img",46\),c\(154,"div",47\).*?g\(170,"a",84\),u\(\)\(\)\(\)\(\),c\(171,"section",48\)}s;
my $new = join '',
  'g(150,"br"),u()(),',                                         # close the cards' container + ministries section
  'c(151,"section",85)(152,"div",86)(153,"div",87)',
  '(154,"span",78),d(155,"', jsq($T{eyebrow}), '"),u(),',
  'c(156,"h2"),d(157,"', jsq($T{title}), '"),u(),',
  'c(158,"p"),d(159,"', jsq($T{text}), '"),u(),',
  'c(160,"p",79),d(161,"', jsq($T{times}), '"),u(),',
  'c(162,"div",80)(163,"a",81),d(164,"', jsq($T{live}), '"),u(),c(165,"a",82),d(166,"', jsq($T{sub}), '"),u()(),',
  'c(167,"a",83),d(168,"', jsq($T{vids}), '"),u()(),',          # close link + yt-text
  'c(169,"a",84),g(170,"img",88)(171,"span",89),c(172,"span",90),d(173,"', jsq($T{badge}), '"),u()(),',   # badge, media link
  'u()(),',                                                     # yt-wrap, yt-section
  'c(174,"section",48)';
# shift everything after the old block (>= 171) by 3 first
my ($pre, $blk, $post) = ($tpl =~ m{^(.*?)($old)(.*)$}s) or die 'block';
$post =~ s{\((\d+),"}{'(' . ($1 >= 171 ? $1 + 3 : $1) . ',"'}ge;
$post =~ s{d\((\d+),`}{'d(' . ($1 >= 171 ? $1 + 3 : $1) . ',`'}ge;
$tpl = $pre . $new . $post;
# relative jump from the prayer card (139) to the first outreach card (204 -> 207)
$tpl =~ s{G\(65\),J\("routerLink","/widowcare"\)}{G(68),J("routerLink","/widowcare")} or die 'advance';
substr($s, $st, $len) = $consts . $tpl;
open my $o, '>:encoding(UTF-8)', $jsf or die $!; print $o $s; close $o;
print "app template updated\n";

# ---------- prerendered home ----------
open my $in, '<:encoding(UTF-8)', 'index.html' or die $!; my $p = <$in>; close $in;
my $a = '_ngcontent-ng-c2813861141';
my $L = "$CH/live";
my $sec = qq{<section $a class="yt-section"><div $a class="yt-wrap"><div $a class="yt-text">}
  . qq{<span $a class="yt-eyebrow">} . html($T{eyebrow}) . '</span>'
  . qq{<h2 $a>} . html($T{title}) . '</h2>'
  . qq{<p $a>} . html($T{text}) . '</p>'
  . qq{<p $a class="yt-times">} . html($T{times}) . '</p>'
  . qq{<div $a class="yt-actions"><a $a href="$L" target="_blank" rel="noopener" class="yt-btn yt-btn-live">} . html($T{live}) . '</a>'
  . qq{<a $a href="$CH?sub_confirmation=1" target="_blank" rel="noopener" class="yt-btn yt-btn-sub">} . html($T{sub}) . '</a></div>'
  . qq{<a $a href="$CH/videos" target="_blank" rel="noopener" class="yt-link">} . html($T{vids}) . '</a></div>'
  . qq{<a $a href="$L" target="_blank" rel="noopener" aria-label="Watch the live service on YouTube" class="yt-media">}
  . qq{<img loading="lazy" decoding="async" $a src="images/about-img.jpg" alt="" class="yt-thumb"><span $a class="yt-play"></span>}
  . qq{<span $a class="yt-badge">} . html($T{badge}) . '</span></a></div></section>';
$p =~ s{<div $a><div $a class="card banner-card yt-card">.*?class="yt-play"></a></div></div>(</div></section>)}{$1$sec}s or die 'html';
open my $po, '>:encoding(UTF-8)', 'index.html' or die $!; print $po $p; close $po;
print "home page updated\n";
