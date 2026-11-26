#!/usr/bin/perl
# Home: "Telugu Christian Matrimony" feature section between YouTube and the
# Bible College / Outreach section. 25 new slots at S (the next section's
# start) → later slots +25, the binding jump into the outreach cards +25,
# decls +25. Links are plain (/matrimony/ is a static page; tel: for the call).
use strict; use warnings; use utf8;
local $/;
my %T = (
  tag   => 'New · Free service',
  title => 'Telugu Christian Matrimony',
  te    => 'ఉచిత క్రైస్తవ వివాహ పరిచయ వేదిక',
  text  => 'A free marriage introduction service at the church, helping Telugu Christian families find a life partner who shares their faith.',
  p1 => 'Free of cost', p2 => 'Open to all castes', p3 => 'Drives held at the church',
  more  => 'Learn more',
  call  => 'Call 9494 7676 33',
);
sub jsq { my $s = shift; $s =~ s/([^\x00-\x7f])/sprintf('\\u%04X', ord $1)/ge; $s }
sub html { my $s = shift; $s =~ s/&/&amp;/g; $s }

my ($jsf) = glob('main-*.js');
open my $f, '<:encoding(UTF-8)', $jsf or die $!; my $s = <$f>; close $f;
die 'already done' if index($s, '"mt-home"') >= 0;
$s =~ m{selectors:\[\["app-homepage"\]\],decls:(\d+),vars:10,consts:\[.*?dependencies:}s or die 'home';
my ($st, $len, $decls) = ($-[0], $+[0] - $-[0], $1);
my $h = substr($s, $st, $len);
my $ti = index($h, 'template:function');
my ($consts, $tpl) = (substr($h, 0, $ti), substr($h, $ti));
my ($inner) = $consts =~ m{consts:\[(.*)\],$}s or die 'consts';
my $n = 0; $n++ while $inner =~ m{\G\s*\[(?:[^\[\]"]|"(?:[^"\\]|\\.)*")*\],?}gc;
die 'count' unless pos($inner) == length($inner);
my @new = ('[1,"mt-home"]', '[1,"mt-home-card"]', '[1,"mt-home-text"]', '[1,"mt-home-tag"]',
           '["lang","te",1,"mt-home-te"]', '[1,"mt-home-points"]', '[1,"mt-home-actions"]',
           '["href","/matrimony/",1,"mt-btn","mt-btn-primary"]', '["href","tel:+919494767633",1,"mt-btn","mt-btn-outline"]',
           '[1,"mt-home-media"]', '["src","images/matrimony-hero.jpg","alt","Wedding rings on an open Bible",1,"mt-home-img"]');
my %K; my @nm = qw(sec card text tag te points actions more call media img);
@K{@nm} = map { $n + $_ } 0 .. $#nm;
$consts =~ s{\],$}{,${\ join(',', @new)}],} or die 'append';
$consts =~ s{decls:$decls}{'decls:' . ($decls + 25)}e or die 'decls';

$tpl =~ m{d\(\d+,"2,500\+ videos[^"]*"\),u\(\)\(\),u\(\)\(\),c\((\d+),"section",48\)} or die 'anchor';
my $S = $1;
my $b = sub { $S + shift };
my $blk = join '',
  "c(", $b->(0), ",\"section\",$K{sec})(", $b->(1), ",\"div\",$K{card})(", $b->(2), ",\"div\",$K{text})",
  "(", $b->(3), ",\"span\",$K{tag}),d(", $b->(4), ',"', jsq($T{tag}), '"),u(),',
  "c(", $b->(5), ",\"h2\"),d(", $b->(6), ',"', jsq($T{title}), '"),u(),',
  "c(", $b->(7), ",\"p\",$K{te}),d(", $b->(8), ',"', jsq($T{te}), '"),u(),',
  "c(", $b->(9), ",\"p\"),d(", $b->(10), ',"', jsq($T{text}), '"),u(),',
  "c(", $b->(11), ",\"ul\",$K{points})(", $b->(12), ",\"li\"),d(", $b->(13), ',"', jsq($T{p1}), '"),u(),',
  "c(", $b->(14), ",\"li\"),d(", $b->(15), ',"', jsq($T{p2}), '"),u(),',
  "c(", $b->(16), ",\"li\"),d(", $b->(17), ',"', jsq($T{p3}), '"),u()(),',
  "c(", $b->(18), ",\"div\",$K{actions})(", $b->(19), ",\"a\",$K{more}),d(", $b->(20), ',"', jsq($T{more}), '"),u(),',
  "c(", $b->(21), ",\"a\",$K{call}),d(", $b->(22), ',"', jsq($T{call}), '"),u()()(),',     # call, actions, text
  "c(", $b->(23), ",\"div\",$K{media}),g(", $b->(24), ",\"img\",$K{img}),u()()(),";       # media, card, section
my $mark = "c($S,\"section\",48)";
my $at = index($tpl, $mark); die 'mark' if $at < 0;
my ($pre, $post) = (substr($tpl, 0, $at), substr($tpl, $at));
$post =~ s{\((\d+),"}{'(' . ($1 >= $S ? $1 + 25 : $1) . ',"'}ge;
$post =~ s{d\((\d+),`}{'d(' . ($1 >= $S ? $1 + 25 : $1) . ',`'}ge;
$tpl = $pre . $blk . $post;
$tpl =~ s{J\("routerLink","/prayer"\),G\((\d+)\),J\("routerLink","/widowcare"\)}{'J("routerLink","/prayer"),G(' . ($1 + 25) . '),J("routerLink","/widowcare")'}e or die 'G';
substr($s, $st, $len) = $consts . $tpl;
open my $o, '>:encoding(UTF-8)', $jsf or die $!; print $o $s; close $o;
print "app updated (section at slot $S, consts $K{sec}-$K{img}, decls ", $decls + 25, ")\n";

open my $in, '<:encoding(UTF-8)', 'index.html' or die $!; my $p = <$in>; close $in;
my $a = '_ngcontent-ng-c2813861141';
my $sec = qq{<section $a class="mt-home"><div $a class="mt-home-card"><div $a class="mt-home-text">}
  . qq{<span $a class="mt-home-tag">} . html($T{tag}) . '</span>'
  . qq{<h2 $a>} . html($T{title}) . '</h2>'
  . qq{<p $a lang="te" class="mt-home-te">$T{te}</p>}
  . qq{<p $a>} . html($T{text}) . '</p>'
  . qq{<ul $a class="mt-home-points"><li $a>$T{p1}</li><li $a>$T{p2}</li><li $a>$T{p3}</li></ul>}
  . qq{<div $a class="mt-home-actions"><a $a href="/matrimony/" class="mt-btn mt-btn-primary">$T{more}</a><a $a href="tel:+919494767633" class="mt-btn mt-btn-outline">$T{call}</a></div></div>}
  . qq{<div $a class="mt-home-media"><img $a src="images/matrimony-hero.jpg" alt="Wedding rings on an open Bible" class="mt-home-img"></div></div></section>};
$p =~ s{(yt-badge">[^<]*</span></a></div></section>)(<section $a class="outreach-section">)}{$1$sec$2} or die 'html';
open my $po, '>:encoding(UTF-8)', 'index.html' or die $!; print $po $p; close $po;
print "home page updated\n";
