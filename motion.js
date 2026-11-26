/* Messiah Fellowship – scroll reveal
   Content blocks below the fold wait hidden and fade + rise in (0.7s) the moment
   they scroll into view; blocks side by side arrive one after another.
   Only a data-mf attribute is set (never classes or structure), so the app is not
   disturbed. Nothing is hidden if this script doesn't run, and nothing moves for
   visitors who ask their device for reduced motion. Styles live in motion.css. */
(function () {
  'use strict';
  if (!('IntersectionObserver' in window)) return;
  if (window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  var BLOCKS = [
    /* home */
    '.main-headings', '.service-card', '.about-section > .desc', '.pastor-row', '.pastor-rows',
    '.section-header', '.small-card', '.wide-card', '.yt-wrap', '.college-box', '.mt-home-card',
    '.section-title', '.outreach-card', '.give-container',
    /* about */
    '.value-card', '.belief-card', '.top-cards > *', '.bottom-cards > *',
    /* ministry + outreach pages */
    '[class$="-image"]', '[class$="-content"]', '[class*="-gallery"] > *', '.gallery > *',
    '.info-box', '.info-box2', '.mission-box', '.quote-section', '.verse',
    /* bible college */
    '.chairman-container', '.vm-container', '.course-container > *', '.facilities-container', '.faculty-card',
    /* contact, give, news */
    '.contact-left', '.contact-right', '.contact-bottom > *', '.offer-card', '.image-box', '.text-box', '.news-card',
    /* pastors, apply, matrimony */
    '.pf-person', '.pf-story', '.pf-facts', '.pf-cta', '.ap-card', '.ap-side', '.mt-open-card', '.mt-faith', '.mt-how', '.mt-steps > *'
  ].join(',');
  // the banner intro boxes, the Bible College hero and the home outreach carousel stay as they are
  var SKIP_INSIDE = '.about-contents, [class$="-contents"], .hero, .outreach-grid';

  var io = new IntersectionObserver(function (entries) {
    var n = 0;
    entries.forEach(function (e) {
      if (!e.isIntersecting) return;
      var el = e.target;
      el.setAttribute('data-mf-d', String(Math.min(n++, 4)));   // stagger blocks arriving together
      el.setAttribute('data-mf', 'in');
      io.unobserve(el);
    });
  }, { rootMargin: '0px 0px -8% 0px', threshold: 0.12 });

  function scan() {
    var page = document.querySelector('router-outlet + *');
    if (!page) return;
    var list = page.querySelectorAll(BLOCKS);
    for (var i = 0; i < list.length; i++) {
      var el = list[i];
      if (el.hasAttribute('data-mf')) continue;
      var parent = el.parentElement;
      if (parent && (parent.closest(SKIP_INSIDE) || (page.contains(parent) && parent !== page && parent.closest(BLOCKS) && page.contains(parent.closest(BLOCKS))))) {
        el.setAttribute('data-mf', 'skip');                      // nested in another block: moves with it
        continue;
      }
      var r = el.getBoundingClientRect();
      if (r.top < innerHeight * 0.92) { el.setAttribute('data-mf', 'skip'); continue; }   // already on screen
      el.setAttribute('data-mf', 'wait');
      io.observe(el);
    }
  }

  var queued = false;
  function queue() { if (!queued) { queued = true; setTimeout(function () { queued = false; scan(); }, 50); } }
  new MutationObserver(queue).observe(document.documentElement, { childList: true, subtree: true });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', queue); else queue();
})();
