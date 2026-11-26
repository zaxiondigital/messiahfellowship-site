#!/usr/bin/perl
# Builds /pastors/index.html from /about/index.html (same header, footer,
# styles) with the page body from tools/pastors-content.html.
# The page is static: the Angular app is not loaded (it has no /pastors route);
# /static-page.js gives the header menu and footer form their behaviour.
# Re-run after editing tools/pastors-content.html.
use strict; use warnings;
my $root = $ARGV[0] // '.';
local $/;
open my $a, '<:raw', "$root/about/index.html" or die $!; my $h = <$a>; close $a;
open my $c, '<:raw', "$root/tools/pastors-content.html" or die $!; my $body = <$c>; close $c;

my $title = 'Our Pastors | Messiah Fellowship Vijayawada';
my $desc  = 'Meet the pastors of Messiah Fellowship, Vijayawada: Dr. Sajja Ratna Kumar and Mrs. Sajja Jyothi, and our founder and president, Pastor Sajja Eliazer.';
my $url   = 'https://messiahfellowship.net/pastors/';

$h =~ s{<title>.*?</title>}{<title>$title</title>}s or die 'title';
$h =~ s{(<meta name="description" content=")[^"]*}{$1$desc} or die 'desc';
$h =~ s{(<meta property="og:description" content=")[^"]*}{$1$desc} or die 'ogdesc';
$h =~ s{(<meta property="og:title" content=")[^"]*}{$1$title} or die 'ogtitle';
$h =~ s{(<link rel="canonical" href=")[^"]*}{$1$url} or die 'canon';
$h =~ s{(<meta property="og:url" content=")[^"]*}{$1$url} or die 'ogurl';
$h =~ s{<meta property="og:image" content="[^"]*"}{<meta property="og:image" content="https://messiahfellowship.net/images/pastor-couple.jpg"} or die 'ogimg';

# page body
$h =~ s{<app-about\b.*?</app-about>}{$body}s or die 'body';
# no Angular on this page
$h =~ s{<script src="polyfills-[^"]+"[^>]*></script>}{}g;
$h =~ s{<script src="main-[^"]+"[^>]*></script>}{}g;
$h =~ s{<script id="ng-state"[^>]*>.*?</script>}{}s;
$h =~ s{<script src="/outreach-carousel.js" defer></script>}{}g;
# page styles + behaviour
$h =~ s{(<link rel="stylesheet" href="/images-rounded.css">)}{$1<link rel="stylesheet" href="/pastors.css">} or die 'css';
$h =~ s{(<script src="/nav-menu.js" defer></script>)}{<script src="/static-page.js" defer></script>$1} or die 'js';
# the footer form is enabled by static-page.js once it is valid
die 'angular left' if $h =~ /main-[A-Z0-9]+\.js/;

mkdir "$root/pastors";
open my $o, '>:raw', "$root/pastors/index.html" or die $!; print $o $h; close $o;
print "wrote pastors/index.html (", length($h), " bytes)\n";
