/* Messiah Fellowship – "Partner in Service" popup
   The PARTNER IN SERVICE buttons (Flood Relief, Medical) had no destination.
   They now open a short "I'm interested" form in a dialog:
     name · mobile/WhatsApp (+ country code) · email · how you'd like to partner · message
   The page it came from is added automatically. Sent to the church's email
   service (same as the prayer / contact forms; it can take ~30 s to wake up).
   Opens only on click; Esc / ✕ / clicking outside closes; phones get a bottom sheet. */
(function () {
  'use strict';
  var ENDPOINT = 'https://api.web3forms.com/submit';
  var W3F_KEY = '6be91bf5-bbfb-4ccf-ab0d-9f123fd31acd';
  var PAGES = {
    floodrelief: 'Flood Relief', medical: 'Medical Ministry', widowcare: 'Widow Care Ministry',
    kamalaarts: 'Kamala Arts & Craft', vegetables: 'Vegetable Distribution'
  };
  var WAYS = ['Volunteer my time', 'Professional help (doctor, nurse, other)', 'Give financially', 'Donate supplies', 'Pray for this ministry'];
  var dlg, form, lastFocus;

  function ministry() {
    var key = location.pathname.replace(/^\/+|\/+$/g, '');
    return PAGES[key] || 'Our ministries';
  }

  function build() {
    dlg = document.createElement('dialog');
    dlg.className = 'pt-dialog';
    dlg.setAttribute('aria-labelledby', 'pt-title');
    dlg.innerHTML =
      '<div class="pt-sheet">' +
        '<button type="button" class="pt-close" aria-label="Close">×</button>' +
        '<div class="pt-body">' +
          '<h2 id="pt-title">Partner in service</h2>' +
          '<p class="pt-intro">Thank you for wanting to serve with us. Share a few details and our team will get in touch.</p>' +
          '<form novalidate>' +
            '<div class="pt-field"><label for="pt-name">Your name <b aria-hidden="true">*</b></label>' +
              '<input id="pt-name" name="name" type="text" autocomplete="name" required></div>' +
            '<div class="pt-field"><label for="pt-phone">Mobile / WhatsApp <b aria-hidden="true">*</b></label>' +
              '<div class="pt-phone"><select name="countryCode" aria-label="Country code">' +
                '<option value="+91">+91</option><option value="+1">+1</option><option value="+44">+44</option>' +
                '<option value="+61">+61</option><option value="+971">+971</option><option value="+65">+65</option>' +
              '</select><input id="pt-phone" name="phone" type="tel" inputmode="tel" autocomplete="tel-national" required></div></div>' +
            '<div class="pt-field"><label for="pt-email">Email <b aria-hidden="true">*</b></label>' +
              '<input id="pt-email" name="email" type="email" autocomplete="email" required></div>' +
            '<fieldset class="pt-field pt-ways"><legend>How would you like to partner? <b aria-hidden="true">*</b> <span>(choose any)</span></legend>' +
              WAYS.map(function (w, i) {
                return '<label class="pt-check"><input type="checkbox" name="ways" value="' + w + '"' + (i === 0 ? ' id="pt-way0"' : '') + '> <span>' + w + '</span></label>';
              }).join('') +
            '</fieldset>' +
            '<div class="pt-field"><label for="pt-msg">Message <span class="pt-opt">(optional)</span></label>' +
              '<textarea id="pt-msg" name="message" rows="3"></textarea></div>' +
            '<p class="pt-privacy">We’ll only use your details to contact you about this ministry.</p>' +
            '<button type="submit" class="pt-submit">Send my interest</button>' +
            '<p class="pt-status" role="status" aria-live="polite"></p>' +
          '</form>' +
          '<div class="pt-done" hidden tabindex="-1">' +
            '<div class="pt-done-icon" aria-hidden="true">✓</div>' +
            '<h2 class="pt-done-title">Thank you!</h2>' +
            '<p>Your interest has been sent. Our team will contact you in the next few days.</p>' +
            '<button type="button" class="pt-submit pt-done-close">Close</button>' +
          '</div>' +
        '</div>' +
      '</div>';
    document.body.appendChild(dlg);
    form = dlg.querySelector('form');

    dlg.querySelector('.pt-close').addEventListener('click', close);
    dlg.querySelector('.pt-done-close').addEventListener('click', close);
    dlg.addEventListener('click', function (e) { if (e.target === dlg) close(); });   // click on the backdrop
    dlg.addEventListener('close', cleanup);
    dlg.addEventListener('keydown', function (e) { if (e.key === 'Escape') { e.preventDefault(); close(); } });
    form.addEventListener('submit', submit);
    form.addEventListener('input', function (e) { var f = e.target.closest('.pt-field'); if (f && f.classList.contains('is-invalid')) validate(); });
    form.addEventListener('change', function (e) { var f = e.target.closest('.pt-field'); if (f && f.classList.contains('is-invalid')) validate(); });
  }

  function open(from) {
    if (!dlg) build();
    lastFocus = from || document.activeElement;
    var m = ministry();
    dlg.dataset.ministry = m;
    form.hidden = false;
    dlg.querySelector('.pt-done').hidden = true;
    setStatus('');
    if (typeof dlg.showModal === 'function') dlg.showModal(); else dlg.setAttribute('open', '');
    document.documentElement.classList.add('pt-open');
    setTimeout(function () { dlg.querySelector('#pt-name').focus(); }, 30);
  }
  function close() {
    if (dlg.open) { if (typeof dlg.close === 'function') dlg.close(); else dlg.removeAttribute('open'); }
    cleanup();
  }
  // unlock page scroll and give focus back to the button (safe to run twice)
  function cleanup() {
    document.documentElement.classList.remove('pt-open');
    if (lastFocus && document.contains(lastFocus)) { var f = lastFocus; lastFocus = null; f.focus(); }
  }

  /* ---------- validation ---------- */
  function setErr(field, msg) {
    var box = field.closest ? field.closest('.pt-field') : field;
    var err = box.querySelector('.pt-error');
    if (msg) {
      if (!err) { err = document.createElement('p'); err.className = 'pt-error'; box.appendChild(err); }
      err.textContent = msg; box.classList.add('is-invalid');
    } else if (err) { err.remove(); box.classList.remove('is-invalid'); }
    return !msg;
  }
  function validate() {
    var el = form.elements, ok = true, first = null;
    function chk(node, msg) { var good = setErr(node, msg); if (!good && !first) first = node; ok = ok && good; }
    chk(el.name, el.name.value.trim().length >= 2 ? '' : 'Please enter your name.');
    var ph = el.phone.value.replace(/[\s()-]/g, '');
    var phOk = el.countryCode.value === '+91' ? /^[6-9]\d{9}$/.test(ph) : /^\d{6,15}$/.test(ph);
    chk(el.phone, !ph ? 'Please enter your mobile number.' : (phOk ? '' : (el.countryCode.value === '+91' ? 'Please enter a valid 10-digit mobile number.' : 'Please enter a valid phone number.')));
    var em = el.email.value.trim();
    chk(el.email, !em ? 'Please enter your email.' : (/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(em) ? '' : 'Please enter a valid email address.'));
    var any = form.querySelectorAll('input[name="ways"]:checked').length > 0;
    chk(form.querySelector('.pt-ways'), any ? '' : 'Please choose at least one.');
    return first ? (first.matches && first.matches('fieldset') ? first.querySelector('input') : first) : null;
  }
  function setStatus(t, err) { var s = form.querySelector('.pt-status'); s.textContent = t; s.classList.toggle('is-error', !!err); }

  /* ---------- send ---------- */
  function submit(e) {
    e.preventDefault();
    var bad = validate();
    if (bad) { bad.focus(); setStatus('Please check the highlighted fields.', true); return; }
    var el = form.elements, m = dlg.dataset.ministry;
    var ways = Array.prototype.map.call(form.querySelectorAll('input[name="ways"]:checked'), function (c) { return c.value; });
    var lines = [
      'PARTNER IN SERVICE – new interest', '',
      'Ministry: ' + m,
      'Name: ' + el.name.value.trim(),
      'Mobile / WhatsApp: ' + el.countryCode.value + ' ' + el.phone.value.trim(),
      'Email: ' + el.email.value.trim(),
      'Would like to: ' + ways.join(', '), '',
      'Message:', el.message.value.trim() || '–', '',
      'Sent from: ' + location.href
    ];
    var btn = form.querySelector('.pt-submit');
    btn.disabled = true; btn.textContent = 'Sending…';
    setStatus('Sending…');
    fetch(ENDPOINT, {
      method: 'POST', headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
      body: JSON.stringify({
        access_key: W3F_KEY, from_name: 'Messiah Fellowship website',
        name: el.name.value.trim(), email: el.email.value.trim(),
        countryCode: el.countryCode.value, phone: el.phone.value.trim(),
        city: '', subject: 'Partner in Service – ' + m, message: lines.join('\n')
      })
    }).then(function (r) { if (!r.ok) throw new Error(r.status); })
      .then(function () {
        var done = dlg.querySelector('.pt-done');
        done.querySelector('.pt-done-title').textContent = 'Thank you, ' + el.name.value.trim().split(' ')[0] + '!';
        form.hidden = true; done.hidden = false; done.focus();
        form.reset();
      })
      .catch(function () { setStatus('Sorry, it could not be sent. Please try again, or call +91 94947 67633.', true); })
      .then(function () { btn.disabled = false; btn.textContent = 'Send my interest'; });
  }

  /* ---------- the buttons ---------- */
  function isPartner(a) { return a && a.textContent.replace(/\s+/g, ' ').trim().toUpperCase() === 'PARTNER IN SERVICE'; }
  document.addEventListener('click', function (e) {
    var a = e.target.closest && e.target.closest('a, button');
    if (!isPartner(a)) return;
    e.preventDefault(); e.stopPropagation();
    open(a);
  }, true);
  // say what it does (screen readers, hover)
  function label() {
    document.querySelectorAll('a[href="#"]').forEach(function (a) {
      if (isPartner(a) && !a.hasAttribute('aria-haspopup')) { a.setAttribute('aria-haspopup', 'dialog'); a.setAttribute('role', 'button'); }
    });
  }
  new MutationObserver(label).observe(document.documentElement, { childList: true, subtree: true });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', label); else label();
})();
