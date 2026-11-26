/* Messiah Fellowship – behaviour for pages built outside the Angular app
   (currently /pastors/). Gives the shared header and footer the same
   behaviour the app provides on every other page:
   - ☰ button opens / closes the phone menu
   - footer prayer form validates and sends to the same email service */
(function () {
  'use strict';

  /* ---------- ☰ menu ---------- */
  document.addEventListener('click', function (e) {
    var links = document.querySelector('.nav-links');
    if (!links) return;
    if (e.target.closest('.menu-icon')) { links.classList.toggle('active'); return; }
    if (e.target.closest('.nav-links a[href]')) links.classList.remove('active');
  });
  var icon = document.querySelector('.menu-icon');
  if (icon) {
    icon.setAttribute('role', 'button');
    icon.setAttribute('tabindex', '0');
    icon.setAttribute('aria-label', 'Menu');
    icon.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); icon.click(); }
    });
  }

  /* ---------- footer links (written for the app as <p routerlink="...">) ---------- */
  document.addEventListener("click", function (e) {
    var p = e.target.closest("[routerlink]:not(a)");
    if (p && !p.dataset.mfGo) location.href = p.getAttribute("routerlink");
  });

  /* ---------- footer prayer form ---------- */
  var form = document.querySelector('form.prayer-form');
  if (!form) return;
  var btn = form.querySelector('button[type="submit"]');
  var msg = form.querySelector('.msg-success');
  var email = form.querySelector('input[name="email"]');
  if (email) email.setAttribute('pattern', '[^@\\s]+@[^@\\s]+\\.[^@\\s]+');   // same rule as the app's email check

  function refresh() { if (btn) btn.disabled = !form.checkValidity(); }
  form.addEventListener('input', refresh);
  form.addEventListener('change', refresh);
  refresh();

  form.addEventListener('submit', function (e) {
    e.preventDefault();
    if (!form.checkValidity()) { form.reportValidity(); return; }
    var data = {};
    Array.prototype.forEach.call(form.elements, function (el) { if (el.name) data[el.name] = el.value; });
    btn.disabled = true;
    msg.textContent = 'Message sending please wait...';
    fetch('https://messiah-backend-20.onrender.com/send-email', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    }).then(function (r) {
      if (!r.ok) throw new Error('Failed to send');
      msg.textContent = 'Thank you! Your prayer request has been sent. We will be praying with you.';
      form.reset();
      refresh();
    }).catch(function () {
      msg.textContent = 'Sorry, your request could not be sent. Please try again, or call +91 94947 67633.';
      refresh();
    });
  });
})();
