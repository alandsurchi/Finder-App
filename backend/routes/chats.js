const express = require('express');
const db = require('../db');
const { verifyToken } = require('./auth');
const crypto = require('crypto');
const {
  isBlocked,
  blockedIdsFor,
  getSettings,
  notify,
  displayName,
  mapMessage,
  bool,
} = require('../lib/helpers');

const { validate, schemas } = require('../lib/validate');

const router = express.Router();

// GET /chats - Get user conversations (one query, grouped in JS)
router.get('/', verifyToken, async (req, res) => {
  const userId = req.userId;

  try {
    const rows = await db.query(
      `SELECT c.id, c.post_id, c.item_name, c.last_message_text, c.last_sender_id,
              c.updated_at_ms, me.unread_count AS my_unread,
              cp.user_id AS p_user_id, u.full_name, u.nick_name, u.avatar_url,
              p.owner_id AS post_owner_id, p.status AS post_status
       FROM chats c
       JOIN chat_participants me ON me.chat_id = c.id AND me.user_id = $1
       JOIN chat_participants cp ON cp.chat_id = c.id
       JOIN users u ON u.uid = cp.user_id
       LEFT JOIN posts p ON p.id = c.post_id
       ORDER BY c.updated_at_ms DESC`,
      [userId]
    );

    const blocked = await blockedIdsFor(userId);
    const byId = new Map();
    for (const r of rows) {
      let convo = byId.get(r.id);
      if (!convo) {
        convo = {
          id: r.id,
          postId: r.post_id || '',
          postOwnerId: r.post_owner_id || '',
          postStatus: r.post_status || '',
          itemName: r.item_name,
          participants: [],
          participantNames: {},
          participantAvatars: {},
          lastMessageText: r.last_message_text || '',
          lastSenderId: r.last_sender_id || '',
          updatedAtMs: parseInt(r.updated_at_ms),
          unreadCounts: { [userId]: parseInt(r.my_unread) || 0 },
        };
        byId.set(r.id, convo);
      }
      convo.participants.push(r.p_user_id);
      convo.participantNames[r.p_user_id] = displayName(r);
      convo.participantAvatars[r.p_user_id] = r.avatar_url || '';
    }

    const conversations = [...byId.values()].filter(
      c => !c.participants.some(p => p !== userId && blocked.has(p))
    );

    res.status(200).json(conversations);
  } catch (err) {
    console.error('Fetch chats error:', err);
    res.status(500).json({ message: 'Error loading conversations.' });
  }
});

// GET /chats/:id/messages - Get messages in a chat
router.get('/:id/messages', verifyToken, async (req, res) => {
  const chatId = req.params.id;
  const limit = Math.min(parseInt(req.query.limit) || 20, 200);
  const cursor = req.query.cursor ? parseInt(req.query.cursor) : null;

  try {
    const isParticipant = await db.queryOne(
      'SELECT * FROM chat_participants WHERE chat_id = $1 AND user_id = $2',
      [chatId, req.userId]
    );
    if (!isParticipant) {
      return res.status(403).json({ message: 'You are not a participant in this chat.' });
    }

    let sql = 'SELECT * FROM messages WHERE chat_id = $1';
    const params = [chatId];

    if (cursor !== null) {
      params.push(cursor);
      sql += ` AND created_at_ms < $${params.length}`;
    }

    params.push(limit);
    sql += ` ORDER BY created_at_ms DESC LIMIT $${params.length}`;

    const messages = await db.query(sql, params);
    const items = messages.map(mapMessage);

    // Reading the latest page clears the unread counter.
    if (cursor === null) {
      await db.exec(
        'UPDATE chat_participants SET unread_count = 0 WHERE chat_id = $1 AND user_id = $2',
        [chatId, req.userId]
      );
    }

    const hasMore = items.length === limit;
    const nextCursor = hasMore && items.length > 0 ? items[items.length - 1].createdAtMs.toString() : null;

    res.status(200).json({ items, nextCursor, hasMore });
  } catch (err) {
    console.error('Fetch messages error:', err);
    res.status(500).json({ message: 'Error loading messages.' });
  }
});

