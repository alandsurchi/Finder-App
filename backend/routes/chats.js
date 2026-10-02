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
  MESSAGE_SELECT,
  pick,
  bool, truthy } = require('../lib/helpers');
const chatState = require('../lib/chat_state');
const realtime = require('../websocket');

const { validate, schemas } = require('../lib/validate');

const router = express.Router();

// GET /chats - Get user conversations (one query, grouped in JS)
router.get('/', verifyToken, async (req, res) => {
  const userId = req.userId;

  try {
    const rows = await db.query(
      `SELECT c.id, c.post_id, c.item_name, c.last_message_text, c.last_sender_id, c.last_message_id,
              c.updated_at_ms, me.unread_count AS my_unread,
              cp.user_id AS p_user_id, cp.last_read_at_ms AS p_read_at, cp.last_delivered_at_ms AS p_delivered_at,
              u.full_name, u.nick_name, u.avatar_url,
              u.identity_verified AS p_verified, u.is_admin AS p_admin,
              p.owner_id AS post_owner_id, p.status AS post_status,
              p.title AS post_title, p.title_en AS post_title_en, p.title_ar AS post_title_ar, p.title_ckb AS post_title_ckb
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
        // The item name follows the viewer language when the post is translated.
        const translated = r.post_title
          ? pick({ title: r.post_title, title_en: r.post_title_en, title_ar: r.post_title_ar, title_ckb: r.post_title_ckb }, 'title', req.lang)
          : null;
        convo = {
          id: r.id,
          postId: r.post_id || '',
          postOwnerId: r.post_owner_id || '',
          postStatus: r.post_status || '',
          itemName: translated || r.item_name,
          participants: [],
          participantNames: {},
          participantAvatars: {},
          participantVerified: {},
          participantAdmin: {},
          lastMessageText: r.last_message_text || '',
          lastSenderId: r.last_sender_id || '',
          lastMessageId: r.last_message_id || '',
          updatedAtMs: parseInt(r.updated_at_ms),
          unreadCounts: { [userId]: parseInt(r.my_unread) || 0 },
          peerReadAtMs: null,
          peerDeliveredAtMs: null,
        };
        byId.set(r.id, convo);
      }
      convo.participants.push(r.p_user_id);
      convo.participantNames[r.p_user_id] = displayName(r);
      convo.participantAvatars[r.p_user_id] = r.avatar_url || '';
      convo.participantVerified[r.p_user_id] = truthy(r.p_verified);
      convo.participantAdmin[r.p_user_id] = truthy(r.p_admin);
      if (r.p_user_id !== userId) {
        convo.peerReadAtMs = r.p_read_at ? parseInt(r.p_read_at) : null;
        convo.peerDeliveredAtMs = r.p_delivered_at ? parseInt(r.p_delivered_at) : null;
      }
    }

    const conversations = [...byId.values()].filter(
      c => !c.participants.some(p => p !== userId && blocked.has(p))
    );

    // Online / last seen of every peer, in one lookup.
    const peerIds = conversations.flatMap(c => c.participants.filter(p => p !== userId));
    const presence = await realtime.presenceOf(peerIds);
    for (const c of conversations) {
      const peer = c.participants.find(p => p !== userId);
      c.peerPresence = (peer && presence[peer]) || { online: false, lastSeenMs: null };
      // Whether my last message was seen / delivered, for the list's ticks.
      const lastAt = c.lastSenderId === userId ? c.updatedAtMs : null;
      c.lastMessageRead = lastAt != null && c.peerReadAtMs != null && lastAt <= c.peerReadAtMs;
      c.lastMessageDelivered = c.lastMessageRead || (lastAt != null && c.peerDeliveredAtMs != null && lastAt <= c.peerDeliveredAtMs);
    }

    res.status(200).json(conversations);

    // Listing the chats means the phone received them: delivered ticks.
    for (const c of conversations) {
      if (c.lastSenderId && c.lastSenderId !== userId) {
        chatState.markChatDelivered(userId, c.id).then(at => {
          if (at) return realtime.sendToChat(c.id, { type: 'message.delivered', chatId: c.id, userId, deliveredAtMs: at }, { except: userId });
        }).catch(() => {});
      }
    }
  } catch (err) {
    console.error('Fetch chats error:', err);
    res.status(500).json({ message: 'Error loading conversations.' });
  }
});

// GET /chats/:id/messages?limit&cursor - newest first; the first page marks the chat read
router.get('/:id/messages', verifyToken, async (req, res) => {
  const chatId = req.params.id;
  const limit = Math.min(parseInt(req.query.limit) || 20, 200);
  const cursor = req.query.cursor ? parseInt(req.query.cursor) : null;

  try {
    if (!(await chatState.isParticipant(chatId, req.userId))) {
      return res.status(403).json({ message: 'You are not a participant in this chat.' });
    }

    // The viewer's own read time before this fetch: the app draws the
    // "unread messages" divider above the first message after it.
    const before = await chatState.watermarksFor(chatId, req.userId);

    let sql = `${MESSAGE_SELECT} WHERE m.chat_id = $1
      AND m.id NOT IN (SELECT message_id FROM message_hidden WHERE user_id = $2)`;
    const params = [chatId, req.userId];

    if (cursor !== null) {
      params.push(cursor);
      sql += ` AND m.created_at_ms < $${params.length}`;
    }

    params.push(limit);
    sql += ` ORDER BY m.created_at_ms DESC LIMIT $${params.length}`;

    const messages = await db.query(sql, params);

    if (cursor === null) {
      const at = await chatState.markChatRead(req.userId, chatId);
      realtime.sendToChat(chatId, { type: 'message.read', chatId, userId: req.userId, readAtMs: at }, { except: req.userId }).catch(() => {});
    }

    const wm = await chatState.watermarksFor(chatId, req.userId);
    const items = messages.map(m => mapMessage(m, wm));
    const hasMore = items.length === limit;
    const nextCursor = hasMore && items.length > 0 ? items[items.length - 1].createdAtMs.toString() : null;

    res.status(200).json({
      items,
      nextCursor,
      hasMore,
      peerReadAtMs: wm.peerReadAtMs,
      peerDeliveredAtMs: wm.peerDeliveredAtMs,
      myReadAtMsBefore: before.myReadAtMs,
    });
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
    // Keep the owner's original title as the snapshot; GET /chats translates it.
    let resolvedItemName = itemName || 'Direct message';
    if (postId) {
      const post = await db.queryOne('SELECT title FROM posts WHERE id = $1', [postId]);
      if (post && post.title) resolvedItemName = post.title;
    }

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

// PUT /chats/:id/read - the chat is on screen: settle its unread state
router.put('/:id/read', verifyToken, async (req, res) => {
  const chatId = req.params.id;
  try {
    if (!(await chatState.isParticipant(chatId, req.userId))) {
      return res.status(403).json({ message: 'You are not a participant in this chat.' });
    }
    const at = await chatState.markChatRead(req.userId, chatId);
    realtime.sendToChat(chatId, { type: 'message.read', chatId, userId: req.userId, readAtMs: at }, { except: req.userId }).catch(() => {});
    res.status(200).json({ message: 'Chat marked as read.', readAtMs: at });
  } catch (err) {
    console.error('Mark chat read error:', err);
    res.status(500).json({ message: 'Error updating chat.' });
  }
});

// DELETE /chats/:id/messages/:mid?scope=everyone|me
//   everyone (default): the sender removes it for everyone (tombstone)
//   me: hides it on this account only
router.delete('/:id/messages/:mid', verifyToken, async (req, res) => {
  const { id: chatId, mid } = req.params;
  const scope = req.query.scope === 'me' ? 'me' : 'everyone';
  try {
    const msg = await db.queryOne('SELECT * FROM messages WHERE id = $1 AND chat_id = $2', [mid, chatId]);
    if (!msg) return res.status(404).json({ message: 'Message not found.' });
    if (!(await chatState.isParticipant(chatId, req.userId))) {
      return res.status(403).json({ message: 'You are not a participant in this chat.' });
    }

    if (scope === 'me') {
      await db.exec(
        `INSERT INTO message_hidden (message_id, user_id) VALUES ($1, $2)${db.isPostgres ? ' ON CONFLICT DO NOTHING' : ''}`,
        [mid, req.userId]
      ).catch(() => {});
      return res.status(200).json({ hidden: true, id: mid });
    }

    if (msg.sender_id !== req.userId) return res.status(403).json({ message: 'You can only delete your own messages.' });
    if (!msg.deleted_at_ms) {
      const now = Date.now();
      await db.exec(
        `UPDATE messages SET deleted_at_ms = $1, text = '', image_url = NULL, audio_url = NULL, audio_ms = NULL, waveform = NULL WHERE id = $2`,
        [now, mid]
      );
      const last = await db.queryOne('SELECT id FROM messages WHERE chat_id = $1 ORDER BY created_at_ms DESC LIMIT 1', [chatId]);
      if (last && last.id === mid) {
        await db.exec('UPDATE chats SET last_message_text = $1 WHERE id = $2', ['This message was deleted', chatId]);
      }
      realtime.sendToChat(chatId, { type: 'message.deleted', chatId, messageId: mid }).catch(() => {});
    }
    const row = await db.queryOne(`${MESSAGE_SELECT} WHERE m.id = $1`, [mid]);
    const wm = await chatState.watermarksFor(chatId, req.userId);
    res.status(200).json(mapMessage(row, wm));
  } catch (err) {
    console.error('Delete message error:', err);
    res.status(500).json({ message: 'Error deleting message.' });
  }
});

// POST /chats/:id/messages - Send a text, image or voice message (or forward one)
router.post('/:id/messages', verifyToken, validate(schemas.sendMessage), async (req, res) => {
  const chatId = req.params.id;
  const senderId = req.userId;
  let text = typeof req.body.text === 'string' ? req.body.text.trim() : '';
  let imageUrl = typeof req.body.imageUrl === 'string' ? req.body.imageUrl.trim() : '';
  let audioUrl = typeof req.body.audioUrl === 'string' ? req.body.audioUrl.trim() : '';
  let audioMs = audioUrl && Number.isFinite(req.body.audioMs) ? Math.round(req.body.audioMs) : null;
  let waveform = audioUrl && Array.isArray(req.body.waveform) && req.body.waveform.length ? req.body.waveform : null;
  const replyToId = typeof req.body.replyToId === 'string' && req.body.replyToId ? req.body.replyToId : null;
  const forwardOf = typeof req.body.forwardOf === 'string' && req.body.forwardOf ? req.body.forwardOf : null;

  try {
    if (!(await chatState.isParticipant(chatId, senderId))) {
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

    if (forwardOf) {
      // The source must be in a chat the sender takes part in.
      const src = await db.queryOne(
        `SELECT m.* FROM messages m JOIN chat_participants cp ON cp.chat_id = m.chat_id AND cp.user_id = $1 WHERE m.id = $2`,
        [senderId, forwardOf]
      );
      if (!src || src.deleted_at_ms) return res.status(404).json({ message: 'Message not found.' });
      text = src.text || '';
      imageUrl = src.image_url || '';
      audioUrl = src.audio_url || '';
      audioMs = src.audio_ms === null || src.audio_ms === undefined ? null : parseInt(src.audio_ms);
      waveform = src.waveform ? JSON.parse(src.waveform) : null;
    }

    if (!text && !imageUrl && !audioUrl) {
      return res.status(400).json({ message: 'Message cannot be empty.' });
    }

    if (replyToId) {
      const quoted = await db.queryOne('SELECT id FROM messages WHERE id = $1 AND chat_id = $2', [replyToId, chatId]);
      if (!quoted) return res.status(400).json({ message: 'The message you are replying to is not in this chat.' });
    }

    const msgId = crypto.randomUUID();
    const now = Date.now();
    const preview = text || (audioUrl ? '\u{1F3A4} Voice message' : 'Sent a photo');

    await db.exec(
      `INSERT INTO messages (id, chat_id, sender_id, text, image_url, audio_url, audio_ms, reply_to_id, is_read, created_at_ms, waveform, forwarded, forward_of)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`,
      [msgId, chatId, senderId, text, imageUrl, audioUrl || null, audioMs, replyToId, bool(false), now,
        waveform ? JSON.stringify(waveform) : null, bool(!!forwardOf), forwardOf]
    );

    await db.exec(
      `UPDATE chats SET last_message_text = $1, last_sender_id = $2, last_message_id = $3, updated_at_ms = $4 WHERE id = $5`,
      [preview, senderId, msgId, now, chatId]
    );

    await db.exec(
      `UPDATE chat_participants SET unread_count = unread_count + 1 WHERE chat_id = $1 AND user_id != $2`,
      [chatId, senderId]
    );

    const created = await db.queryOne(`${MESSAGE_SELECT} WHERE m.id = $1`, [msgId]);
    const wm = await chatState.watermarksFor(chatId, senderId);
    const message = mapMessage(created, wm);
    res.status(201).json(message);

    // Everyone in the chat (the sender's other devices too) gets it live.
    realtime.sendToChat(chatId, { type: 'message.new', chatId, message }).catch(() => {});

    // Phone notification only for people who are not connected right now.
    const sender = await db.queryOne('SELECT full_name, nick_name, avatar_url FROM users WHERE uid = $1', [senderId]);
    const chat = await db.queryOne('SELECT item_name, post_id FROM chats WHERE id = $1', [chatId]);
    for (const o of others) {
      const settings = await getSettings(o.user_id);
      if (!settings.notify_messages) continue;
      await notify(o.user_id, {
        title: `${displayName(sender)} · ${chat ? chat.item_name : 'Message'}`,
        message: preview.length > 120 ? `${preview.slice(0, 117)}...` : preview,
        type: 'message',
        push: !realtime.isOnline(o.user_id),
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
  } catch (err) {
    console.error('Send message error:', err);
    if (!res.headersSent) res.status(500).json({ message: 'Error sending message.' });
  }
});

module.exports = router;
