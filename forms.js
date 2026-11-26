/* Messiah Fellowship – form improvements (prayer form in every footer + Contact page form)
   1. Visible labels above every field (placeholders vanish while typing, which is
      hard for older visitors); placeholders become short examples.
   2. More country codes for overseas members (Gulf, Singapore, Malaysia, NZ, …).
   3. Pages built outside the app (/pastors/, /apply/, /matrimony/): the phone
      check follows the chosen country (it was India-only there).
   On app pages this waits until the app has taken over the form (hydration),
   so the added labels never disturb it; it re-runs when a page is redrawn. */
(function () {
  'use strict';
  // used as HTML pattern attributes (pages outside the app). Chrome reads these in
  // "v" mode, where - ( ) . inside [ ] must be escaped or the whole rule is ignored.
  var IN_PATTERN = '^\\s*0?[6-9](?:[\\s\\-]*\\d){9}\\s*$';               // India: 10 digits, starts 6–9
  var WW_PATTERN = '^\\s*\\(?(?:\\d[\\s\\(\\)\\.\\-]*){6,15}$';           // elsewhere: 6–15 digits, e.g. (555) 123-4567
  var EXTRA_CODES = ['+64', '+971', '+966', '+974', '+965', '+968', '+973', '+65', '+60', '+49', '+353', '+27', '+254'];
  var isApp = !!document.querySelector('script[src*="main-"]');

  var FIELDS = {
    prayer: {
      name:    ['Your name', 'e.g. Ravi Kumar'],
      email:   ['Email', 'name@example.com'],
      city:    ['City / Town', 'e.g. Vijayawada'],
      phone:   ['Phone / WhatsApp', 'Mobile number'],
      message: ['Prayer request', 'How can we pray for you?']
    },
    contact: {
      name:    ['Full name', 'e.g. Ravi Kumar'],
      email:   ['Email', 'name@example.com'],
      subject: ['Subject', 'What is this about?'],
      message: ['Message', 'Write your message here']
    }
  };
  var uid = 0;

  function ready(form) {
    if (!isApp) return true;
    return form.__ngContext__ !== undefined;            // set once the app owns this element
  }

  function addLabel(form, name, text, example) {
    var el = form.querySelector('[name="' + name + '"]');
    if (!el || el.dataset.mfLabelled) return;
    el.dataset.mfLabelled = '1';
    if (!el.id) el.id = 'f-' + name + '-' + (++uid);
    el.setAttribute('placeholder', example);
    var lab = document.createElement('label');
    lab.className = 'fld-label';
    lab.htmlFor = el.id;
    lab.textContent = text;
    if (el.required || el.hasAttribute('required')) {
      var star = document.createElement('b'); star.setAttribute('aria-hidden', 'true'); star.textContent = ' *';
      lab.appendChild(star);
    }
    var anchor = name === 'phone' && el.closest('.phone-group') ? el.closest('.phone-group') : el;
    anchor.parentNode.insertBefore(lab, anchor);
  }

  function addCodes(select) {
    if (!select || select.dataset.mfCodes) return;
    select.dataset.mfCodes = '1';
    select.setAttribute('aria-label', 'Country code');
    var have = Array.prototype.map.call(select.options, function (o) { return o.value; });
    EXTRA_CODES.forEach(function (code) {
      if (have.indexOf(code) >= 0) return;
      var o = document.createElement('option'); o.value = code; o.textContent = code;
      select.appendChild(o);
    });
  }

  function staticPhoneRule(form) {                      // only for pages without the app
    if (isApp || form.dataset.mfPhone) return;
    var sel = form.querySelector('select[name="countryCode"]'), ph = form.querySelector('input[name="phone"]');
    if (!sel || !ph) return;
    form.dataset.mfPhone = '1';
    var apply = function () { ph.setAttribute('pattern', sel.value === '+91' ? IN_PATTERN : WW_PATTERN); };
    sel.addEventListener('change', function () { apply(); ph.dispatchEvent(new Event('input', { bubbles: true })); });
    apply();
  }

  function run() {
    document.querySelectorAll('form.prayer-form').forEach(function (form) {
      if (!ready(form)) return;
      Object.keys(FIELDS.prayer).forEach(function (n) { addLabel(form, n, FIELDS.prayer[n][0], FIELDS.prayer[n][1]); });
      addCodes(form.querySelector('select[name="countryCode"]'));
      staticPhoneRule(form);
    });
    document.querySelectorAll('.contact-right form').forEach(function (form) {
      if (!ready(form)) return;
      Object.keys(FIELDS.contact).forEach(function (n) { addLabel(form, n, FIELDS.contact[n][0], FIELDS.contact[n][1]); });
    });
  }

  var queued = false;
  function queue() { if (!queued) { queued = true; setTimeout(function () { queued = false; run(); }, 50); } }
  new MutationObserver(queue).observe(document.documentElement, { childList: true, subtree: true });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', queue); else queue();
  window.addEventListener('load', queue);
  // the app may finish taking over the page a little after load
  var tries = 0, t = setInterval(function () { run(); if (++tries > 20) clearInterval(t); }, 250);
})();
