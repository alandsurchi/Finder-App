// Realtime layer for chat: new messages, delivered / read receipts, typing
// and presence. REST stays the source of truth; the socket only pushes
// what the routes already stored, so a client without a socket (or with a
// flaky one) keeps working by polling.
//
// Connect:  wss://<host>/ws?token=<jwt>   (or send {type:'auth', token} first)
// Server → client: authenticated, presence.snapshot, presence, message.new,
//   message.delivered, message.read, message.deleted, typing, error
// Client → server: typing {chatId, isTyping}, delivered {chatId}, read {chatId}, ping
const ws = require('ws');
const jwt = require('jsonwebtoken');
const db = require('./db');
const { jwtSecret: JWT_SECRET } = require('./config');
const { truthy } = require('./lib/helpers');
const chatState = require('./lib/chat_state');

const HEARTBEAT_MS = 30 * 1000;
const LAST_SEEN_WRITE_EVERY_MS = 60 * 1000;

/** userId → Set<WebSocket> of that user's live connections. */
const clients = new Map();

function send(socket, event) {
  if (socket.readyState !== ws.OPEN) return;
  try { socket.send(JSON.stringify(event)); } catch (_) { /* closing */ }
}

function sendToUser(userId, event) {
  const set = clients.get(userId);
  if (!set) return 0;
  for (const s of set) send(s, event);
  return set.size;
}

/** Sends to every participant of a chat (optionally skipping one user). */
async function sendToChat(chatId, event, { except } = {}) {
  const ids = await chatState.participantsOf(chatId).catch(() => []);
  for (const id of ids) {
    if (except && id === except) continue;
    sendToUser(id, event);
  }
}

function isOnline(userId) {
  const set = clients.get(userId);
  return !!set && set.size > 0;
}

/** { userId: { online, lastSeenMs } } for a list of users. */
async function presenceOf(userIds) {
  const out = {};
  const ids = [...new Set(userIds.filter(Boolean))];
  if (!ids.length) return out;
  const placeholders = ids.map((_, i) => `$${i + 1}`).join(', ');
  const rows = await db.query(`SELECT uid, last_seen_ms FROM users WHERE uid IN (${placeholders})`, ids).catch(() => []);
  const seen = new Map(rows.map(r => [r.uid, r.last_seen_ms ? parseInt(r.last_seen_ms) : null]));
  for (const id of ids) {
    out[id] = { online: isOnline(id), lastSeenMs: seen.get(id) ?? null };
  }
  return out;
}

async function touchLastSeen(userId) {
  await db.exec('UPDATE users SET last_seen_ms = $1 WHERE uid = $2', [Date.now(), userId]).catch(() => {});
}

/** Everyone who shares a chat with the user. */
async function peersOf(userId) {
  const rows = await db.query(
    `SELECT DISTINCT cp.user_id FROM chat_participants cp
     JOIN chat_participants me ON me.chat_id = cp.chat_id AND me.user_id = $1
     WHERE cp.user_id != $2`,
    [userId, userId]
  ).catch(() => []);
  return rows.map(r => r.user_id);
}

async function broadcastPresence(userId, online) {
  const lastSeenMs = online ? null : Date.now();
  const event = { type: 'presence', userId, online, lastSeenMs };
  for (const peer of await peersOf(userId)) sendToUser(peer, event);
}

async function authenticate(token) {
  if (!token) return null;
  let decoded;
  try { decoded = jwt.verify(token, JWT_SECRET); } catch (_) { return null; }
  const user = await db.queryOne('SELECT uid, is_banned FROM users WHERE uid = $1', [decoded.userId]).catch(() => null);
  if (!user || truthy(user.is_banned)) return null;
  return user.uid;
}

