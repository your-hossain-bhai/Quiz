/* quizhub landing page — interactivity */
(function () {
  'use strict';

  // CONFIG
  // =========
  // API base is configurable: set window.QUIZHUB_API_BASE_URL before this script loads.
  // Defaults to './' which means endpoints are fetched relative to the current page.
  // In production, point this at the URL where bdapps_api_php/ is hosted, e.g.:
  //   <script>window.QUIZHUB_API_BASE_URL = 'https://quizhub.your-domain.com';</script>
  const CONFIG = {
    apiBase: (window.QUIZHUB_API_BASE_URL || './').replace(/\/+$/, '') + '/',
    apkMetaPath: 'apk-meta.json',
    defaultApkUrl: 'https://github.com/your-hossain-bhai/Quiz/releases/latest',
  };

  // UTILS
  // =====
  const $ = (sel, root = document) => root.querySelector(sel);
  const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));

  function escapeHtml(str) {
    return String(str).replace(/[&<>"']/g, (c) => ({
      '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    })[c]);
  }

  // TOAST
  // =====
  let toastTimer = null;
  function toast(message, type = 'info') {
    const t = $('#toast');
    if (!t) return;
    t.textContent = message;
    t.classList.remove('success', 'error', 'info');
    t.classList.add(type);
    t.hidden = false;
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => { t.hidden = true; }, 4500);
  }

  // API WRAPPER
  // ============
  // PHP backend reads form-encoded POST fields (user_mobile, Otp, referenceNo).
  // So we send application/x-www-form-urlencoded, not JSON.
  async function apiPost(endpoint, payload) {
    const url = CONFIG.apiBase + endpoint.replace(/^\/+/, '');
    const body = new URLSearchParams();
    Object.entries(payload || {}).forEach(([k, v]) => {
      if (v !== undefined && v !== null) body.append(k, String(v));
    });
    let res;
    try {
      res = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: body.toString(),
      });
    } catch (err) {
      throw new Error('Network error — could not reach ' + url);
    }
    const text = await res.text();
    let data;
    try { data = text ? JSON.parse(text) : {}; }
    catch { data = { raw: text, statusCode: 'PARSE_ERROR', statusDetail: text.slice(0, 200) }; }
    return { ok: res.ok, status: res.status, data };
  }

  // BDApps response parser — handles multiple response shapes used in the PHP endpoints.
  function interpretBdApps(endpoint, data) {
    if (!data) return { ok: false, message: 'Empty response from server' };
    const statusCode = String(data.statusCode || '').toUpperCase();
    const statusDetail = data.statusDetail || data.message || '';
    const success = Boolean(data.success);

    // S1000 = success in BDApps APIs
    if (statusCode === 'S1000') return { ok: true, message: statusDetail || 'OK' };

    // Check subscription
    if (endpoint.includes('check_subscription')) {
      const subscribed = data.isSubscribed === true || /REGISTERED|ACTIVE/i.test(String(data.subscriptionStatus || ''));
      return {
        ok: true,
        subscribed,
        message: subscribed ? '✓ Active subscription' : 'No active subscription',
      };
    }

    // Send OTP
    if (endpoint.includes('send_otp')) {
      if (success || data.referenceNo) return { ok: true, message: 'OTP sent! Check your phone.' };
      return { ok: false, message: statusDetail || 'Failed to send OTP' };
    }

    // Verify OTP
    if (endpoint.includes('verify_otp')) {
      if (statusCode === 'S1000' || success) return { ok: true, message: '✓ Subscribed successfully!' };
      return { ok: false, message: statusDetail || 'Verification failed' };
    }

    // Unsubscribe
    if (endpoint.includes('unsubscribe')) {
      if (success || statusCode === 'S1000') return { ok: true, message: '✓ Unsubscribed successfully' };
      return { ok: false, message: statusDetail || 'Unsubscribe failed' };
    }

    // Generic
    if (success) return { ok: true, message: statusDetail || 'OK' };
    return { ok: false, message: statusDetail || 'Request failed' };
  }

  function setResult(node, type, message) {
    if (!node) return;
    node.textContent = message;
    node.className = 'result-chip ' + type;
  }

  // MOBILE NAV
  // ===========
  function wireNav() {
    const toggle = $('#navToggle');
    const menu = $('#mobileMenu');
    if (!toggle || !menu) return;
    toggle.addEventListener('click', () => {
      const open = menu.classList.toggle('is-open');
      toggle.setAttribute('aria-expanded', String(open));
    });
    menu.addEventListener('click', (e) => {
      if (e.target.tagName === 'A') {
        menu.classList.remove('is-open');
        toggle.setAttribute('aria-expanded', 'false');
      }
    });
  }

  // SMOOTH SCROLL
  // ==============
  function wireAnchors() {
    document.addEventListener('click', (e) => {
      const a = e.target.closest('a[href^="#"]');
      if (!a) return;
      const href = a.getAttribute('href');
      if (!href || href === '#') return;
      const target = document.querySelector(href);
      if (!target) return;
      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  }

  // APK DOWNLOAD
  // =============
  function wireDownload() {
    const btn = $('#downloadApkBtn');
    const link = $('#apkStatusLink');
    const sizeLabel = $('#apkSizeLabel');
    const hint = $('#apkHint');
    if (!btn) return;

    fetch(CONFIG.apkMetaPath, { cache: 'no-store' })
      .then((r) => (r.ok ? r.json() : null))
      .then((meta) => {
        if (meta && meta.url) {
          btn.setAttribute('href', meta.url);
          if (meta.filename) btn.setAttribute('download', meta.filename);
          if (sizeLabel && meta.size) sizeLabel.textContent = meta.size;
          if (link) {
            link.textContent = meta.releaseUrl ? 'View release notes' : 'View APK details';
            link.setAttribute('href', meta.releaseUrl || meta.url);
          }
          if (hint && meta.version) {
            const tag = meta.size ? ` · <code>${escapeHtml(meta.size)}</code>` : '';
            hint.innerHTML = `Current build: <code>${escapeHtml(meta.version)}</code>${tag}`;
          }
        } else {
          if (link) {
            link.textContent = 'How to build the APK →';
            link.setAttribute('href', '#build');
          }
          if (hint) {
            hint.innerHTML = 'No APK found. Run <code>flutter build apk --release</code> from <code>client_app/</code> and drop the file into <code>client_app/build/app/outputs/flutter-apk/</code>. The download button will detect it automatically.';
          }
        }
      })
      .catch(() => {
        if (link) {
          link.textContent = 'How to build the APK →';
          link.setAttribute('href', '#build');
        }
      });

    btn.addEventListener('click', (e) => {
      const href = btn.getAttribute('href');
      if (!href || href === '#' || href === '') {
        e.preventDefault();
        location.hash = '#download';
        toast('APK not available yet — see build instructions below.', 'info');
      }
    });
  }

  // LOGIN MODAL
  // ============
  // The landing page login is a friendly magic-link request. There's no auth backend
  // in this repo yet, so we POST to <apiBase>/bdapps_api_php/login.php if it exists;
  // otherwise we show a clear status explaining where the real auth lives.
  function wireLogin() {
    const modal = $('#loginModal');
    const form = $('#loginForm');
    const result = $('#loginResult');
    if (!modal || !form) return;

    function open() {
      modal.hidden = false;
      modal.setAttribute('aria-hidden', 'false');
      setTimeout(() => $('#loginEmail')?.focus(), 50);
      document.body.style.overflow = 'hidden';
    }
    function close() {
      modal.hidden = true;
      modal.setAttribute('aria-hidden', 'true');
      document.body.style.overflow = '';
      if (result) { result.textContent = ''; result.className = 'result-chip'; }
    }

    document.addEventListener('click', (e) => {
      const trigger = e.target.closest('[data-action="open-login"]');
      if (trigger) { e.preventDefault(); open(); }
    });
    modal.addEventListener('click', (e) => {
      if (e.target.classList.contains('modal-backdrop') || e.target.classList.contains('modal-close')) close();
    });
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && !modal.hidden) close();
    });

    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      const email = $('#loginEmail').value.trim();
      const password = $('#loginPassword').value;
      if (!email || !password) {
        setResult(result, 'error', 'Email and password are required.');
        return;
      }
      if (!/^\S+@\S+\.\S+$/.test(email)) {
        setResult(result, 'error', 'Please enter a valid email address.');
        return;
      }
      setResult(result, 'info', 'Signing you in…');
      try {
        const res = await apiPost('bdapps_api_php/login.php', { email, password });
        const ok = res.ok && (res.data.statusCode === 'S1000' || res.data.success === true);
        if (ok) {
          setResult(result, 'success', '✓ Signed in. Welcome back!');
          toast('Login successful', 'success');
          setTimeout(close, 1200);
        } else {
          setResult(result, 'error', res.data.statusDetail || res.data.message || 'Login failed. Please try again.');
        }
      } catch (err) {
        // If the backend doesn't exist (404) or the host can't reach it, fall back to a
        // helpful message instead of a confusing "Network error".
        setResult(result, 'error', 'Login service is not configured yet. Use the mobile app to sign in for now.');
      }
    });
  }

  // TAB SWITCHING
  // ==============
  function wireTabs() {
    const buttons = $$('[data-tab]');
    const panels = $$('.panel');
    buttons.forEach((btn) => {
      btn.addEventListener('click', () => {
        const target = btn.dataset.tab;
        buttons.forEach((b) => {
          const active = b === btn;
          b.classList.toggle('is-active', active);
          b.setAttribute('aria-selected', String(active));
        });
        panels.forEach((p) => {
          const active = p.dataset.panel === target;
          p.classList.toggle('is-active', active);
          p.hidden = !active;
        });
      });
    });
  }

  // SUBSCRIBE
  // ==========
  function wireSubscribe() {
    const checkForm = $('#checkForm');
    const checkMobile = $('#checkMobile');
    const checkResult = $('#checkResult');

    const subscribeForm = $('#subscribeForm');
    const subscribeMobile = $('#subscribeMobile');
    const sendOtpBtn = $('#sendOtpBtn');
    const otpField = $('#otpField');
    const otpInput = $('#otpInput');
    const verifyOtpBtn = $('#verifyOtpBtn');
    const subscribeResult = $('#subscribeResult');

    const unsubForm = $('#unsubscribeForm');
    const unsubResult = $('#unsubscribeResult');

    const API_BASE = $('#apiBaseLabel');
    if (API_BASE) API_BASE.textContent = CONFIG.apiBase;

    // Track referenceNo from send_otp so verify_otp can use it
    let lastReferenceNo = '';

    if (checkForm) {
      checkForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const mobile = checkMobile.value.trim();
        if (!mobile) return setResult(checkResult, 'error', 'Please enter a mobile number.');
        setResult(checkResult, 'info', 'Checking subscription…');
        try {
          const res = await apiPost('bdapps_api_php/check_subscription.php', { user_mobile: mobile });
          const parsed = interpretBdApps('check_subscription.php', res.data);
          if (parsed.subscribed === true) {
            setResult(checkResult, 'success', '✓ Active subscription found');
          } else if (parsed.subscribed === false) {
            setResult(checkResult, 'info', 'No active subscription. Use the Subscribe tab to subscribe.');
          } else {
            setResult(checkResult, parsed.ok ? 'success' : 'error', parsed.message);
          }
        } catch (err) {
          setResult(checkResult, 'error', 'Could not reach the API: ' + err.message);
        }
      });
    }

    if (sendOtpBtn) {
      sendOtpBtn.addEventListener('click', async () => {
        const mobile = subscribeMobile.value.trim();
        if (!mobile) return setResult(subscribeResult, 'error', 'Please enter a mobile number first.');
        setResult(subscribeResult, 'info', 'Sending OTP…');
        sendOtpBtn.disabled = true;
        try {
          const res = await apiPost('bdapps_api_php/send_otp.php', { user_mobile: mobile });
          const parsed = interpretBdApps('send_otp.php', res.data);
          if (parsed.ok) {
            setResult(subscribeResult, 'success', 'OTP sent! Check your phone.');
            otpField.hidden = false;
            lastReferenceNo = res.data.referenceNo || '';
            otpInput.focus();
          } else {
            setResult(subscribeResult, 'error', parsed.message);
          }
        } catch (err) {
          setResult(subscribeResult, 'error', 'Could not reach the API: ' + err.message);
        } finally {
          sendOtpBtn.disabled = false;
        }
      });
    }

    if (subscribeForm) {
      subscribeForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const mobile = subscribeMobile.value.trim();
        const otp = otpInput.value.trim();
        if (!mobile) return setResult(subscribeResult, 'error', 'Please enter a mobile number.');
        if (!otp) return setResult(subscribeResult, 'error', 'Please enter the OTP.');
        if (!lastReferenceNo) return setResult(subscribeResult, 'error', 'Please click "Send OTP" first.');
        setResult(subscribeResult, 'info', 'Verifying…');
        verifyOtpBtn.disabled = true;
        try {
          const res = await apiPost('bdapps_api_php/verify_otp.php', { Otp: otp, referenceNo: lastReferenceNo });
          const parsed = interpretBdApps('verify_otp.php', res.data);
          if (parsed.ok) {
            setResult(subscribeResult, 'success', '✓ Subscribed successfully!');
            toast('Subscription activated 🎉', 'success');
            otpInput.value = '';
            lastReferenceNo = '';
            otpField.hidden = true;
          } else {
            setResult(subscribeResult, 'error', parsed.message);
          }
        } catch (err) {
          setResult(subscribeResult, 'error', 'Could not reach the API: ' + err.message);
        } finally {
          verifyOtpBtn.disabled = false;
        }
      });
    }

    if (unsubForm) {
      unsubForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const mobile = $('#unsubMobile').value.trim();
        if (!mobile) return setResult(unsubResult, 'error', 'Please enter a mobile number.');
        setResult(unsubResult, 'info', 'Unsubscribing…');
        try {
          const res = await apiPost('bdapps_api_php/unsubscribe.php', { user_mobile: mobile });
          const parsed = interpretBdApps('unsubscribe.php', res.data);
          if (parsed.ok) {
            setResult(unsubResult, 'success', '✓ Unsubscribed successfully.');
            toast('Subscription cancelled', 'info');
          } else {
            setResult(unsubResult, 'error', parsed.message);
          }
        } catch (err) {
          setResult(unsubResult, 'error', 'Could not reach the API: ' + err.message);
        }
      });
    }
  }

  // SCROLL REVEAL
  // ==============
  function wireReveal() {
    const targets = $$('[data-reveal]');
    if (!targets.length || !('IntersectionObserver' in window)) {
      targets.forEach((t) => t.classList.add('is-in'));
      return;
    }
    const io = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-in');
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
    targets.forEach((t) => io.observe(t));
  }

  // INIT
  // ====
  document.addEventListener('DOMContentLoaded', () => {
    wireNav();
    wireAnchors();
    wireDownload();
    wireLogin();
    wireTabs();
    wireSubscribe();
    wireReveal();
  });
})();
