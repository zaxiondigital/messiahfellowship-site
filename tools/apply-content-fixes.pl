#!/usr/bin/perl
# Apply tools/content-fixes.tsv to the prerendered pages AND the Angular app
# script, so text stays identical whether a page is loaded or navigated to.
# Usage: perl tools/apply-content-fixes.pl [--dry]
use strict; use warnings; use utf8;
use open qw(:std :encoding(UTF-8));
use File::Basename;
binmode STDOUT, ':encoding(UTF-8)';

my $dry = grep { $_ eq '--dry' } @ARGV;
my $root = dirname(dirname(__FILE__));
my ($js) = glob("$root/main-*.js") or die "app script not found\n";
my %html = map { my $p = $_ eq "$root/index.html" ? 'home' : basename(dirname($_)); ($p => $_) }
           (glob("$root/index.html"), glob("$root/*/index.html"));

sub slurp { open my $f, '<:raw', $_[0] or die "$_[0]: $!"; local $/; my $t = <$f>; utf8::decode($t); $t }
sub spew  { open my $f, '>:raw', $_[0] or die "$_[0]: $!"; my $t = $_[1]; utf8::encode($t); print $f $t }
sub enc_html { my $s = shift; $s =~ s/&(?!amp;)/&amp;/g unless $s =~ /^>.*<$/ && $s !~ /&/; $s =~ s/&(?!amp;)/&amp;/g; $s }
sub enc_js   { my $s = shift; $s =~ s/([^\x00-\x7f])/sprintf('\\u%04x', ord $1)/ge; $s }

sub replace_nth { my ($tref, $old, $new, $nth) = @_;
  my $count = 0; my $done = 0; my $pos = 0;
  while ((my $i = index($$tref, $old, $pos)) >= 0) {
    $count++;
    if ($nth == 0 || $count == $nth) { substr($$tref, $i, length $old) = $new; $pos = $i + length $new; $done++ }
    else { $pos = $i + length $old }
  }
  return $done;
}

my %text = map { $_ => slurp($html{$_}) } keys %html;
my $jstext = slurp($js);
open my $spec, '<:encoding(UTF-8)', "$root/tools/content-fixes.tsv" or die $!;
my ($ok, $bad) = (0, 0);
while (my $line = <$spec>) {
  chomp $line; $line =~ s/\r$//; next if $line =~ /^\s*(#|$)/;
  my ($pages, $hn, $jn, $old, $new) = split /\t/, $line, 5;
  my @targets = $pages eq 'all' ? sort keys %html : split /,/, $pages;
  my ($h, $j) = (0, 0);
  if ($hn ne '-') { for my $p (@targets) { die "unknown page $p\n" unless exists $text{$p};
      $h += replace_nth(\$text{$p}, enc_html($old), enc_html($new), $hn) } }
  if ($jn ne '-') { $j = replace_nth(\$jstext, enc_js($old), enc_js($new), $jn) }
  my $flag = (($hn ne '-' && !$h) || ($jn ne '-' && !$j)) ? 'MISSING' : 'ok';
  $flag eq 'ok' ? $ok++ : $bad++;
  printf "%-7s html:%-3s js:%-2s %s\n", $flag, ($hn eq '-' ? '-' : $h), ($jn eq '-' ? '-' : $j), substr($old, 0, 70);
}
print "\n$ok applied, $bad not found\n";
unless ($dry) { spew($html{$_}, $text{$_}) for keys %html; spew($js, $jstext); print "files written\n" }
