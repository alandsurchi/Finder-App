// User-level data operations shared by account deletion and the admin console.
const path = require('path');
const fs = require('fs');
const db = require('../db');
const config = require('../config');

/**
 * Removes a user and everything they own: posts (and the chats about them),
 * chats they took part in, saved items, reports, notifications, blocks,
 * device tokens, verification requests and private files. SQLite does not
 * enforce foreign keys, so every table is cleaned by hand.
 */
async function deleteUserData(uid) {
  const chatRows = await db.query(
    `SELECT DISTINCT c.id FROM chats c
     LEFT JOIN chat_participants cp ON cp.chat_id = c.id
     LEFT JOIN posts p ON p.id = c.post_id
     WHERE cp.user_id = $1 OR p.owner_id = $2`,
    [uid, uid]
  );
  for (const row of chatRows) {
    await db.exec('DELETE FROM messages WHERE chat_id = $1', [row.id]);
    await db.exec('DELETE FROM chat_participants WHERE chat_id = $1', [row.id]);
    await db.exec('DELETE FROM chats WHERE id = $1', [row.id]);
  }
  await db.exec('DELETE FROM saved_items WHERE user_id = $1 OR post_id IN (SELECT id FROM posts WHERE owner_id = $2)', [uid, uid]);
  await db.exec('DELETE FROM reports WHERE reporter_id = $1 OR post_id IN (SELECT id FROM posts WHERE owner_id = $2)', [uid, uid]);
  await db.exec('DELETE FROM posts WHERE owner_id = $1', [uid]);
  await db.exec('DELETE FROM notifications WHERE user_id = $1', [uid]);
  await db.exec('DELETE FROM blocked_users WHERE user_id = $1 OR blocked_user_id = $2', [uid, uid]);
  await db.exec('DELETE FROM device_tokens WHERE user_id = $1', [uid]);
  await db.exec('DELETE FROM verification_requests WHERE user_id = $1', [uid]);
  try {
    const dir = path.join(config.privateDir, 'verification');
    for (const f of await fs.promises.readdir(dir).catch(() => [])) {
      if (f.startsWith(`${uid}_`)) await fs.promises.unlink(path.join(dir, f)).catch(() => {});
    }
  } catch (_) { /* best effort */ }
  await db.exec('DELETE FROM user_settings WHERE user_id = $1', [uid]);
  await db.exec('DELETE FROM users WHERE uid = $1', [uid]);
}

/** Deletes one post and everything hanging off it. */
async function deletePostData(id) {
  await db.exec('DELETE FROM saved_items WHERE post_id = $1', [id]);
  await db.exec('DELETE FROM reports WHERE post_id = $1', [id]);
  const chats = await db.query('SELECT id FROM chats WHERE post_id = $1', [id]);
  for (const c of chats) {
    await db.exec('DELETE FROM messages WHERE chat_id = $1', [c.id]);
    await db.exec('DELETE FROM chat_participants WHERE chat_id = $1', [c.id]);
    await db.exec('DELETE FROM chats WHERE id = $1', [c.id]);
  }
  await db.exec('DELETE FROM posts WHERE id = $1', [id]);
}

module.exports = { deleteUserData, deletePostData };
