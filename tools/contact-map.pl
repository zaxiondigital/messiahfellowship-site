#!/usr/bin/perl
# Contact page: the static map picture (images/map.jpg) becomes a live Google Map.
# Changes the same element in the app template (main-*.js) and the prerendered page,
# so first load and in-app navigation match. Run once.
use strict; use warnings;
local $/;
my $SRC = 'https://maps.google.com/maps?q=MESSIAH%20FELLOWSHIP%20CHURCH%2C%20100%20Feet%20Rd%2C%20Auto%20Nagar%2C%20Vijayawada&z=16&output=embed';
my $TITLE = 'Google Map: Messiah Fellowship church, 100 Feet Road, Auto Nagar, Vijayawada';
my ($js) = glob 'main-*.js';
open my $f, '<:raw', $js or die; my $s = <$f>; close $f;
my $n = 0;
$n += $s =~ s{\Q(8,"div",9),g(9,"img",10)(10,"img",11),u(),c(11,"div",12)\E}{(8,"div",9),g(9,"iframe",10)(10,"img",11),u(),c(11,"div",12)};
$n += $s =~ s{\Q["src","images/map.jpg","alt","Map",1,"map-img"]\E}{["src","$SRC","title","$TITLE","loading","lazy","referrerpolicy","no-referrer-when-downgrade","allowfullscreen","",1,"map-img"]};
die "expected 2 template changes, made $n" unless $n == 2;
open my $o, '>:raw', $js or die; print $o $s; close $o;

my $page = 'contact/index.html';
open $f, '<:raw', $page or die; my $h = <$f>; close $f;
(my $src = $SRC) =~ s/&/&amp;/g;
$h =~ s{<img loading="lazy" decoding="async" (_ngcontent-ng-c\d+) src="images/map\.jpg" alt="Map" class="map-img">}
       {<iframe $1 src="$src" title="$TITLE" loading="lazy" referrerpolicy="no-referrer-when-downgrade" allowfullscreen="" class="map-img"></iframe>} or die 'page map not found';
open $o, '>:raw', $page or die; print $o $h; close $o;
print "map: template + page updated\n";
