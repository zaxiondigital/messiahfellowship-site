#!/usr/bin/perl
# Home hero: a welcome bar on the video (who · when · where + Watch Live / Get Directions).
#   <div.hero-video> <video/> <div.hero-bar> [div.hero-bar-text span p p] [div.hero-bar-actions a a] </div>
# New slots 4..16 right after the video (later slots +13, first binding jump +13,
# decls +13); the prerendered home HTML gets the same markup. Styles: header.css (.hero-bar).
use strict; use warnings; use utf8;
local $/;
my $LIVE = 'https://www.youtube.com/@MessiahFellowship/live';
my $MAPS = 'https://www.google.com/maps/search/?api=1&query=Messiah+Fellowship+Autonagar+Gate+Vijayawada';
my %T = (
  eyebrow => 'Messiah Fellowship · Vijayawada',
  title   => 'Join us this Sunday',
  times   => 'Worship at 8:00am, 10:30am & 6:00pm · 100 Feet Road, Autonagar Gate',
  live    => '▶ Watch Live',
  dir     => 'Get Directions',
);
sub jsq { my $s = shift; $s =~ s/([^\x00-\x7f])/sprintf('\\u%04X', ord $1)/ge; $s }
sub html { my $s = shift; $s =~ s/&/&amp;/g; $s }

# ---------- compiled template ----------
my ($jsf) = glob('main-*.js');
open my $f, '<:encoding(UTF-8)', $jsf or die $!; my $s = <$f>; close $f;
die 'already done' if index($s, '"hero-bar"') >= 0;
$s =~ m{selectors:\[\["app-homepage"\]\],decls:(\d+),vars:10,consts:\[.*?dependencies:}s or die 'home';
my ($st, $len, $decls) = ($-[0], $+[0] - $-[0], $1);
my $h = substr($s, $st, $len);
my $ti = index($h, 'template:function');
my ($consts, $tpl) = (substr($h, 0, $ti), substr($h, $ti));

# new consts appended after the current last one
my ($inner) = $consts =~ m{consts:\[(.*)\],$}s or die 'consts';
my $count = 0; $count++ while $inner =~ m{\G\s*\[(?:[^\[\]"]|"(?:[^"\\]|\\.)*")*\],?}gc;
die "could not count consts" unless pos($inner) && pos($inner) == length($inner);
my @new = ('[1,"hero-video"]', '[1,"hero-bar"]', '[1,"hero-bar-text"]', '[1,"hero-eyebrow"]', '[1,"hero-title"]', '[1,"hero-times"]',
           '[1,"hero-bar-actions"]',
           qq{["href","$LIVE","target","_blank","rel","noopener",1,"hero-btn","hero-btn-live"]},
           qq{["href","$MAPS","target","_blank","rel","noopener",1,"hero-btn","hero-btn-dir"]});
my %K; my @names = qw(video bar text eyebrow title times actions live dir);
@K{@names} = map { $count + $_ } 0 .. $#names;
$consts =~ s{\],$}{,${\ join(',', @new)}],} or die 'append';
$consts =~ s{decls:$decls}{'decls:' . ($decls + 13)}e or die 'decls';

my $old = qr{c\(0,"div"\)\(1,"video",0\),g\(2,"source",1\),d\(3,`[^`]*`\),u\(\)\(\)};
my ($vid) = $tpl =~ m{($old)} or die 'video';
(my $vid2 = $vid) =~ s{^c\(0,"div"\)}{c(0,"div",$K{video})};
$vid2 =~ s{u\(\)\(\)$}{u(),};                                   # close video only; the wrapper stays open
my $bar = join '',
  "c(4,\"div\",$K{bar})(5,\"div\",$K{text})(6,\"span\",$K{eyebrow}),d(7,\"", jsq($T{eyebrow}), '"),u(),',
  "c(8,\"p\",$K{title}),d(9,\"", jsq($T{title}), '"),u(),',
  "c(10,\"p\",$K{times}),d(11,\"", jsq($T{times}), '"),u()(),',
  "c(12,\"div\",$K{actions})(13,\"a\",$K{live}),d(14,\"", jsq($T{live}), '"),u(),',
  "c(15,\"a\",$K{dir}),d(16,\"", jsq($T{dir}), '"),u()()()()';  # dir, actions, bar, wrapper
my ($pre, undef, $post) = ($tpl =~ m{^(.*?)($old)(.*)$}s);
$post =~ s{\((\d+),"}{'(' . ($1 >= 4 ? $1 + 13 : $1) . ',"'}ge;
$post =~ s{d\((\d+),`}{'d(' . ($1 >= 4 ? $1 + 13 : $1) . ',`'}ge;
$tpl = $pre . $vid2 . $bar . $post;
$tpl =~ s{t&2&&\(G\(93\)}{t&2&&(G(106)} or die 'first G';
substr($s, $st, $len) = $consts . $tpl;
open my $o, '>:encoding(UTF-8)', $jsf or die $!; print $o $s; close $o;
print "app template updated (consts $K{video}-$K{dir}, decls ", $decls + 13, ")\n";

# ---------- prerendered home ----------
open my $in, '<:encoding(UTF-8)', 'index.html' or die $!; my $p = <$in>; close $in;
my $a = '_ngcontent-ng-c2813861141';
my $barhtml = qq{<div $a class="hero-bar"><div $a class="hero-bar-text">}
  . qq{<span $a class="hero-eyebrow">} . html($T{eyebrow}) . '</span>'
  . qq{<p $a class="hero-title">} . html($T{title}) . '</p>'
  . qq{<p $a class="hero-times">} . html($T{times}) . '</p></div>'
  . qq{<div $a class="hero-bar-actions"><a $a href="$LIVE" target="_blank" rel="noopener" class="hero-btn hero-btn-live">} . html($T{live}) . '</a>'
  . qq{<a $a href="${\ html($MAPS)}" target="_blank" rel="noopener" class="hero-btn hero-btn-dir">} . html($T{dir}) . '</a></div></div>';
$p =~ s{(<app-homepage [^>]*>)<div $a>(<video .*?</video>)</div>}{$1<div $a class="hero-video">$2$barhtml</div>}s or die 'html';
open my $po, '>:encoding(UTF-8)', 'index.html' or die $!; print $po $p; close $po;
print "home page updated\n";
