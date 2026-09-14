// Push notifications through Firebase Cloud Messaging.
//
// FCM is the only way to wake a closed Android app, so it is the one piece
// that does not live on Railway. Everything else (the notification rows the
// app lists, device tokens, settings) stays in our own database.
//
// Configuration: FIREBASE_SERVICE_ACCOUNT = base64 of the service-account
// JSON (see docs/DEPLOYMENT.md). Without it push is disabled and every call
// here is a no-op that logs once.
const config = require('../config');
const db = require('../db');

let messaging = null;
let warned = false;

function init() {
  if (messaging) return messaging;
  const account = config.firebaseServiceAccount;
  if (!account) {
    if (!warned) {
      warned = true;
      console.warn('PUSH: FIREBASE_SERVICE_ACCOUNT not set; phone notifications are disabled.');
    }
    return null;
  }
  try {
    const { initializeApp, cert, getApps } = require('firebase-admin/app');
    const { getMessaging } = require('firebase-admin/messaging');
    const app = getApps().length ? getApps()[0] : initializeApp({ credential: cert(account) });
    messaging = getMessaging(app);
    console.log(`PUSH: Firebase Cloud Messaging ready (project ${account.project_id}).`);
  } catch (err) {
    console.error('PUSH: could not initialise firebase-admin:', err.message);
  }
  return messaging;
}

function stringValues(obj) {
  const out = {};
  for (const [k, v] of Object.entries(obj || {})) {
    if (v === undefined || v === null) continue;
    out[k] = typeof v === 'string' ? v : JSON.stringify(v);
  }
  return out;
}

/**
 * Sends a notification to every device registered for [userId].
 * Never throws: failures are logged and dead tokens are removed.
 */
async function sendPush(userId, { title, body, data = {}, collapseKey } = {}) {
  const fcm = init();
  if (!fcm || !userId) return { sent: 0 };

  let tokens;
  try {
    const rows = await db.query('SELECT token FROM device_tokens WHERE user_id = $1', [userId]);
    tokens = rows.map(r => r.token).filter(Boolean);
  } catch (err) {
    console.error('PUSH: token lookup failed:', err.message);
    return { sent: 0 };
  }
  if (tokens.length === 0) return { sent: 0 };

  const type = data.type || 'system';
  const channelId = type === 'message' ? 'finder_messages' : 'finder_updates';
  const tag = collapseKey ? String(collapseKey).slice(0, 60) : undefined;

  const message = {
    tokens,
    notification: { title, body },
    data: stringValues({ ...data, title, body }),
    android: {
      priority: 'high',
      ...(tag ? { collapseKey: tag } : {}),
      notification: { channelId, ...(tag ? { tag } : {}), sound: 'default' },
    },
    apns: {
      payload: { aps: { sound: 'default', ...(tag ? { 'thread-id': tag } : {}) } },
    },
  };

  try {
    const res = await fcm.sendEachForMulticast(message);
    const dead = [];
    res.responses.forEach((r, i) => {
      if (r.success) return;
      const code = r.error && r.error.code;
      if (code === 'messaging/registration-token-not-registered' ||
          code === 'messaging/invalid-registration-token' ||
          code === 'messaging/invalid-argument') {
        dead.push(tokens[i]);
      } else {
        console.error(`PUSH: send failed for one device: ${code || r.error}`);
      }
    });
    for (const token of dead) {
      await db.exec('DELETE FROM device_tokens WHERE token = $1', [token]).catch(() => {});
    }
    return { sent: res.successCount, failed: res.failureCount };
  } catch (err) {
    console.error('PUSH: multicast failed:', err.message);
    return { sent: 0 };
  }
}

/** True when push can actually be delivered (used by /health). */
function pushConfigured() {
  return !!config.firebaseServiceAccount;
}

module.exports = { sendPush, pushConfigured, init };
