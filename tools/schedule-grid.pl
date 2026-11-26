#!/usr/bin/perl
# Home: the 3 gold service boxes + the "Also: …" sentence become one schedule
# grid of 6 cards (day → time → name): Sunday ×3 (gold) and weekday ×3 (outlined).
# Template: slots 25–42 (18) → 25–67 (43); later slots +25, first G jump +25,
# decls +25. Heading "Three Powerful Sunday Worship Services" → "Service Times".
use strict; use warnings; use utf8;
local $/;
my @CARDS = (
  [1, 'Sunday',    '8:00 AM',      'First Service'],
  [1, 'Sunday',    '10:30 AM',     'Second Service'],
  [1, 'Sunday',    '6:00 PM',      'Third Service'],
  [0, 'Wednesday', '5:00 AM',      'Men’s Morning Prayer'],
  [0, 'Friday',    '6:30 PM',      'Family Prayer'],
  [0, 'Every day', '7 AM – 7 PM',  'Prayer Tower'],
);
my $HEAD = 'Service Times';
sub jsq { my $s = shift; $s =~ s/([^\x00-\x7f])/sprintf('\\u%04X', ord $1)/ge; $s }

my ($jsf) = glob('main-*.js');
open my $f, '<:encoding(UTF-8)', $jsf or die $!; my $s = <$f>; close $f;
die 'already done' if index($s, '"svc-time"') >= 0;
$s =~ m{selectors:\[\["app-homepage"\]\],decls:(\d+),vars:10,consts:\[.*?dependencies:}s or die 'home';
my ($st, $len, $decls) = ($-[0], $+[0] - $-[0], $1);
my $h = substr($s, $st, $len);
my $ti = index($h, 'template:function');
my ($consts, $tpl) = (substr($h, 0, $ti), substr($h, $ti));

my ($inner) = $consts =~ m{consts:\[(.*)\],$}s or die 'consts';
my $n = 0; $n++ while $inner =~ m{\G\s*\[(?:[^\[\]"]|"(?:[^"\\]|\\.)*")*\],?}gc;
die 'count' unless pos($inner) == length($inner);
my ($KS, $KW, $KD, $KT, $KN) = ($n, $n + 1, $n + 2, $n + 3, $n + 4);
$consts =~ s{\],$}{,[1,"service-card","is-sunday"],[1,"service-card","is-week"],[1,"svc-day"],[1,"svc-time"],[1,"svc-name"]],} or die 'append';
$consts =~ s{decls:$decls}{'decls:' . ($decls + 25)}e or die 'decls';

my $old = qr{c\(25,"div",6\)\(26,"div",7\).*?d\(42,"[^"]*"\),u\(\),(?=c\(43,"p",8\))}s;
my $blk = 'c(25,"div",6)';
my $b = 26;
for my $i (0 .. $#CARDS) {
  my ($sun, $day, $time, $name) = @{$CARDS[$i]};
  $blk .= ($i == 0 ? '' : ',c') . "($b,\"div\"," . ($sun ? $KS : $KW) . ')'
        . '(' . ($b + 1) . ",\"span\",$KD),d(" . ($b + 2) . ',"' . jsq($day) . '"),u(),'
        . 'c(' . ($b + 3) . ",\"strong\",$KT),d(" . ($b + 4) . ',"' . jsq($time) . '"),u(),'
        . 'c(' . ($b + 5) . ",\"span\",$KN),d(" . ($b + 6) . ',"' . jsq($name) . '"),u()()';
  $b += 7;
}
$blk .= '(),';                                             # close .services
die "slot math" unless $b == 68;
my ($pre, undef, $post) = ($tpl =~ m{^(.*?)($old)(.*)$}s) or die 'block';
$post =~ s{\((\d+),"}{'(' . ($1 >= 43 ? $1 + 25 : $1) . ',"'}ge;
$post =~ s{d\((\d+),`}{'d(' . ($1 >= 43 ? $1 + 25 : $1) . ',`'}ge;
$pre =~ s{d\(24," Three Powerful Sunday Worship Services "\)}{d(24," $HEAD ")} or die 'head';
$tpl = $pre . $blk . $post;
$tpl =~ s{t&2&&\(G\(106\)}{t&2&&(G(131)} or die 'G';
substr($s, $st, $len) = $consts . $tpl;
open my $o, '>:encoding(UTF-8)', $jsf or die $!; print $o $s; close $o;
print "app updated (consts $KS-$KN, decls ", $decls + 25, ")\n";

# ---------- prerendered home ----------
open my $in, '<:encoding(UTF-8)', 'index.html' or die $!; my $p = <$in>; close $in;
my $a = '_ngcontent-ng-c2813861141';
my $html = qq{<div $a class="sub-heading"> $HEAD </div><div $a class="services">};
for my $c (@CARDS) {
  my ($sun, $day, $time, $name) = @$c;
  (my $hn = $name) =~ s/&/&amp;/g;
  $html .= qq{<div $a class="service-card } . ($sun ? 'is-sunday' : 'is-week') . qq{"><span $a class="svc-day">$day</span><strong $a class="svc-time">$time</strong><span $a class="svc-name">$hn</span></div>};
}
$html .= '</div>';
$p =~ s{<div $a class="sub-heading">.*?<p $a class="services-more">[^<]*</p>}{$html}s or die 'html';
open my $po, '>:encoding(UTF-8)', 'index.html' or die $!; print $po $p; close $po;
print "home page updated\n";
