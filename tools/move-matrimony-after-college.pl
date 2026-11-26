#!/usr/bin/perl
# Home: order Bible College → Matrimony → Community Outreach.
# The Bible College box lives inside .outreach-section > .container, so the
# matrimony <section> (slots 209–233) moves to just after the college box.
# New creation order: outreach section + container + college box (old 234–249 → 209–224),
# then matrimony (old 209–233 → 225–249); 250+ unchanged. Total slots and the
# binding jumps stay the same. Run once.
use strict; use warnings;
local $/;
my ($jsf) = glob('main-*.js');
open my $f, '<:raw', $jsf or die $!; my $s = <$f>; close $f;
my $M_re = qr{c\(209,"section",108\).*?g\(233,"img",118\),u\(\)\(\)\(\),}s;
my $P_re = qr{c\(234,"section",48\).*?d\(249,"APPLY FOR ADMISSION"\),u\(\)\(\)\(\),}s;
$s =~ m{($M_re)($P_re)} or die 'blocks not found (already moved?)';
my ($M, $P) = ($1, $2);
my ($at, $len) = ($-[0], $+[0] - $-[0]);
sub renum { my ($t, $d) = @_;
  $t =~ s{(?<![A-Za-z0-9_\$])(c|g|d)\((\d+)(?=[,)])}{"$1(" . ($2 + $d)}ge;
  $t =~ s{\)\((\d+),}{')(' . ($1 + $d) . ','}ge;
  $t }
my $new = renum($P, -25) . renum($M, +16);
substr($s, $at, $len) = $new;
open my $o, '>:raw', $jsf or die $!; print $o $s; close $o;
print "app reordered\n";

open my $in, '<:raw', 'index.html' or die $!; my $p = <$in>; close $in;
my $a = '_ngcontent-ng-c2813861141';
$p =~ s{(<section $a class="mt-home">.*?</section>)(<section $a class="outreach-section">.*?APPLY FOR ADMISSION</a></div></div>)}{$2$1}s or die 'html';
open my $po, '>:raw', 'index.html' or die $!; print $po $p; close $po;
print "home page reordered\n";
