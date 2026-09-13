// Shared helpers used across routers.
const crypto = require('crypto');
const db = require('../db');

/** True when outgoing e-mail is configured. Without SMTP the app runs in
 *  "demo mode": signups are auto-verified and codes are printed to stdout. */
function smtpConfigured() {
  return !!(process.env.SMTP_HOST && process.env.SMTP_USER && process.env.SMTP_PASS);
}

function truthy(v) {
  return v === 1 || v === true || v === 'true' || v === '1';
}

function displayName(row) {
  if (!row) return 'Finder User';
  return row.full_name || row.nick_name || 'Finder User';
}

/** Blocked in either direction. */
async function isBlocked(a, b) {
  if (!a || !b) return false;
  const row = await db.queryOne(
    `SELECT 1 AS hit FROM blocked_users
     WHERE (user_id = $1 AND blocked_user_id = $2)
        OR (user_id = $3 AND blocked_user_id = $4)`,
    [a, b, b, a]
  );
  return !!row;
}

/** Set of user ids that `userId` has blocked or that have blocked `userId`. */
async function blockedIdsFor(userId) {
  const rows = await db.query(
    `SELECT blocked_user_id AS id FROM blocked_users WHERE user_id = $1
     UNION
     SELECT user_id AS id FROM blocked_users WHERE blocked_user_id = $2`,
    [userId, userId]
  );
  return new Set(rows.map(r => r.id));
}

const SETTINGS_DEFAULTS = {
  show_profile: true,
  allow_messages: true,
  show_location: false,
  hide_phone: true,
  notify_messages: true,
  notify_matches: true,
  notify_updates: true,
  notify_marketing: false,
  notify_email: true,
};

/** Effective settings for a user (defaults merged over the stored row). */
async function getSettings(userId) {
  const row = await db.queryOne('SELECT * FROM user_settings WHERE user_id = $1', [userId]);
  const out = { ...SETTINGS_DEFAULTS };
  if (row) {
    for (const key of Object.keys(SETTINGS_DEFAULTS)) {
      if (row[key] !== undefined && row[key] !== null) out[key] = truthy(row[key]);
    }
  }
  return out;
}

function bool(v) {
  return db.isPostgres ? !!v : (v ? 1 : 0);
}

/** Upsert a subset of settings columns. */
async function saveSettings(userId, patch) {
  const current = await getSettings(userId);
  const next = { ...current };
  for (const key of Object.keys(SETTINGS_DEFAULTS)) {
    if (patch[key] !== undefined) next[key] = !!patch[key];
  }
  const exists = await db.queryOne('SELECT user_id FROM user_settings WHERE user_id = $1', [userId]);
  const cols = Object.keys(SETTINGS_DEFAULTS);
  if (exists) {
    const sets = cols.map((c, i) => `${c} = $${i + 1}`).join(', ');
    await db.exec(
      `UPDATE user_settings SET ${sets} WHERE user_id = $${cols.length + 1}`,
      [...cols.map(c => bool(next[c])), userId]
    );
  } else {
    const placeholders = cols.map((_, i) => `$${i + 2}`).join(', ');
    await db.exec(
      `INSERT INTO user_settings (user_id, ${cols.join(', ')}) VALUES ($1, ${placeholders})`,
      [userId, ...cols.map(c => bool(next[c]))]
    );
  }
  return next;
}

/** Insert a notification row. `type` is one of message | match | update | system. */
async function notify(userId, { title, message, type = 'system' }) {
  if (!userId) return null;
  const id = crypto.randomUUID();
  const now = Date.now();
  await db.exec(
    `INSERT INTO notifications (id, user_id, title, message, type, is_unread, created_at_ms)
     VALUES ($1, $2, $3, $4, $5, $6, $7)`,
    [id, userId, title, message, type, bool(true), now]
  );
  return { id, title, message, type, isUnread: true, createdAtMs: now };
}

/** SELECT fragment + mapper so every post response has the same shape. */
const POST_SELECT = `
  SELECT p.*,
         u.full_name AS owner_full_name,
         u.nick_name AS owner_nick_name,
         u.avatar_url AS owner_avatar_url,
         u.identity_verified AS owner_identity_verified
  FROM posts p
  LEFT JOIN users u ON u.uid = p.owner_id`;

function mapPost(row) {
  return {
    id: row.id,
    title: row.title,
    description: row.description,
    category: row.category,
    isLost: truthy(row.is_lost),
    reward: row.reward,
    ownerId: row.owner_id,
    ownerName: row.owner_full_name || row.owner_nick_name || 'Finder User',
    ownerAvatarUrl: row.owner_avatar_url || '',
    ownerVerified: truthy(row.owner_identity_verified),
    location: row.location,
    imageUrl: row.image_url || '',
    lostOn: row.lost_on || null,
    createdAtMs: parseInt(row.created_at_ms),
    updatedAtMs: parseInt(row.updated_at_ms),
    status: row.status || 'active',
  };
}

function mapMessage(row) {
  return {
    id: row.id,
    chatId: row.chat_id,
    senderId: row.sender_id,
    text: row.text || '',
    imageUrl: row.image_url || '',
    createdAtMs: parseInt(row.created_at_ms),
    isRead: truthy(row.is_read),
  };
}

module.exports = {
  smtpConfigured,
  truthy,
  bool,
  displayName,
  isBlocked,
  blockedIdsFor,
  getSettings,
  saveSettings,
  SETTINGS_DEFAULTS,
  notify,
  POST_SELECT,
  mapPost,
  mapMessage,
};
