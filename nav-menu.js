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
  function syncTitle() {
    var key = location.pathname.replace(/^\/+|\/+$/g, '');
    if (TITLES.hasOwnProperty(key)) document.title = TITLES[key];
  }
  ['pushState', 'replaceState'].forEach(function (m) {
    var orig = history[m];
    history[m] = function () { var r = orig.apply(this, arguments); setTimeout(syncTitle, 0); return r; };
  });
  window.addEventListener('popstate', function () { setTimeout(syncTitle, 0); });

  new MutationObserver(prepareLogo).observe(document.documentElement, { childList: true, subtree: true });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', prepareLogo); else prepareLogo();
})();
