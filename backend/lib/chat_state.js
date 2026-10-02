// Read / delivered state of a chat, WhatsApp style. Every participant keeps
// two watermarks: everything the peer sent up to `last_delivered_at_ms` has
// reached their phone, everything up to `last_read_at_ms` was seen. Chats
// are two-party, so a watermark per participant is exact and needs one
// UPDATE instead of one row per message.
const db = require('../db');
const { bool } = require('./helpers');

async function isParticipant(chatId, userId) {
  const row = await db.queryOne(
    'SELECT 1 AS hit FROM chat_participants WHERE chat_id = $1 AND user_id = $2',
    [chatId, userId]
  );
  return !!row;
}

async function participantsOf(chatId) {
  const rows = await db.query('SELECT user_id FROM chat_participants WHERE chat_id = $1', [chatId]);
  return rows.map(r => r.user_id);
}

/** Marks the "new message" notifications of one chat as read for a user. */
async function markChatNotificationsRead(userId, chatId) {
  await db.exec(
    `UPDATE notifications SET is_unread = $1 WHERE user_id = $2 AND type = 'message' AND data LIKE $3`,
    [bool(false), userId, `%"chatId":"${chatId}"%`]
  );
}

/**
 * The user's phone received the chat's messages (list fetched or socket
 * ack). Returns the new watermark, or null when nothing changed.
 */
async function markChatDelivered(userId, chatId) {
  const now = Date.now();
  const r = await db.exec(
    `UPDATE chat_participants SET last_delivered_at_ms = $1
     WHERE chat_id = $2 AND user_id = $3 AND (last_delivered_at_ms IS NULL OR last_delivered_at_ms < $4)`,
    [now, chatId, userId, now]
  );
  return r.affectedRows ? now : null;
}

/** The user opened the chat: everything so far is read and delivered. */
async function markChatRead(userId, chatId) {
  const now = Date.now();
  await db.exec(
    `UPDATE chat_participants
     SET unread_count = 0, last_read_at_ms = $1,
         last_delivered_at_ms = CASE WHEN last_delivered_at_ms IS NULL OR last_delivered_at_ms < $2 THEN $3 ELSE last_delivered_at_ms END
     WHERE chat_id = $4 AND user_id = $5`,
    [now, now, now, chatId, userId]
  );
  await markChatNotificationsRead(userId, chatId);
  return now;
}

/**
 * Watermarks a viewer needs to stamp ticks on their own messages: the
 * peer's read/delivered times, plus the viewer's own read time (for the
 * "unread messages" divider).
 */
async function watermarksFor(chatId, userId) {
  const rows = await db.query(
    'SELECT user_id, last_read_at_ms, last_delivered_at_ms FROM chat_participants WHERE chat_id = $1',
    [chatId]
  );
  let peerReadAtMs = null;
  let peerDeliveredAtMs = null;
  let myReadAtMs = null;
  for (const r of rows) {
    if (r.user_id === userId) {
      myReadAtMs = r.last_read_at_ms ? parseInt(r.last_read_at_ms) : null;
    } else {
      // With more than one peer the earliest watermark decides.
      const read = r.last_read_at_ms ? parseInt(r.last_read_at_ms) : null;
      const delivered = r.last_delivered_at_ms ? parseInt(r.last_delivered_at_ms) : null;
      peerReadAtMs = peerReadAtMs === null ? read : (read === null ? null : Math.min(peerReadAtMs, read));
      peerDeliveredAtMs = peerDeliveredAtMs === null ? delivered : (delivered === null ? null : Math.min(peerDeliveredAtMs, delivered));
    }
  }
  return { peerReadAtMs, peerDeliveredAtMs, myReadAtMs };
}

module.exports = {
  isParticipant,
  participantsOf,
  markChatNotificationsRead,
  markChatDelivered,
  markChatRead,
  watermarksFor,
};
