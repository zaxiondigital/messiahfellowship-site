/* Messiah Fellowship – close menus after a link is chosen
   The site navigates without reloading the page, so after clicking a link in the
   Ministries / Outreach drop-down the mouse is still over it (and the link keeps
   focus), which kept the drop-down open. This closes it straight away; it opens
   again normally the next time you hover or tab into it. */
(function () {
  'use strict';
  document.addEventListener('click', function (e) {
    var link = e.target.closest && e.target.closest('.nav-links a');
    if (!link) return;

    var group = link.closest('.navbar-ministries');
    if (group && link.closest('.ministries-content')) {
      group.classList.add('dd-closed');
      var reopen = function () {
        group.classList.remove('dd-closed');
        group.removeEventListener('mouseleave', reopen);
      };
      group.addEventListener('mouseleave', reopen);
      // touch / keyboard: no mouseleave will come, so release after a moment
      setTimeout(function () { if (!group.matches(':hover')) reopen(); }, 400);
    }
    // drop focus so :focus-within doesn't hold the menu open
    setTimeout(function () {
      var a = document.activeElement;
      if (a && a.closest && a.closest('.nav-links')) a.blur();
    }, 0);
  });

  /* ---------- Header logo = link to Home ----------
     Uses the existing Home menu link so navigation stays in-app (no reload).
     Already on Home → smooth scroll to the top. Keyboard + screen-reader ready. */
  function goHome() {
    var p = location.pathname.replace(/\/+$/, '');
    if (p === '' ) { window.scrollTo({ top: 0, behavior: 'smooth' }); return; }
    var home = document.querySelector('.nav-links a[href="/"]');
    if (home) home.click(); else location.href = '/';
    window.scrollTo(0, 0);
  }
  function prepareLogo() {
    var logo = document.querySelector('.navbar .logo');
    if (!logo || logo.getAttribute('role') === 'link') return;
    logo.setAttribute('role', 'link');
    logo.setAttribute('tabindex', '0');
    logo.setAttribute('aria-label', 'Messiah Fellowship – Home');
    logo.setAttribute('title', 'Home');
  }
  document.addEventListener('click', function (e) {
    if (e.target.closest && e.target.closest('.navbar .logo')) { e.preventDefault(); goHome(); }
  });
  document.addEventListener('keydown', function (e) {
    if ((e.key === 'Enter' || e.key === ' ') && e.target.closest && e.target.closest('.navbar .logo')) {
      e.preventDefault(); goHome();
    }
  });
  /* ---------- "Meet Our Pastors" (home) opens the Our Pastors page ----------
     /pastors/ is a separate page (not part of the app), so this is a normal page load. */
  document.addEventListener('click', function (e) {
    if (e.target.closest && e.target.closest('.meet-pastor')) { e.preventDefault(); location.href = '/pastors/'; }
  });

  /* ---------- "Find Out More" (home welcome section) opens About ----------
     Uses the About menu link so it stays in-app (no reload), then starts at the top. */
  document.addEventListener('click', function (e) {
    if (!(e.target.closest && e.target.closest('.cta-btn'))) return;
    e.preventDefault();
    var about = document.querySelector('.nav-links a[href="/about"]');
    if (about) about.click(); else location.href = '/about';
    window.scrollTo(0, 0);
  });

  /* ---------- "Apply" buttons open the admission form (/apply/) ----------
     Home "Apply for Admission", Bible College hero "Apply for Admission" and
     each course's "Apply Now" (that one preselects its course).
     Capture phase, so the home college box's own link to /bible-college
     doesn't win. /apply/ is a separate page, so this is a normal page load. */
  var COURSES = ['bth', 'dipth', 'cth'];   // same order as the course cards
  document.addEventListener('click', function (e) {
    var t = e.target;
    if (!t.closest) return;
    var url = null, b;
    if (t.closest('.college-box .btn-outline') || t.closest('app-bible-college .hero-content button')) {
      url = '/apply/';
    } else if ((b = t.closest('app-bible-college .course-container .card button'))) {
      var cards = Array.prototype.slice.call(document.querySelectorAll('app-bible-college .course-container .card'));
      var key = COURSES[cards.indexOf(b.closest('.card'))];
      url = '/apply/' + (key ? '?course=' + key : '');
    }
    if (!url) return;
    e.preventDefault();
    e.stopPropagation();
    location.href = url;
  }, true);

  /* ---------- Welcome bar "Service Times" → the Sunday schedule on the home page ---------- */
  document.addEventListener('click', function (e) {
    var a = e.target.closest && e.target.closest('.hero-btn-services');
    if (!a) return;
    e.preventDefault();
    var t = document.querySelector('.about-section .sub-heading') || document.querySelector('.about-section');
    if (!t) return;
    var hdr = document.querySelector('app-header');
    var y = t.getBoundingClientRect().top + window.scrollY - (hdr ? hdr.offsetHeight : 0) - 24;
    var reduce = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
    window.scrollTo({ top: y, behavior: reduce ? 'auto' : 'smooth' });
  });

  /* ---------- Sticky header: soft shadow once the page is scrolled ---------- */
  var scrolledQueued = false;
  // on after 48px, off again only near the very top: the header changes height,
  // so a single threshold would make it flicker on and off
  function markScrolled() {
    scrolledQueued = false;
    var el = document.documentElement, y = window.scrollY;
    if (y > 48) el.classList.add('is-scrolled'); else if (y < 8) el.classList.remove('is-scrolled');
  }
  window.addEventListener('scroll', function () { if (!scrolledQueued) { scrolledQueued = true; requestAnimationFrame(markScrolled); } }, { passive: true });
  markScrolled();

  /* ---------- Home hero video: make sure it autoplays ----------
     Browsers only autoplay videos that are muted. When the app creates or
     updates the <video>, the HTML "muted" attribute does not switch the sound
     off (the .muted property stays false), so the video stayed frozen.
     Set it in script and start playback; re-run when the home page is redrawn. */
  function heroVideo() {
    var v = document.querySelector('.hero-video video');
    if (!v || v.dataset.mfAuto) return;
    v.dataset.mfAuto = '1';
    v.muted = true; v.defaultMuted = true; v.playsInline = true; v.loop = true;
    v.setAttribute('muted', ''); v.setAttribute('playsinline', '');
    var go = function () { if (v.paused) { var p = v.play(); if (p && p.catch) p.catch(function () {}); } };
    if (v.readyState >= 2) go(); else v.addEventListener('canplay', go, { once: true });
    go();
  }
  new MutationObserver(heroVideo).observe(document.documentElement, { childList: true, subtree: true });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', heroVideo); else heroVideo();

  /* ---------- Page title follows in-app navigation ----------
     The app never set titles, so after moving between pages the tab kept the
     first page's title. Same titles as each page's own <title>. */
  var TITLES = {
    '': 'Messiah Fellowship | Full Gospel Pentecostal Church in Vijayawada',
    'about': 'About Us | Messiah Fellowship Vijayawada',
    'bible-college': 'Bible College | Messiah Fellowship Vijayawada',
    'children': 'Children’s Ministry & Sunday School | Messiah Fellowship',
    'contact': 'Contact Us | Messiah Fellowship Vijayawada',
    'events': 'Events | Messiah Fellowship Vijayawada',
    'floodrelief': 'Flood Relief | Messiah Fellowship Vijayawada',
    'give': 'Give & Tithe Online | Messiah Fellowship',
    'inthenews': 'In the News | Messiah Fellowship Vijayawada',
    'kamalaarts': 'Kamala Arts | Messiah Fellowship Vijayawada',
    'pastors': 'Our Pastors | Messiah Fellowship Vijayawada',
    'medical': 'Medical Ministry & Free Health Camps | Messiah Fellowship',
    'men': "Men's Ministry | Messiah Fellowship Vijayawada",
    'prayer': 'Global Prayer Tower | Messiah Fellowship',
    'vegetables': 'Vegetable Distribution Program | Messiah Fellowship',
    'widowcare': 'Widow Care Ministry | Messiah Fellowship Vijayawada',
    'women': "Women's Ministry | Messiah Fellowship Vijayawada",
    'youth': 'Youth Ministry | Messiah Fellowship Vijayawada'
  };
  /* hidden page H1 (see tools/add-h1.pl) for pages whose design has no H1;
     other pages have their own, so the hidden one is removed there */
  var H1 = {
    '': 'Messiah Fellowship – Full Gospel Pentecostal Church in Vijayawada',
    'contact': 'Contact Messiah Fellowship',
    'events': 'Events at Messiah Fellowship',
    'floodrelief': 'Flood Relief',
    'give': 'Tithes & Offerings',
    'kamalaarts': 'Kamala Arts & Craft',
    'medical': 'Medical Ministry & Free Health Camps',
    'men': 'Men’s Ministry: Morning Prayer & Breakfast',
    'widowcare': 'Widow Care Ministry'
  };
  function syncTitle() {
    var key = location.pathname.replace(/^\/+|\/+$/g, '');
    if (TITLES.hasOwnProperty(key)) document.title = TITLES[key];
    if (!TITLES.hasOwnProperty(key) || key === 'pastors') return;   // static pages / 404: leave as is
    var h = document.getElementById('page-h1');
    if (H1.hasOwnProperty(key)) {
      if (!h) { h = document.createElement('h1'); h.id = 'page-h1'; h.className = 'sr-only'; document.body.insertBefore(h, document.body.firstChild); }
      h.textContent = H1[key];
    } else if (h) { h.remove(); }
  }

  /* ---------- Links that only worked with a mouse / weren't links ---------- */
  var MAPS = 'https://www.google.com/maps/search/?api=1&query=Messiah+Fellowship+Autonagar+Gate+Vijayawada';
  function asLink(el, label) {
    if (!el || el.dataset.mfLink) return;
    el.dataset.mfLink = '1';
    el.setAttribute('role', 'link');
    el.setAttribute('tabindex', '0');
    if (label) el.setAttribute('aria-label', label);
  }
  function enhance() {
    // footer "Volunteer" → Contact (routerlink attr = same look as the other footer links)
    document.querySelectorAll('app-footer .footer-col p:not([routerlink])').forEach(function (p) {
      var t = p.textContent.trim();
      if (t === 'Volunteer') { p.setAttribute('routerlink', '/contact'); p.dataset.mfGo = '/contact'; asLink(p); }
    });
    // phone & email (Contact page + footer) → tap to call / email
    document.querySelectorAll('.contact-info span, app-footer p.contact').forEach(function (el) {
      var t = el.textContent.trim();
      if (/^\+?[\d\s-]{8,}$/.test(t)) { el.dataset.mfHref = 'tel:' + t.replace(/[^\d+]/g, ''); asLink(el, 'Call ' + t); }
      else if (/^[^@\s]+@[^@\s]+\.[a-z]+$/i.test(t)) { el.dataset.mfHref = 'mailto:' + t; asLink(el, 'Email ' + t); }
    });
    // Contact page map → Google Maps directions
    var map = document.querySelector('.contact-left .map-img');
    if (map && !map.dataset.mfLink) { map.dataset.mfOpen = MAPS; asLink(map, 'Open directions to Messiah Fellowship in Google Maps'); map.alt = 'Map: Messiah Fellowship, 100 Feet Road, Autonagar Gate, Vijayawada'; }
  }
  document.addEventListener('click', function (e) {
    var el = e.target.closest && e.target.closest('[data-mf-href],[data-mf-open],[data-mf-go]');
    if (!el) return;
    if (el.dataset.mfHref) { location.href = el.dataset.mfHref; return; }
    if (el.dataset.mfOpen) { window.open(el.dataset.mfOpen, '_blank', 'noopener'); return; }
    var a = document.querySelector('.nav-links a[href="' + el.dataset.mfGo + '"]');
    if (a) a.click(); else location.href = el.dataset.mfGo;
    window.scrollTo(0, 0);
  });
  // keyboard: Enter opens cards / footer links / the links above (they're not <a>)
  document.addEventListener('keydown', function (e) {
    if (e.key !== 'Enter' || !e.target.matches) return;
    if (e.target.matches('.outreach-card, [routerlink]:not(a), [data-mf-link]')) { e.preventDefault(); e.target.click(); }
  });
  var queued = false;
  new MutationObserver(function () {
    if (queued) return; queued = true;
    requestAnimationFrame(function () { queued = false; enhance(); });
  }).observe(document.documentElement, { childList: true, subtree: true });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', enhance); else enhance();
  ['pushState', 'replaceState'].forEach(function (m) {
    var orig = history[m];
    history[m] = function () { var r = orig.apply(this, arguments); setTimeout(syncTitle, 0); return r; };
  });
  window.addEventListener('popstate', function () { setTimeout(syncTitle, 0); });

  new MutationObserver(prepareLogo).observe(document.documentElement, { childList: true, subtree: true });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', prepareLogo); else prepareLogo();
})();
