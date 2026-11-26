#!/usr/bin/perl
# Home outreach cards: "Know More ›" becomes a real link to the ministry page
# (prerendered HTML). nav-menu.js adds the same href when the app redraws the cards.
use strict; use warnings;
local $/;
my %R = ('WIDOW CARE MINISTRY' => '/widowcare', 'MEDICAL MINISTRY' => '/medical', 'FLOOD RELIEF' => '/floodrelief',
         'KAMALA ARTS &amp; CRAFT' => '/kamalaarts', 'VEGETABLE DISTRIBUTION' => '/vegetables');
open my $f, '<:raw', 'index.html' or die $!; my $s = <$f>; close $f;
my $n = 0;
$s =~ s{(<span (_ngcontent-ng-c\d+)>([^<]+)</span>)<a \2>(Know More ›</a>)}{
  my ($span, $a, $t, $rest) = ($1, $2, $3, $4);
  if (my $href = $R{$t}) { $n++; (my $plain = $t) =~ s/&amp;/&/; my $lab = 'Know more about ' . join(' ', map { ucfirst lc } split / /, $plain);
    $lab =~ s/&/&amp;/g; qq{$span<a $a href="$href" aria-label="$lab">$rest} }
  else { "$span<a $a>$rest" }
}ge;
die "expected 5 links, set $n" unless $n == 5;
open my $o, '>:raw', 'index.html' or die $!; print $o $s; close $o;
print "Know More links: $n\n";
