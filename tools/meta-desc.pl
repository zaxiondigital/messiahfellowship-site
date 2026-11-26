#!/usr/bin/perl
# Fuller search descriptions (about 140-160 characters) for pages whose description was short.
use strict; use warnings; use utf8;
local $/;
my %D = (
  'kamalaarts' => 'Kamala Arts & Craft Training Center, Messiah Fellowship, Vijayawada: free tailoring and stitching training for women, open to all, with sewing machine support.',
  'medical'    => 'Free medical camps every three months by Messiah Fellowship in Vijayawada: free doctor consultations and lab tests, open to everyone regardless of religion.',
  'give'       => 'Give your tithes and offerings to Messiah Fellowship, Vijayawada, and support worship, outreach and the spreading of the Gospel. God loves a cheerful giver.',
  'vegetables' => 'Messiah Fellowship regularly distributes fresh vegetables to hundreds of families in need in Vijayawada, open to everyone regardless of religion or background.',
);
for my $p (sort keys %D) {
  my $f = "$p/index.html";
  open my $fh, '<:utf8', $f or die; my $h = <$fh>; close $fh;
  (my $d = $D{$p}) =~ s/&/&amp;/g;
  $h =~ s{(<meta name="description" content=")[^"]*}{$1$d} or die "desc $f";
  $h =~ s{(<meta property="og:description" content=")[^"]*}{$1$d} or die "og $f";
  open my $o, '>:utf8', $f or die; print $o $h; close $o;
  printf "%-11s %d chars\n", $p, length $D{$p};
}
