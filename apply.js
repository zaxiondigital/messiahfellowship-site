/* Messiah Fellowship – Bible College admission form (/apply/)
   - ?course=bth|dipth|cth preselects the course (from the "Apply Now" buttons)
   - shows each course's duration / qualification and warns (does not block)
     if the chosen qualification is below the course requirement
   - checks fields on submit and shows the message under each field
   - sends the application to the church's email service */
(function () {
  'use strict';
  var form = document.getElementById('apply-form');
  if (!form) return;
  var ENDPOINT = 'https://api.web3forms.com/submit';
  var W3F_KEY = '6be91bf5-bbfb-4ccf-ab0d-9f123fd31acd';
  var course = form.elements.course, qual = form.elements.qualification;
  var hint = document.getElementById('ap-course-hint');
  var status = form.querySelector('.ap-status');
  var btn = form.querySelector('button[type="submit"]');
  var INFO = {
    bth:   'Duration: 3 years · Qualification: Inter',
    dipth: 'Duration: 2 years · Qualification: Inter',
    cth:   'Duration: 1 year · Qualification: SSC'
  };

  /* ---------- preselect course from the link ---------- */
  var want = (new URLSearchParams(location.search).get('course') || '').toLowerCase();
  Array.prototype.forEach.call(course.options, function (o) { if (o.dataset.key === want) course.value = o.value; });

  function courseHint() {
    var c = course.selectedOptions[0], q = qual.selectedOptions[0];
    if (!c || !c.dataset.key) { hint.textContent = ''; hint.classList.remove('is-warn'); return; }
    var warn = c.dataset.min === 'inter' && q && q.dataset.level === 'ssc';
    hint.textContent = warn
      ? INFO[c.dataset.key] + '. This course needs Inter; you can still apply and our team will guide you.'
      : INFO[c.dataset.key];
    hint.classList.toggle('is-warn', warn);
  }
  course.addEventListener('change', courseHint);
  qual.addEventListener('change', courseHint);
  courseHint();

  /* ---------- validation ---------- */
  function phoneOk() {
    var v = form.elements.phone.value.replace(/[\s-]/g, '');
    return form.elements.countryCode.value === '+91' ? /^[6-9]\d{9}$/.test(v) : /^\d{6,15}$/.test(v);
  }
  var CHECKS = {
    course: function () { return course.value ? '' : 'Please choose a course.'; },
    name: function (el) { return el.value.trim().length >= 2 ? '' : 'Please enter the student’s full name.'; },
    dob: function (el) { return el.value ? '' : 'Please enter the date of birth.'; },
    gender: function () { return form.querySelector('input[name="gender"]:checked') ? '' : 'Please choose one.'; },
    qualification: function () { return qual.value ? '' : 'Please choose your highest qualification.'; },
    phone: function (el) {
      if (!el.value.trim()) return 'Please enter a mobile number.';
      return phoneOk() ? '' : (form.elements.countryCode.value === '+91'
        ? 'Please enter a valid 10-digit mobile number.' : 'Please enter a valid phone number.');
    },
    email: function (el) {
      if (!el.value.trim()) return 'Please enter an email address.';
      return /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(el.value.trim()) ? '' : 'Please enter a valid email address.';
    },
    city: function (el) { return el.value.trim() ? '' : 'Please enter your city or town.'; }
  };
  function fieldBox(name) {
    var el = form.elements[name];
    var node = el.length && !el.tagName ? el[0] : el;   // radio group → first radio
    return node.closest('.ap-field');
  }
  function check(name) {
    var el = form.elements[name], msg = CHECKS[name](el), box = fieldBox(name);
    var err = box.querySelector('.ap-error');
    if (msg) {
      if (!err) { err = document.createElement('p'); err.className = 'ap-error'; err.id = 'err-' + name; box.appendChild(err); }
      err.textContent = msg;
      box.classList.add('is-invalid');
    } else if (err) { err.remove(); box.classList.remove('is-invalid'); }
    var input = el.length && !el.tagName ? el[0] : el;
    input.setAttribute('aria-invalid', msg ? 'true' : 'false');
    if (msg) input.setAttribute('aria-describedby', 'err-' + name); else input.removeAttribute('aria-describedby');
    return !msg;
  }
  // re-check a field once the person fixes it
  form.addEventListener('input', function (e) {
    var n = e.target.name === 'countryCode' ? 'phone' : e.target.name;
    if (CHECKS[n] && fieldBox(n).classList.contains('is-invalid')) check(n);
  });
  form.addEventListener('change', function (e) {
    var n = e.target.name === 'countryCode' ? 'phone' : e.target.name;
    if (CHECKS[n] && fieldBox(n).classList.contains('is-invalid')) check(n);
  });

  /* ---------- send ---------- */
  function val(n) {
    var el = form.elements[n];
    if (el && el.length && !el.tagName) { var c = form.querySelector('input[name="' + n + '"]:checked'); return c ? c.value : ''; }
    return el ? el.value.trim() : '';
  }
  form.addEventListener('submit', function (e) {
    e.preventDefault();
    var first = null;
    Object.keys(CHECKS).forEach(function (n) { if (!check(n) && !first) first = n; });
    if (first) {
      var el = form.elements[first]; (el.length && !el.tagName ? el[0] : el).focus();
      status.textContent = 'Please check the highlighted fields.'; status.className = 'ap-status is-error';
      return;
    }
    var dob = val('dob').split('-').reverse().join('/');   // dd/mm/yyyy
    var lines = [
      'NEW ADMISSION APPLICATION – Messiah Bible College', '',
      'Course: ' + val('course'),
      'Student name: ' + val('name'),
      'Date of birth: ' + dob,
      'Gender: ' + val('gender'),
      'Highest qualification: ' + val('qualification'),
      'Mobile: ' + val('countryCode') + ' ' + val('phone'),
      'Email: ' + val('email'),
      'City / Town: ' + val('city') + (val('state') ? ', ' + val('state') : ''),
      'Church & pastor: ' + (val('church') || '–'),
      'Hostel needed: ' + (val('hostel') || '–'), '',
      'Why they would like to join:', val('why') || '–'
    ];
    var data = {
      access_key: W3F_KEY, from_name: 'Messiah Fellowship website',
      name: val('name'), email: val('email'), countryCode: val('countryCode'), phone: val('phone'),
      city: val('city'), subject: 'Bible College application – ' + val('course'),
      message: lines.join('\n')
    };
    btn.disabled = true;
    btn.textContent = 'Sending…';
    status.className = 'ap-status';
    status.textContent = 'Sending your application…';
    fetch(ENDPOINT, { method: 'POST', headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' }, body: JSON.stringify(data) })
      .then(function (r) { if (!r.ok) throw new Error(r.status); })
      .then(function () {
        var done = document.querySelector('.ap-done');
        form.hidden = true;
        done.querySelector('h2').textContent = 'Thank you, ' + val('name').split(' ')[0] + '!';
        done.hidden = false;
        done.scrollIntoView({ behavior: 'smooth', block: 'center' });
        done.focus({ preventScroll: true });
      })
      .catch(function () {
        btn.disabled = false;
        btn.textContent = 'Submit Application';
        status.className = 'ap-status is-error';
        status.textContent = 'Sorry, your application could not be sent. Please try again, or call +91 94947 67633.';
      });
  });
})();
