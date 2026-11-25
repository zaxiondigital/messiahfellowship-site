/* Messiah Fellowship – Community Outreach carousel (home page)
   The ‹ › buttons had no behaviour in the original app. This small script:
   - scrolls the outreach cards one card at a time when an arrow is clicked
   - shows the arrows only when the cards don't all fit (adds .is-carousel)
   - disables ‹ at the start and › at the end
   Works across in-app navigation (the home page can be re-rendered by Angular). */
(function () {
  'use strict';
  var SECTION = '.outreach-section';
  var queued = false;

  function parts() {
    var grid = document.querySelector(SECTION + ' .outreach-grid');
    if (!grid) return null;
    var section = grid.closest(SECTION);
    var btns = section.querySelectorAll('.nav-buttons button');
    return { grid: grid, section: section, prev: btns[0], next: btns[1] };
  }

  function update() {
    queued = false;
    var p = parts();
    if (!p) return;
    var overflow = p.grid.scrollWidth > p.grid.clientWidth + 4;
    p.section.classList.toggle('is-carousel', overflow);
    if (p.prev && p.next) {
      p.prev.setAttribute('aria-label', 'Previous outreach');
      p.next.setAttribute('aria-label', 'Next outreach');
      p.prev.disabled = !overflow || p.grid.scrollLeft <= 4;
      p.next.disabled = !overflow || p.grid.scrollLeft + p.grid.clientWidth >= p.grid.scrollWidth - 4;
    }
  }
  function queue() { if (!queued) { queued = true; requestAnimationFrame(update); } }

  // arrow clicks (delegated, so it survives Angular re-rendering)
  document.addEventListener('click', function (e) {
    var btn = e.target.closest && e.target.closest(SECTION + ' .nav-buttons button');
    if (!btn) return;
    var p = parts();
    if (!p) return;
    e.preventDefault();
    // jump to an exact card (works even if clicked again mid-animation)
    var cards = Array.prototype.slice.call(p.grid.querySelectorAll('.outreach-card'));
    if (!cards.length) return;
    var base = cards[0].offsetLeft;
    var stops = cards.map(function (c) { return c.offsetLeft - base; });
    var max = p.grid.scrollWidth - p.grid.clientWidth;
    var target = p.grid._target != null ? p.grid._target : p.grid.scrollLeft;
    var i = 0, best = Infinity;
    stops.forEach(function (s, k) { var dd = Math.abs(s - target); if (dd < best) { best = dd; i = k; } });
    i = Math.max(0, Math.min(stops.length - 1, i + (btn === p.prev ? -1 : 1)));
    var left = Math.min(stops[i], max);
    p.grid._target = left;
    clearTimeout(p.grid._t); p.grid._t = setTimeout(function () { p.grid._target = null; }, 600);
    p.grid.scrollTo({ left: left, behavior: 'smooth' });
  });

  // keep arrow states in sync
  document.addEventListener('scroll', function (e) {
    if (e.target && e.target.classList && e.target.classList.contains('outreach-grid')) queue();
  }, true);
  window.addEventListener('resize', queue);
  new MutationObserver(queue).observe(document.documentElement, { childList: true, subtree: true });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', queue); else queue();
})();
