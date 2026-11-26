#!/usr/bin/perl
# Pages whose design has no <h1> get a visually hidden one (for screen readers
# and search engines), placed before <app-root> so the app never touches it.
# Text must match H1 in /nav-menu.js, which updates it on in-app navigation.
use strict; use warnings;
my %H1 = (
  ''            => 'Messiah Fellowship – Full Gospel Pentecostal Church in Vijayawada',
  'contact'     => 'Contact Messiah Fellowship',
  'events'      => 'Events at Messiah Fellowship',
  'floodrelief' => 'Flood Relief',
  'give'        => 'Tithes &amp; Offerings',
  'kamalaarts'  => 'Kamala Arts &amp; Craft',
  'medical'     => 'Medical Ministry &amp; Free Health Camps',
  'men'         => 'Men’s Ministry: Morning Prayer &amp; Breakfast',
  'widowcare'   => 'Widow Care Ministry',
);
local $/;
for my $k (sort keys %H1) {
  my $p = $k eq '' ? 'index.html' : "$k/index.html";
  open my $in, '<:raw', $p or die $!; my $h = <$in>; close $in;
  next if $h =~ /id="page-h1"/;
  $h =~ s{<body>}{<body><h1 id="page-h1" class="sr-only">$H1{$k}</h1>} or die "no body in $p";
  open my $o, '>:raw', $p or die $!; print $o $h; close $o; print "$p\n";
}
