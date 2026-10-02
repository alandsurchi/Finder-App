// Per-user limits on the actions people spam: posting, messaging, uploads.
// Keyed by the signed-in user (fall back to the IP before auth). Tunable
// through RATE_LIMIT_POSTS (per day), RATE_LIMIT_MESSAGES (per minute) and
// RATE_LIMIT_UPLOADS (per hour).
const rateLimit = require('express-rate-limit');

const MESSAGE = 'Too many requests. Please slow down.';

function perUser(max, windowMs, message = MESSAGE) {
  return rateLimit({
    windowMs,
    max,
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: (req) => req.userId || req.ip,
    message: { message },
  });
}

const n = (key, fallback) => parseInt(process.env[key], 10) || fallback;

module.exports = {
  posts: perUser(n('RATE_LIMIT_POSTS', 10), 24 * 60 * 60 * 1000, 'You have reached the daily limit of new posts. Try again tomorrow.'),
  messages: perUser(n('RATE_LIMIT_MESSAGES', 60), 60 * 1000, 'You are sending messages too quickly. Wait a moment.'),
  uploads: perUser(n('RATE_LIMIT_UPLOADS', 30), 60 * 60 * 1000, 'Too many uploads. Try again in a while.'),
};
