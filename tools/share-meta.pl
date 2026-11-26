#!/usr/bin/perl
# Link previews (WhatsApp, Facebook, X): pages that share the small logo get the
# 1200x630 share.jpg instead; every page gets a large-image card tag.
# Pages with their own photo (pastors, apply, matrimony) keep it. Re-runnable.
use strict; use warnings;
local $/;
my ($n, $m) = (0, 0);
for my $f ('index.html', glob '*/index.html') {
  open my $fh, '<:raw', $f or die; my $h = <$fh>; close $fh; my $o = $h;
  if ($h =~ s{(<meta property="og:image" content=")https://messiahfellowship\.net/images/logo\.png(")}{$1https://messiahfellowship.net/images/share.jpg$2}) {
    $h =~ s{(<meta property="og:image" content="[^"]*">)}{$1<meta property="og:image:width" content="1200"><meta property="og:image:height" content="630"><meta property="og:image:alt" content="Messiah Fellowship church service in Vijayawada">} unless $h =~ /og:image:width/;
    $n++;
  }
  $h =~ s{(<meta property="og:image" content="[^"]*">)}{$1<meta name="twitter:card" content="summary_large_image">} unless $h =~ /twitter:card/;
  if ($h ne $o) { open my $w, '>:raw', $f or die; print $w $h; close $w; $m++ }
}
print "share image on $n pages, $m pages updated\n";