// POST /chats/initiate - Start or get a chat.
// With postId: one chat per (post, pair). Without: a direct chat per pair.
router.post('/initiate', verifyToken, validate(schemas.initiateChat), async (req, res) => {
  const { peerId, postId, itemName } = req.body;
  const currentUserId = req.userId;

  if (!peerId) {
    return res.status(400).json({ message: 'peerId is required.' });
  }
  if (peerId === currentUserId) {
    return res.status(400).json({ message: 'You cannot message yourself.' });
  }

  try {
    const peer = await db.queryOne('SELECT uid FROM users WHERE uid = $1', [peerId]);
    if (!peer) return res.status(404).json({ message: 'User not found.' });

    if (await isBlocked(currentUserId, peerId)) {
      return res.status(403).json({ message: 'You cannot message this user.' });
    }
    const peerSettings = await getSettings(peerId);
    if (!peerSettings.allow_messages) {
      return res.status(403).json({ message: 'This user does not accept direct messages.' });
    }

    const ids = [currentUserId, peerId].sort();
    const chatId = postId ? `${postId}_${ids[0]}_${ids[1]}` : `direct_${ids[0]}_${ids[1]}`;
    const resolvedItemName = itemName || 'Direct message';

    const existingChat = await db.queryOne('SELECT * FROM chats WHERE id = $1', [chatId]);
    if (existingChat) {
      return res.status(200).json({ chatId });
    }

    const now = Date.now();
    await db.exec(
      `INSERT INTO chats (id, post_id, item_name, last_message_text, last_sender_id, created_at_ms, updated_at_ms)
       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [chatId, postId || null, resolvedItemName, '', '', now, now]
    );
    await db.exec(
      'INSERT INTO chat_participants (chat_id, user_id, unread_count) VALUES ($1, $2, 0)',
      [chatId, currentUserId]
    );
    await db.exec(
      'INSERT INTO chat_participants (chat_id, user_id, unread_count) VALUES ($1, $2, 0)',
      [chatId, peerId]
    );

    res.status(201).json({ chatId });
  } catch (err) {
    console.error('Initiate chat error:', err);
    res.status(500).json({ message: 'Error initiating conversation.' });
  }
});

// POST /chats/:id/messages - Send a text and/or image message
router.post('/:id/messages', verifyToken, validate(schemas.sendMessage), async (req, res) => {
  const chatId = req.params.id;
  const senderId = req.userId;
  const text = typeof req.body.text === 'string' ? req.body.text.trim() : '';
  const imageUrl = typeof req.body.imageUrl === 'string' ? req.body.imageUrl.trim() : '';

  if (!text && !imageUrl) {
    return res.status(400).json({ message: 'Message cannot be empty.' });
  }

  try {
    const isParticipant = await db.queryOne(
      'SELECT * FROM chat_participants WHERE chat_id = $1 AND user_id = $2',
      [chatId, senderId]
    );
    if (!isParticipant) {
      return res.status(403).json({ message: 'You are not a participant.' });
    }

    const others = await db.query(
      'SELECT user_id FROM chat_participants WHERE chat_id = $1 AND user_id != $2',
      [chatId, senderId]
    );
    for (const o of others) {
      if (await isBlocked(senderId, o.user_id)) {
        return res.status(403).json({ message: 'You cannot message this user.' });
      }
    }

    const msgId = crypto.randomUUID();
    const now = Date.now();
    const preview = text || 'Sent a photo';

    await db.exec(
      `INSERT INTO messages (id, chat_id, sender_id, text, image_url, is_read, created_at_ms)
       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [msgId, chatId, senderId, text, imageUrl, bool(false), now]
    );

    await db.exec(
      `UPDATE chats SET last_message_text = $1, last_sender_id = $2, updated_at_ms = $3 WHERE id = $4`,
      [preview, senderId, now, chatId]
    );

    await db.exec(
      `UPDATE chat_participants SET unread_count = unread_count + 1 WHERE chat_id = $1 AND user_id != $2`,
      [chatId, senderId]
    );

    // Notify the other participants (respecting their notification setting).
    const sender = await db.queryOne('SELECT full_name, nick_name, avatar_url FROM users WHERE uid = $1', [senderId]);
    const chat = await db.queryOne('SELECT item_name, post_id FROM chats WHERE id = $1', [chatId]);
    for (const o of others) {
      const settings = await getSettings(o.user_id);
      if (!settings.notify_messages) continue;
      await notify(o.user_id, {
        title: `${displayName(sender)} · ${chat ? chat.item_name : 'Message'}`,
        message: preview.length > 120 ? `${preview.slice(0, 117)}...` : preview,
        type: 'message',
        // Everything the app needs to open this chat straight from the
        // notification, without another request.
        data: {
          type: 'message',
          chatId,
          postId: (chat && chat.post_id) || '',
          peerId: senderId,
          peerName: displayName(sender),
          peerAvatarUrl: (sender && sender.avatar_url) || '',
          itemName: (chat && chat.item_name) || '',
        },
      });
    }

    res.status(201).json({
      id: msgId,
      chatId,
      senderId,
      text,
      imageUrl,
      createdAtMs: now,
      isRead: false,
    });
  } catch (err) {
    console.error('Send message error:', err);
    res.status(500).json({ message: 'Error sending message.' });
  }
});

module.exports = router;
