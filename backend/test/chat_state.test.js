// node --test: receipt watermarks and tick derivation on a throw-away SQLite file.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');

const tmp = path.join(os.tmpdir(), `finder-test-${process.pid}.sqlite`);
process.env.SQLITE_PATH = tmp;
process.env.NODE_ENV = 'test';
delete process.env.DATABASE_URL;

const db = require('../db');
const chatState = require('../lib/chat_state');
const { mapMessage, bool } = require('../lib/helpers');

test.before(async () => {
  await db.initDb();
  const now = Date.now();
  for (const uid of ['a', 'b']) {
    await db.exec(`INSERT INTO users (uid, email, password_hash, full_name, created_at, updated_at) VALUES ($1, $2, 'x', $3, $4, $5)`, [uid, `${uid}@t.io`, uid.toUpperCase(), now, now]).catch(() => {});
  }
  await db.exec(`INSERT INTO chats (id, post_id, item_name, last_message_text, last_sender_id, created_at_ms, updated_at_ms) VALUES ('c1', NULL, 'Thing', '', '', $1, $2)`, [now, now]);
  for (const uid of ['a', 'b']) {
    await db.exec(`INSERT INTO chat_participants (chat_id, user_id, unread_count) VALUES ('c1', $1, 0)`, [uid]);
  }
  await db.exec(`INSERT INTO messages (id, chat_id, sender_id, text, is_read, created_at_ms) VALUES ('m1', 'c1', 'a', 'hi', $1, $2)`, [bool(false), now - 1000]);
});

test.after(async () => {
  try { fs.unlinkSync(tmp); } catch (_) {}
});

test('participants and membership', async () => {
  assert.deepEqual((await chatState.participantsOf('c1')).sort(), ['a', 'b']);
  assert.equal(await chatState.isParticipant('c1', 'a'), true);
  assert.equal(await chatState.isParticipant('c1', 'zz'), false);
});

test('delivered then read watermarks drive the ticks', async () => {
  const row = await db.queryOne('SELECT * FROM messages WHERE id = $1', ['m1']);
  let wm = await chatState.watermarksFor('c1', 'a');
  assert.equal(mapMessage(row, wm).isDelivered, false);

  const d = await chatState.markChatDelivered('b', 'c1');
  assert.ok(d > 0);
  wm = await chatState.watermarksFor('c1', 'a');
  let m = mapMessage(row, wm);
  assert.equal(m.isDelivered, true);
  assert.equal(m.isRead, false);

  const r = await chatState.markChatRead('b', 'c1');
  assert.ok(r >= d);
  wm = await chatState.watermarksFor('c1', 'a');
  m = mapMessage(row, wm);
  assert.equal(m.isRead, true);
  assert.equal(m.isDelivered, true);
  const me = await chatState.watermarksFor('c1', 'b');
  assert.equal(me.myReadAtMs, r);
});

test('mapMessage parses waveform and forwarded, tombstones blank media', () => {
  const m = mapMessage({ id: 'x', chat_id: 'c1', sender_id: 'a', text: 't', created_at_ms: 1, waveform: '[1,200,-5]', forwarded: 1, audio_url: 'u' }, {});
  assert.deepEqual(m.waveform, [1, 100, 0]);
  assert.equal(m.forwarded, true);
  const gone = mapMessage({ id: 'y', chat_id: 'c1', sender_id: 'a', text: 't', created_at_ms: 1, deleted_at_ms: 2, waveform: '[5]', audio_url: 'u' }, {});
  assert.equal(gone.deleted, true);
  assert.equal(gone.waveform, null);
  assert.equal(gone.audioUrl, '');
});
