#!/usr/bin/perl
# Structured data (schema.org JSON-LD) for Google: church details, service times,
# pastors and the Bible College. Re-runnable: replaces the block each time.
#   perl tools/schema.pl
# Postal code 520007 confirmed 2026-11-26 (The Hindu office next door is 55-1-4,
# 520007). The Google Maps listing wrongly says 520010 – the church should fix it there.
use strict; use warnings; use utf8;
use JSON::PP;
local $/;

my $SITE = 'https://messiahfellowship.net';
my %ADDR = (
  '@type' => 'PostalAddress',
  streetAddress   => '55-1-5, 100 Feet Road, Near Autonagar Gate, Auto Nagar',
  postalCode      => '520007',
  addressLocality => 'Vijayawada',
  addressRegion   => 'Andhra Pradesh',
  addressCountry  => 'IN',
);
my $CHURCH_ID = "$SITE/#church";

sub service {
  my ($name, $days, $start, $end) = @_;
  return {
    '@type' => 'Event', name => $name,
    eventAttendanceMode => 'https://schema.org/OfflineEventAttendanceMode',
    location => { '@id' => $CHURCH_ID },
    eventSchedule => { '@type' => 'Schedule', repeatFrequency => ($days eq 'daily' ? 'P1D' : 'P1W'),
      ($days eq 'daily' ? () : (byDay => "https://schema.org/$days")),
      startTime => $start, ($end ? (endTime => $end) : ()), scheduleTimezone => 'Asia/Kolkata' },
  };
}

my $church = {
  '@type' => 'Church', '@id' => $CHURCH_ID,
  name => 'Messiah Fellowship',
  alternateName => ['Messiah Fellowship Church', 'మెస్సియ ఫెలోషిప్ చర్చ్'],
  description => 'Full Gospel Pentecostal church in Vijayawada, Andhra Pradesh, with Sunday worship services at 8:00 AM, 10:30 AM and 6:00 PM, a Global Prayer Tower, Messiah Bible College and community outreach ministries.',
  url => "$SITE/",
  logo => "$SITE/images/logo.png",
  image => ["$SITE/images/about-img.jpg", "$SITE/images/video-poster.jpg"],
  telephone => '+91-94947-67633',
  email => 'ratnaksajja@gmail.com',
  address => { %ADDR },
  geo => { '@type' => 'GeoCoordinates', latitude => 16.4938601, longitude => 80.6697133 },
  hasMap => 'https://maps.google.com/?cid=5174151055568101196',
  areaServed => 'Vijayawada',
  founder => { '@type' => 'Person', name => 'Pastor Sajja Eliazer', jobTitle => 'Founder & President' },
  employee => [
    { '@type' => 'Person', name => 'Dr. Sajja Ratna Kumar', jobTitle => 'Pastor' },
    { '@type' => 'Person', name => 'Mrs. Sajja Jyothi', jobTitle => 'Pastor' },
  ],
  contactPoint => [
    { '@type' => 'ContactPoint', telephone => '+91-94947-67633', contactType => 'customer support', availableLanguage => ['English', 'Telugu'] },
    { '@type' => 'ContactPoint', telephone => '+91-94947-67733', contactType => 'customer support', availableLanguage => ['English', 'Telugu'] },
  ],
  sameAs => [
    'https://www.facebook.com/messiahfellowship1/',
    'https://www.instagram.com/messiahfellowshipchurch',
    'https://youtube.com/@messiahfellowship',
  ],
  event => [
    service('Sunday First Service',    'Sunday',    '08:00'),
    service('Sunday Second Service',   'Sunday',    '10:30'),
    service('Sunday Third Service',    'Sunday',    '18:00'),
    service("Men's Morning Prayer",    'Wednesday', '05:00'),
    service('Family Prayer',           'Friday',    '18:30'),
    service('Global Prayer Tower',     'daily',     '07:00', '19:00'),
  ],
};
my $website = { '@type' => 'WebSite', '@id' => "$SITE/#website", url => "$SITE/", name => 'Messiah Fellowship', inLanguage => 'en', publisher => { '@id' => $CHURCH_ID } };
my $college = {
  '@type' => 'EducationalOrganization', '@id' => "$SITE/bible-college/#college",
  name => 'Messiah Bible College', url => "$SITE/bible-college/",
  parentOrganization => { '@id' => $CHURCH_ID },
  address => { %ADDR }, telephone => '+91-94947-67633',
  description => 'Bible college in Vijayawada offering Bachelor of Theology (B.Th), Diploma in Theology (Dip.Th) and Certificate in Theology (C.Th).',
};
my $churchRef = { '@type' => 'Church', '@id' => $CHURCH_ID, name => 'Messiah Fellowship', url => "$SITE/" };

sub crumbs {
  my ($path, $name) = @_;
  return { '@type' => 'BreadcrumbList', itemListElement => [
    { '@type' => 'ListItem', position => 1, name => 'Home', item => "$SITE/" },
    { '@type' => 'ListItem', position => 2, name => $name, item => "$SITE$path" } ] };
}

# page => [graph items]
my %PAGES = (
  'index.html'               => [ $church, $website ],
  'contact/index.html'       => [ $church, crumbs('/contact/', 'Contact Us') ],
  'pastors/index.html'       => [ $church, crumbs('/pastors/', 'Our Pastors') ],
  'about/index.html'         => [ $church, crumbs('/about/', 'About Us') ],
  'bible-college/index.html' => [ $college, $churchRef, crumbs('/bible-college/', 'Bible College') ],
  'apply/index.html'         => [ $college, $churchRef, crumbs('/apply/', 'Apply for Admission') ],
);
# every other page: who runs it + breadcrumb from its own <title>
for my $f (glob '*/index.html') {
  next if $PAGES{$f} || $f =~ m{^(give-preview|events)/};
  open my $fh, '<:utf8', $f or die; my $h = <$fh>; close $fh;
  my ($t) = $h =~ m{<title>([^|<]+)}; $t //= ''; $t =~ s/\s+$//; $t =~ s/&amp;/&/g;
  (my $path = "/$f") =~ s{index\.html$}{};
  $PAGES{$f} = [ $churchRef, crumbs($path, $t) ];
}

my $json = JSON::PP->new->utf8(0)->canonical(1);
my $n = 0;
for my $f (sort keys %PAGES) {
  open my $fh, '<:utf8', $f or die "$f: $!"; my $h = <$fh>; close $fh;
  my $ld = $json->encode({ '@context' => 'https://schema.org', '@graph' => $PAGES{$f} });
  $ld =~ s{</}{<\\/}g;
  my $tag = qq{<script type="application/ld+json" id="mf-ld">$ld</script>};
  $h =~ s{<script type="application/ld\+json"[^>]*>.*?</script>}{}gs;       # old blocks (incl. the first home one)
  $h =~ s{</head>}{$tag</head>} or die "no </head> in $f";
  open my $o, '>:utf8', $f or die; print $o $h; close $o; $n++;
}
print "structured data written to $n pages\n";
