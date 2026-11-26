#!/usr/bin/perl
# Send every website form to the church inbox through Web3Forms (api.web3forms.com)
# instead of the old Render server (whose recipient we could not see or change).
#   perl tools/web3forms.pl            -> switch the code, key left as __W3F_KEY__
#   perl tools/web3forms.pl <key>      -> put the access key in (re-runnable)
# The key only lets the site SEND to the inbox it was created for; it is safe in public code.
# Forms: footer prayer form + Contact page (Angular, main-*.js), /apply/ (apply.js),
# Partner in Service popup (partner.js), footer form on static pages (static-page.js).
use strict; use warnings; use utf8;
local $/;
my $KEY = shift // '';
my $OLD = 'https://messiah-backend-20.onrender.com/send-email';
my $API = 'https://api.web3forms.com/submit';
my $FROM = 'Messiah Fellowship website';

sub edit {
  my ($f, $code) = @_;
  open my $h, '<:utf8', $f or die "$f: $!"; my $s = <$h>; close $h; my $o = $s;
  $code->(\$s);
  if ($s ne $o) { open my $w, '>:utf8', $f or die; print $w $s; close $w; print "updated $f\n" } else { print "unchanged $f\n" }
}

my ($js) = glob 'main-*.js';
edit($js, sub {
  my $s = shift;
  # Contact page form (sendMessage) – keeps the visitor's own subject
  $$s =~ s{this\.http\.post\("\Q$OLD\E",n\.value\)(\.subscribe\(\{next:\(\)=>)}
          {this.http.post("$API",Object.assign({access_key:"__W3F_KEY__",from_name:"$FROM"},n.value,{subject:"Website contact: "+(n.value.subject||"")}))$1};
  # Footer prayer form (sendPrayer)
  $$s =~ s{this\.http\.post\("\Q$OLD\E",n\.value\)(\.subscribe\(\{next:t=>)}
          {this.http.post("$API",Object.assign({access_key:"__W3F_KEY__",from_name:"$FROM",subject:"Prayer request from the website"},n.value))$1};
  die "old endpoint still in $js" if index($$s, $OLD) >= 0;
});

edit('apply.js', sub {
  my $s = shift;
  $$s =~ s{var ENDPOINT = '\Q$OLD\E';}{var ENDPOINT = '$API';\n  var W3F_KEY = '__W3F_KEY__';};
  $$s =~ s{(    var data = \{\n)(      name: val\('name'\))}{$1      access_key: W3F_KEY, from_name: '$FROM',\n$2};
  $$s =~ s{Sending your application\. This can take up to 30 seconds, please keep this page open\.}{Sending your application…};
  $$s =~ s{(fetch\(ENDPOINT, \{ method: 'POST', headers: \{ 'Content-Type': 'application/json')( \})}{$1, 'Accept': 'application/json'$2};
});

edit('partner.js', sub {
  my $s = shift;
  $$s =~ s{var ENDPOINT = '\Q$OLD\E';}{var ENDPOINT = '$API';\n  var W3F_KEY = '__W3F_KEY__';};
  $$s =~ s{(body: JSON\.stringify\(\{\n)(\s+name: el\.name\.value\.trim\(\))}{$1        access_key: W3F_KEY, from_name: '$FROM',\n$2};
  $$s =~ s{Sending… this can take up to 30 seconds, please keep this open\.}{Sending…};
  $$s =~ s{(method: 'POST', headers: \{ 'Content-Type': 'application/json')( \},)}{$1, 'Accept': 'application/json'$2};
});

edit('static-page.js', sub {
  my $s = shift;
  $$s =~ s{(    var data = \{\};\n)}{    var data = { access_key: '__W3F_KEY__', from_name: '$FROM', subject: 'Prayer request from the website' };\n};
  $$s =~ s#fetch\('\Q$OLD\E', \{\n(\s+method: 'POST',\n\s+headers: \{ 'Content-Type': 'application/json')( \},)#fetch('$API', {\n$1, 'Accept': 'application/json'$2#;
});

# make sure nothing still points at the old server
for my $f ($js, 'apply.js', 'partner.js', 'static-page.js') {
  open my $h, '<:utf8', $f or die; my $s = <$h>; close $h;
  die "old endpoint left in $f" if index($s, $OLD) >= 0;
  die "Web3Forms endpoint missing in $f" if index($s, $API) < 0;
}

if ($KEY ne '') {
  die "that does not look like a Web3Forms access key\n" unless $KEY =~ /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  for my $f ($js, 'apply.js', 'partner.js', 'static-page.js') {
    edit($f, sub { my $s = shift; $$s =~ s{__W3F_KEY__|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}(?=["'])}{$KEY}gi });
  }
}
