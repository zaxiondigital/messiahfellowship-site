#!/usr/bin/perl
# Builds the site's static pages (pages that are not part of the Angular app)
# from /about/index.html, so they share the exact header, footer and styles.
#   perl tools/build-static.pl            -> builds every page below
#   perl tools/build-static.pl apply      -> builds one
# Page bodies live in tools/<slug>-content.html. The Angular app is not loaded
# on these pages; /static-page.js runs the header menu and footer form.
use strict; use warnings;
my $root = '.';
my %PAGES = (
  pastors => {
    title => 'Our Pastors | Messiah Fellowship Vijayawada',
    desc  => 'Meet the pastors of Messiah Fellowship, Vijayawada: Dr. Sajja Ratna Kumar and Mrs. Sajja Jyothi, and our founder and president, Pastor Sajja Eliazer.',
    image => 'pastor-couple.jpg',
    css   => ['pastors.css'],
    js    => [],
  },
  apply => {
    title => 'Apply for Admission | Messiah Bible College',
    desc  => 'Apply online for Messiah Bible College, Vijayawada: Bachelor of Theology (B.Th), Diploma in Theology (Dip.Th) and Certificate in Theology (C.Th).',
    image => 'bible-college.jpg',
    css   => ['pastors.css', 'apply.css'],
    js    => ['apply.js'],
  },
  matrimony => {
    title => 'Telugu Christian Matrimony | Messiah Fellowship Vijayawada',
    desc  => 'Free Telugu Christian matrimony service at Messiah Fellowship, Vijayawada. Matrimony drives at the church, open to Christians from all castes. Call 9494 7676 33.',
    image => 'matrimony-hero.jpg',
    css   => ['pastors.css', 'matrimony.css'],
    js    => [],
  },
  privacy => {
    title => 'Privacy Policy | Messiah Fellowship Vijayawada',
    desc  => 'How Messiah Fellowship, Vijayawada collects, uses and protects the information you share through our website, including prayer requests and applications.',
    image => 'share.jpg',
    css   => ['pastors.css', 'privacy.css'],
    js    => [],
  },
  'give-preview' => {   # private demo with SAMPLE details; never linked, never in the sitemap
    title   => 'Give (Preview) | Messiah Fellowship',
    desc    => 'Preview of the Give page with sample details.',
    image   => 'tithe.jpg',
    css     => ['pastors.css', 'give.css'],
    js      => ['give.js'],
    noindex => 1,
  },
);
my @which = @ARGV ? @ARGV : sort keys %PAGES;
local $/;
open my $a, '<:raw', "$root/about/index.html" or die $!; my $tpl = <$a>; close $a;

for my $slug (@which) {
  my $p = $PAGES{$slug} or die "unknown page $slug";
  open my $c, '<:raw', "$root/tools/$slug-content.html" or die $!; my $body = <$c>; close $c;
  my $h = $tpl;
  my $url = "https://messiahfellowship.net/$slug/";
  $h =~ s{<title>.*?</title>}{<title>$p->{title}</title>}s or die 'title';
  $h =~ s{(<meta name="description" content=")[^"]*}{$1$p->{desc}} or die 'desc';
  $h =~ s{(<meta property="og:description" content=")[^"]*}{$1$p->{desc}} or die 'ogdesc';
  $h =~ s{(<meta property="og:title" content=")[^"]*}{$1$p->{title}} or die 'ogtitle';
  $h =~ s{(<link rel="canonical" href=")[^"]*}{$1$url} or die 'canon';
  $h =~ s{(<meta property="og:url" content=")[^"]*}{$1$url} or die 'ogurl';
  $h =~ s{<meta property="og:image" content="[^"]*"}{<meta property="og:image" content="https://messiahfellowship.net/images/$p->{image}"} or die 'ogimg';
  $h =~ s{<app-about\b.*?</app-about>}{$body}s or die 'body';
  $h =~ s{(<meta name="viewport"[^>]*>)}{$1\n  <meta name="robots" content="noindex, nofollow">} or die 'robots' if $p->{noindex};
  # no Angular on static pages
  $h =~ s{<script src="polyfills-[^"]+"[^>]*></script>}{}g;
  $h =~ s{<script src="main-[^"]+"[^>]*></script>}{}g;
  $h =~ s{<script id="ng-state"[^>]*>.*?</script>}{}s;
  $h =~ s{<script src="/outreach-carousel.js" defer></script>}{}g;
  my $css = join '', map { qq{<link rel="stylesheet" href="/$_">} } @{$p->{css}};
  my $js  = join '', map { qq{<script src="/$_" defer></script>} } @{$p->{js}};
  $h =~ s{(<link rel="stylesheet" href="/images-rounded.css">)}{$1$css} or die 'css';
  $h =~ s{(<script src="/nav-menu.js" defer></script>)}{$js<script src="/static-page.js" defer></script>$1} or die 'js';
  die 'angular left' if $h =~ /main-[A-Z0-9]+\.js/;
  mkdir "$root/$slug";
  open my $o, '>:raw', "$root/$slug/index.html" or die $!; print $o $h; close $o;
  print "wrote $slug/index.html (", length($h), " bytes)\n";
}
