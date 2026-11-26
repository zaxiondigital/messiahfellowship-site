/* Messiah Fellowship – floating WhatsApp button (every page)
   Opens a chat with the church's WhatsApp number (from the church's YouTube
   description: "WhatsApp us at 90302 333 71") with a short greeting typed in.
   Added outside the app, so in-app navigation never removes it. */
(function () {
  'use strict';
  var NUMBER = '919030233371';
  var TEXT = 'Hello Messiah Fellowship, I found you on your website.';
  function add() {
    if (document.querySelector('.wa-float')) return;
    var a = document.createElement('a');
    a.className = 'wa-float';
    a.href = 'https://wa.me/' + NUMBER + '?text=' + encodeURIComponent(TEXT);
    a.target = '_blank';
    a.rel = 'noopener';
    a.setAttribute('aria-label', 'Chat with us on WhatsApp');
    a.innerHTML =
      '<svg viewBox="0 0 32 32" width="30" height="30" aria-hidden="true" focusable="false">' +
      '<path fill="#fff" d="M16.04 3C9.4 3 4 8.33 4 14.9c0 2.33.69 4.6 2 6.54L4.7 28l6.8-1.75a12.2 12.2 0 0 0 4.54.87h.01C22.68 27.12 28 21.79 28 15.22 28 8.65 22.68 3 16.04 3zm0 22.1h-.01a10.1 10.1 0 0 1-4.12-.9l-.3-.14-4.03 1.04 1.08-3.9-.2-.32a9.86 9.86 0 0 1-1.6-5.38c0-5.46 4.48-9.9 9.99-9.9 5.5 0 9.97 4.6 9.97 10.06 0 5.46-4.48 9.44-9.78 9.44zm5.47-7.4c-.3-.15-1.77-.87-2.04-.97-.28-.1-.48-.15-.68.15-.2.3-.78.97-.96 1.17-.18.2-.35.22-.65.07-.3-.15-1.27-.46-2.42-1.48-.9-.79-1.5-1.77-1.67-2.07-.18-.3-.02-.46.13-.61.13-.13.3-.35.45-.52.15-.18.2-.3.3-.5.1-.2.05-.38-.02-.53-.08-.15-.68-1.62-.93-2.22-.24-.58-.49-.5-.68-.51h-.58c-.2 0-.53.07-.8.37-.28.3-1.05 1.02-1.05 2.5 0 1.47 1.08 2.9 1.23 3.1.15.2 2.12 3.22 5.13 4.52.72.31 1.28.5 1.72.63.72.23 1.38.2 1.9.12.58-.09 1.77-.72 2.02-1.42.25-.7.25-1.3.17-1.42-.07-.13-.27-.2-.57-.35z"/>' +
      '</svg><span class="wa-label">Chat with us</span>';
    document.body.appendChild(a);
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', add); else add();
})();
