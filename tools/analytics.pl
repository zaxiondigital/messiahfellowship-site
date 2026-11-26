#!/usr/bin/perl
# Google Analytics 4 tag on every page (property "Messiah Fellowship Website",
# Google account digitalksraj@gmail.com). Re-runnable; skips the private give-preview.
# In-app page changes are counted by GA4 enhanced measurement (browser history events).
use strict; use warnings;
local $/;
my $ID = 'G-9BPK79SJ8D';
my $TAG = qq{<script async src="https://www.googletagmanager.com/gtag/js?id=$ID" id="mf-ga"></script>}
        . qq{<script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments);}gtag('js',new Date());gtag('config','$ID');</script>};
my $n = 0;
for my $f (grep { !m{^give-preview/} } 'index.html', '404.html', glob '*/index.html') {
  next unless -f $f;
  open my $h, '<:raw', $f or die; my $s = <$h>; close $h;
  next if $s =~ /id="mf-ga"/;
  $s =~ s{(<meta charset="[^"]*">)}{$1$TAG} or $s =~ s{(<head[^>]*>)}{$1$TAG} or die "no head in $f";
  open my $o, '>:raw', $f or die; print $o $s; close $o; $n++;
}
print "GA4 tag added to $n pages\n";
