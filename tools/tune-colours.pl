#!/usr/bin/perl
# Brand colour fine-tune (2026-11-27): maroon and gold nudged towards the church's new
# badge (dove plum #62263c, champagne gold #bea56a). Replaces every hard-coded use across
# styles, app code, page HTML (built-in component styles), icons and the web manifest.
# Re-runnable: does nothing once the old values are gone.
use strict; use warnings;
local $/;
my %HEX = (
  '6e0f4a' => '6a1c44',   # maroon-700  primary
  '4f0834' => '4c1532',   # maroon-900  deep maroon
  'c8a23a' => 'bf9f55',   # gold-400
  'a3832e' => 'a0823f',   # gold-600
  '876b22' => '85693a',   # gold-700    gold backgrounds
  'f1dde8' => 'efdfe6',   # maroon-100  tint
  'f8eef4' => 'f6eef2',   # maroon-50   tint
);
my %RGB = (
  '110,15,74'  => '106, 28, 68',
  '79,8,52'    => '76, 21, 50',
  '200,162,58' => '191, 159, 85',
  '60,6,40'    => '58, 16, 38',
);
my @files = (glob('*.css'), glob('*.js'), 'index.html', '404.html', glob('*/index.html'),
             glob('images/icons/*.svg'), 'site.webmanifest', glob('tools/*-content.html'));
my ($total, %per) = (0);
for my $f (@files) {
  next unless -f $f;
  open my $h, '<:raw', $f or die "$f: $!"; my $s = <$h>; close $h; my $n = 0;
  for my $old (keys %HEX) { $n += $s =~ s/#\Q$old\E(?![0-9a-f])/#$HEX{$old}/gi; }
  for my $old (keys %RGB) {
    my ($r, $g, $b) = split /,/, $old;
    $n += $s =~ s/(rgba?\(\s*)$r\s*,\s*$g\s*,\s*$b(?=\s*[,)])/$1$RGB{$old}/g;
  }
  next unless $n;
  open my $o, '>:raw', $f or die; print $o $s; close $o;
  $per{$f} = $n; $total += $n;
}
printf "%d replacements in %d files\n", $total, scalar keys %per;
printf "  %-34s %d\n", $_, $per{$_} for sort { $per{$b} <=> $per{$a} } keys %per;
