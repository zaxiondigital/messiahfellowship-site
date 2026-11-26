#!/usr/bin/perl
# Prayer form phone check (footer, every app page):
#   +91 → 10 digits starting 6–9 (a leading 0, spaces or dashes allowed)
#   any other country → 6–15 digits (spaces, dashes, dots, brackets allowed)
# Before: +91, +1, +44, +61 only, with strict digit counts. Also friendlier error text.
use strict; use warnings;
local $/;
my ($jsf) = glob('main-*.js');
open my $f, '<:raw', $jsf or die $!; my $s = <$f>; close $f;
# patterns exactly as they must appear inside a JS string literal (backslashes doubled)
# (- ( ) . escaped inside [ ]: browsers also read this as an HTML pattern in strict "v" mode)
my $IN = '^\\\\s*0?[6-9](?:[\\\\s\\\\-]*\\\\d){9}\\\\s*$';
my $WW = '^\\\\s*\\\\(?(?:\\\\d[\\\\s\\\\(\\\\)\\\\.\\\\-]*){6,15}$';
my $OLD_IN = '^[6-9]\\\\d{9}$';

sub splice_once {
  my ($start, $stop, $new) = @_;
  my $at = index($s, $start); die "not found: $start" if $at < 0;
  my $end = index($s, $stop, $at); die "end not found: $stop" if $end < 0;
  substr($s, $at, $end - $at) = $new;
}
# 1. the per-country switch
splice_once('updatePattern(){switch(this.countryCode){', 'this.phone=""',
  'updatePattern(){switch(this.countryCode){case"+91":this.phonePattern="' . $IN . '";break;default:this.phonePattern="' . $WW . '"}');
# 2. the initial value of phonePattern (class field)
my $c = 0;
for my $tail (';Message', ';email') {
  my $old = 'phonePattern="' . $OLD_IN . '"' . $tail;
  while ((my $at = index($s, $old)) >= 0) { substr($s, $at, length $old) = 'phonePattern="' . $IN . '"' . $tail; $c++ }
}
die "initial phonePattern not found" unless $c;
# 3. error text
my $e_old = 'd(1," Please enter correct phone ")';
my $at = index($s, $e_old); die 'error text not found' if $at < 0;
substr($s, $at, length $e_old) = 'd(1," Please enter a valid phone number ")';

open my $o, '>:raw', $jsf or die $!; print $o $s; close $o;
print "phone rules updated (initial values: $c)\n";
