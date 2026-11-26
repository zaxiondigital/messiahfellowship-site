#!/usr/bin/perl
# Home de-clutter (each fact said once):
#  1. welcome bar: drop the gold "Messiah Fellowship · Vijayawada" label; line = address only;
#     buttons = "Service Times" (scrolls to the schedule) + Get Directions (Watch Live stays in the header)
#  2. under the 3 Sunday service cards: one line with the weekday meetings
#  3. top bar: only Sunday + Prayer Tower (Wednesday / Friday spans removed) – header template
#  4. YouTube section: "Sunday services: 8:00am · …" -> "Streamed live from Vijayawada · India time (IST)"
# Home: label (2 slots) out, schedule line (2 slots) in → later slots unchanged.
# Header: 10 slots out → later slots -10, first G jump -10, decls -10. Run once.
use strict; use warnings; use utf8;
local $/;
my %T = (
  addr  => '100 Feet Road, Autonagar Gate, Vijayawada',
  svc   => 'Service Times',
  more  => 'Also: Men’s prayer Wed 5:00am · Family prayer Fri 6:30pm · Prayer Tower daily 7:00am–7:00pm',
  yt    => 'Streamed live from Vijayawada · India time (IST)',
);
sub jsq { my $s = shift; $s =~ s/([^\x00-\x7f])/sprintf('\\u%04X', ord $1)/ge; $s }
sub html { my $s = shift; $s =~ s/&/&amp;/g; $s }

my ($jsf) = glob('main-*.js');
open my $f, '<:encoding(UTF-8)', $jsf or die $!; my $s = <$f>; close $f;
die 'already done' if index($s, '"services-more"') >= 0;

# ================= home =================
$s =~ m{selectors:\[\["app-homepage"\]\],decls:273,vars:10,consts:\[.*?dependencies:}s or die 'home';
my ($st, $len) = ($-[0], $+[0] - $-[0]);
my $h = substr($s, $st, $len);
my $ti = index($h, 'template:function');
my ($consts, $tpl) = (substr($h, 0, $ti), substr($h, $ti));
# consts: services button replaces the live button; new const for the schedule line
$consts =~ s{\["href","https://www\.youtube\.com/\@MessiahFellowship/live","target","_blank","rel","noopener",1,"hero-btn","hero-btn-live"\]}
            {["href","#services",1,"hero-btn","hero-btn-services"]} or die 'c98';
my ($inner) = $consts =~ m{consts:\[(.*)\],$}s or die 'consts';
my $count = 0; $count++ while $inner =~ m{\G\s*\[(?:[^\[\]"]|"(?:[^"\\]|\\.)*")*\],?}gc;
die 'count' unless pos($inner) == length($inner);
my $K = $count;                                   # index of the new const
$consts =~ s{\],$}{,[1,"services-more"]],} or die 'append';

$tpl =~ s{\(6,"span",94\),d\(7,"[^"]*"\),u\(\),c\(8,"p",95\)}{(6,"p",95)} or die 'label';   # 5 now starts the title directly
# renumber 9..42 by -2 (the label's 2 slots)
$tpl =~ s{(?<![A-Za-z0-9_\$])(c|g|d)\((\d+)(?=[,)])}{"$1(" . (($2 >= 9 && $2 <= 42) ? $2 - 2 : $2)}ge;
$tpl =~ s{\)\((\d+),}{')(' . (($1 >= 9 && $1 <= 42) ? $1 - 2 : $1) . ','}ge;
$tpl =~ s{d\(\d+,"Join us this Sunday"\)}{d(7,"Join us this Sunday")} or die 'title';
$tpl =~ s{d\(9,"Worship at [^"]*"\)}{'d(9,"' . jsq($T{addr}) . '")'}e or die 'addr';
$tpl =~ s{d\(12,"\\u25B6 Watch Live"\)}{'d(12,"' . jsq($T{svc}) . '")'}e or die 'btn';
$tpl =~ s{(d\(40,"\@ 6:00pm"\),u\(\)\(\)\(\),)}{$1 . "c(41,\"p\",$K),d(42,\"" . jsq($T{more}) . '"),u(),'}e or die 'more';
$tpl =~ s{d\(174,"Sunday services:[^"]*"\)}{'d(174,"' . jsq($T{yt}) . '")'}e or die 'yt';
substr($s, $st, $len) = $consts . $tpl;

# ================= header =================
$s =~ m{selectors:\[\["app-header"\]\],decls:75,vars:2,.*?dependencies:}s or die 'header';
($st, $len) = ($-[0], $+[0] - $-[0]);
$h = substr($s, $st, $len);
$h =~ s{decls:75}{decls:65} or die 'hdecls';
$h =~ s{,c\(5,"span"\),d\(6,""\),c\(7,"b"\),d\(8,"Wednesday:"\),u\(\),d\(9,"[^"]*"\),u\(\),c\(10,"span"\),d\(11,""\),c\(12,"b"\),d\(13,"Friday:"\),u\(\),d\(14,"[^"]*"\),u\(\)}{} or die 'spans';
my $ht = index($h, 'template:function');
my ($hh, $htp) = (substr($h, 0, $ht), substr($h, $ht));
$htp =~ s{(?<![A-Za-z0-9_\$])(c|g|d|It|dt)\((\d+)(?=[,)])}{"$1(" . ($2 >= 15 ? $2 - 10 : $2)}ge;
$htp =~ s{\)\((\d+),}{')(' . ($1 >= 15 ? $1 - 10 : $1) . ','}ge;
$htp =~ s{t&2&&\(G\(25\)}{t&2&&(G(15)} or die 'hG';
substr($s, $st, $len) = $hh . $htp;

open my $o, '>:encoding(UTF-8)', $jsf or die $!; print $o $s; close $o;
print "app updated (schedule const $K)\n";

# ================= pages =================
my $ha = '_ngcontent-ng-c2813861141';
for my $p (glob('*/index.html'), 'index.html') {
  open my $in, '<:encoding(UTF-8)', $p or die $!; my $x = <$in>; close $in;
  my $c = 0;
  $c += ($x =~ s{<span (_ngcontent-ng-c\d+)><!--ngetn--><b \1>Wednesday:</b>[^<]*</span><span \1><!--ngetn--><b \1>Friday:</b>[^<]*</span>}{}g);
  if ($p eq 'index.html') {
    $x =~ s{<span $ha class="hero-eyebrow">[^<]*</span>}{} or die 'h label';
    $x =~ s{(<p $ha class="hero-times">)[^<]*(</p>)}{$1 . html($T{addr}) . $2}e or die 'h addr';
    $x =~ s{<a $ha href="https://www\.youtube\.com/\@MessiahFellowship/live" target="_blank" rel="noopener" class="hero-btn hero-btn-live">[^<]*</a>}
           {<a $ha href="#services" class="hero-btn hero-btn-services">$T{svc}</a>} or die 'h btn';
    $x =~ s{(Third Service</span><strong $ha>\@ 6:00pm</strong></div></div>)}{$1<p $ha class="services-more">${\ html($T{more})}</p>} or die 'h more';
    $x =~ s{(<p $ha class="yt-times">)[^<]*(</p>)}{$1 . html($T{yt}) . $2}e or die 'h yt';
    $c++;
  }
  next unless $c;
  open my $out, '>:encoding(UTF-8)', $p or die $!; print $out $x; close $out;
  print "$p: $c\n";
}
