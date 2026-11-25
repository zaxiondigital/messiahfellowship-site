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
})();