function initWebSocket(server) {
  const wss = new ws.Server({ noServer: true });

  server.on('upgrade', (request, socket, head) => {
    const url = new URL(request.url, 'http://localhost');
    if (url.pathname !== '/ws' && url.pathname !== '/') {
      socket.destroy();
      return;
    }
    wss.handleUpgrade(request, socket, head, (conn) => {
      conn.queryToken = url.searchParams.get('token') || '';
      wss.emit('connection', conn, request);
    });
  });

  // Dead-connection reaper: ping every 30 s, drop sockets that never pong.
  const reaper = setInterval(() => {
    for (const conn of wss.clients) {
      if (conn.isAlive === false) { conn.terminate(); continue; }
      conn.isAlive = false;
      try { conn.ping(); } catch (_) { /* closing */ }
    }
  }, HEARTBEAT_MS);
  reaper.unref();
  wss.on('close', () => clearInterval(reaper));

  wss.on('connection', (conn) => {
    conn.isAlive = true;
    let userId = null;
    let lastSeenWrittenAt = 0;
    const participantCache = new Map();

    const register = async (uid) => {
      userId = uid;
      const first = !clients.has(uid);
      if (first) clients.set(uid, new Set());
      clients.get(uid).add(conn);
      await touchLastSeen(uid);
      lastSeenWrittenAt = Date.now();
      send(conn, { type: 'authenticated', userId: uid });
      const peers = await peersOf(uid);
      const snapshot = await presenceOf(peers);
      send(conn, { type: 'presence.snapshot', users: Object.entries(snapshot).map(([id, p]) => ({ userId: id, ...p })) });
      if (first) await broadcastPresence(uid, true);
    };

    const canAct = async (chatId) => {
      if (!userId || !chatId) return false;
      if (participantCache.has(chatId)) return participantCache.get(chatId);
      const ok = await chatState.isParticipant(chatId, userId);
      participantCache.set(chatId, ok);
      return ok;
    };

    conn.on('pong', async () => {
      conn.isAlive = true;
      if (userId && Date.now() - lastSeenWrittenAt > LAST_SEEN_WRITE_EVERY_MS) {
        lastSeenWrittenAt = Date.now();
        await touchLastSeen(userId);
      }
    });

    // Token in the URL: authenticate straight away.
    if (conn.queryToken) {
      authenticate(conn.queryToken).then(uid => {
        if (!uid) { send(conn, { type: 'error', message: 'Invalid token.' }); return conn.close(4401, 'unauthorized'); }
        return register(uid);
      }).catch(err => console.error('WS auth error:', err.message));
    }

    conn.on('message', async (raw) => {
      let payload;
      try { payload = JSON.parse(raw.toString()); } catch (_) {
        return send(conn, { type: 'error', message: 'Invalid message payload format.' });
      }
      try {
        switch (payload.type) {
          case 'auth': {
            if (userId) return;
            const uid = await authenticate(payload.token);
            if (!uid) { send(conn, { type: 'error', message: 'Invalid token.' }); return conn.close(4401, 'unauthorized'); }
            return register(uid);
          }
          case 'ping':
            return send(conn, { type: 'pong', at: Date.now() });
          case 'typing': {
            const { chatId, isTyping } = payload;
            if (!(await canAct(chatId))) return;
            return sendToChat(chatId, { type: 'typing', chatId, userId, isTyping: !!isTyping }, { except: userId });
          }
          case 'delivered': {
            const { chatId } = payload;
            if (!(await canAct(chatId))) return;
            const at = await chatState.markChatDelivered(userId, chatId);
            if (at) await sendToChat(chatId, { type: 'message.delivered', chatId, userId, deliveredAtMs: at }, { except: userId });
            return;
          }
          case 'read': {
            const { chatId } = payload;
            if (!(await canAct(chatId))) return;
            const at = await chatState.markChatRead(userId, chatId);
            return sendToChat(chatId, { type: 'message.read', chatId, userId, readAtMs: at }, { except: userId });
          }
          default:
            if (!userId) return send(conn, { type: 'error', message: 'Not authenticated.' });
        }
      } catch (err) {
        console.error('WS handler error:', err.message);
      }
    });

    conn.on('close', async () => {
      if (!userId) return;
      const set = clients.get(userId);
      if (set) {
        set.delete(conn);
        if (set.size === 0) {
          clients.delete(userId);
          await touchLastSeen(userId);
          await broadcastPresence(userId, false);
        }
      }
    });

    conn.on('error', () => {});
  });
}

module.exports = { initWebSocket, sendToUser, sendToChat, isOnline, presenceOf };
