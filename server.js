/**
 * QuizHub dev server (Node.js) — single-file replacement for the PHP
 * dev stack. Serves the static landing page AND proxies the BDApps
 * endpoints with a deterministic mock so the subscribe / unsubscribe /
 * check flows can be exercised locally without PHP installed.
 *
 * In production, deploy the bdapps_api_php/ folder to your PHP host and
 * set window.QUIZHUB_API_BASE_URL on the landing page to its public URL.
 *
 * Usage:
 *   node server.js            # starts on http://localhost:8088
 *   PORT=4000 node server.js  # custom port
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PORT = process.env.PORT || 8088;
const ROOT = __dirname;

// In-memory mock subscription store. Keys are normalized mobile numbers
// (e.g. "01712345678"), values are { referenceNo, subscribed, createdAt }.
const subscriptions = new Map();
// referenceNo -> mobile while pending OTP verification
const pendingOtps = new Map();

function readBody(req) {
  return new Promise((resolve) => {
    let chunks = '';
    req.on('data', (c) => (chunks += c));
    req.on('end', () => resolve(chunks));
  });
}

function parseForm(body) {
  // application/x-www-form-urlencoded
  const out = {};
  if (!body) return out;
  body.split('&').forEach((pair) => {
    const [k, v = ''] = pair.split('=');
    if (k) out[decodeURIComponent(k)] = decodeURIComponent(v.replace(/\+/g, ' '));
  });
  return out;
}

function sendJson(res, status, payload) {
  const body = JSON.stringify(payload);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(body),
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Cache-Control': 'no-store',
  });
  res.end(body);
}

function send(res, status, contentType, body) {
  res.writeHead(status, {
    'Content-Type': contentType,
    'Content-Length': Buffer.byteLength(body),
    'Access-Control-Allow-Origin': '*',
    'Cache-Control': 'no-store',
  });
  res.end(body);
}

// Normalize to "01XXXXXXXXX" (11 digits, BD format).
function normalizeMobile(raw) {
  let d = String(raw || '').replace(/\D+/g, '');
  if (d.startsWith('880') && d.length === 13) d = '0' + d.slice(3);
  else if (d.startsWith('88') && d.length === 12) d = '0' + d.slice(2);
  if (!/^01[3-9][0-9]{8}$/.test(d)) return '';
  return d;
}

function randomRef() {
  return 'REF' + Date.now().toString(36).toUpperCase() + Math.floor(Math.random() * 1000);
}

const ROUTES = {
  // GET / — landing page
  'GET /': (req, res) => serveStatic(res, 'index.html', 'text/html; charset=utf-8'),

  // ---------- BDApps mock endpoints ----------

  'POST /bdapps_api_php/check_subscription.php': (req, res, body) => {
    const form = parseForm(body);
    const mobile = normalizeMobile(form.user_mobile);
    if (!mobile) return sendJson(res, 400, { error: 'Invalid mobile number format' });
    const entry = subscriptions.get(mobile);
    const isSubscribed = entry ? entry.subscribed === true : false;
    sendJson(res, 200, {
      subscriptionStatus: isSubscribed ? 'REGISTERED' : 'UNREGISTERED',
      isSubscribed,
      statusCode: 'S1000',
      statusDetail: isSubscribed ? 'User is currently subscribed' : 'User is not subscribed',
      subscriberId: 'tel:88' + mobile,
      _mock: true,
    });
  },

  'POST /bdapps_api_php/send_otp.php': (req, res, body) => {
    const form = parseForm(body);
    const mobile = normalizeMobile(form.user_mobile);
    if (!mobile) {
      return sendJson(res, 400, {
        success: false,
        message: 'Invalid mobile number format',
        referenceNo: null,
      });
    }
    const referenceNo = randomRef();
    pendingOtps.set(referenceNo, { mobile, otp: '1234', createdAt: Date.now() });
    // In real BDApps the OTP is sent via SMS. For local dev we hardcode 1234
    // so you can complete the verify step without a phone.
    sendJson(res, 200, {
      success: true,
      referenceNo,
      statusCode: 'S1000',
      statusDetail: 'OTP sent successfully. (Dev mock — use 1234)',
      subscriberId: 'tel:88' + mobile,
      _mock: true,
      devOtp: '1234',
    });
  },

  'POST /bdapps_api_php/verify_otp.php': (req, res, body) => {
    const form = parseForm(body);
    const otp = String(form.Otp || form.otp || '').trim();
    const referenceNo = String(form.referenceNo || '').trim();
    if (!otp || !referenceNo) {
      return sendJson(res, 400, {
        statusCode: 'E0001',
        statusDetail: 'OTP and reference number are required',
      });
    }
    const pending = pendingOtps.get(referenceNo);
    if (!pending) {
      return sendJson(res, 400, {
        statusCode: 'E0002',
        statusDetail: 'Invalid or expired reference number. Please request a new OTP.',
      });
    }
    if (otp !== pending.otp) {
      return sendJson(res, 401, {
        statusCode: 'E0003',
        statusDetail: 'Incorrect OTP. (Dev mock — use 1234)',
      });
    }
    subscriptions.set(pending.mobile, {
      subscribed: true,
      referenceNo,
      createdAt: Date.now(),
    });
    pendingOtps.delete(referenceNo);
    sendJson(res, 200, {
      statusCode: 'S1000',
      statusDetail: 'Subscription activated successfully',
      subscriptionStatus: 'REGISTERED',
      subscriberId: 'tel:88' + pending.mobile,
      _mock: true,
    });
  },

  'POST /bdapps_api_php/unsubscribe.php': (req, res, body) => {
    const form = parseForm(body);
    const mobile = normalizeMobile(form.user_mobile || form.subscriberId);
    if (!mobile) return sendJson(res, 400, { error: 'Mobile number required' });
    subscriptions.set(mobile, { subscribed: false, unsubscribedAt: Date.now() });
    sendJson(res, 200, {
      success: true,
      subscriberId: 'tel:88' + mobile,
      statusCode: 'S1000',
      statusDetail: 'Unsubscribed successfully',
      subscriptionStatus: 'UNREGISTERED',
      _mock: true,
    });
  },

  'POST /bdapps_api_php/login.php': (req, res, body) => {
    const form = parseForm(body);
    const email = String(form.email || '').trim();
    const password = String(form.password || '');
    if (!email || !password) {
      return sendJson(res, 400, {
        statusCode: 'E0001',
        statusDetail: 'Email and password are required.',
        success: false,
      });
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return sendJson(res, 400, {
        statusCode: 'E0002',
        statusDetail: 'Please enter a valid email address.',
        success: false,
      });
    }
    if (password.length < 6) {
      return sendJson(res, 401, {
        statusCode: 'E0003',
        statusDetail: 'Incorrect email or password.',
        success: false,
      });
    }
    sendJson(res, 200, {
      statusCode: 'S1000',
      statusDetail: 'Signed in successfully.',
      success: true,
      user: { email, displayName: email.split('@')[0] },
    });
  },
};

function serveStatic(res, file, contentType) {
  const full = path.join(ROOT, file);
  fs.readFile(full, (err, data) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('Not found: ' + file);
      return;
    }
    send(res, 200, contentType, data);
  });
}

const STATIC_FILES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.apk': 'application/vnd.android.package-archive',
  '.ico': 'image/x-icon',
};

const server = http.createServer(async (req, res) => {
  const parsed = url.parse(req.url, true);
  const pathname = parsed.pathname;
  const key = req.method + ' ' + pathname;

  if (req.method === 'OPTIONS') {
    res.writeHead(200, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    });
    return res.end();
  }

  if (ROUTES[key]) {
    const body = await readBody(req);
    return ROUTES[key](req, res, body);
  }

  // Static file serving
  if (req.method === 'GET') {
    const safe = pathname.replace(/\.\./g, '').replace(/\/+$/, '') || '/';
    const full = path.join(ROOT, safe === '/' ? 'index.html' : safe);
    if (!full.startsWith(ROOT)) {
      res.writeHead(403);
      return res.end('Forbidden');
    }
    fs.stat(full, (err, stat) => {
      if (err || !stat.isFile()) {
        res.writeHead(404);
        return res.end('Not found');
      }
      const ext = path.extname(full).toLowerCase();
      const ct = STATIC_FILES[ext] || 'application/octet-stream';
      res.writeHead(200, { 'Content-Type': ct });
      fs.createReadStream(full).pipe(res);
    });
    return;
  }

  res.writeHead(405);
  res.end('Method not allowed');
});

server.listen(PORT, () => {
  console.log('');
  console.log('  QuizHub dev server');
  console.log('  --------------------');
  console.log(`  Listening on  http://localhost:${PORT}`);
  console.log('');
  console.log('  Open the URL above in your browser.');
  console.log('  Endpoints (mocked):');
  console.log('    POST /bdapps_api_php/check_subscription.php');
  console.log('    POST /bdapps_api_php/send_otp.php   (dev OTP: 1234)');
  console.log('    POST /bdapps_api_php/verify_otp.php');
  console.log('    POST /bdapps_api_php/unsubscribe.php');
  console.log('    POST /bdapps_api_php/login.php');
  console.log('');
});