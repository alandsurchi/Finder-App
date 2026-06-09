const express = require('express');
const db = require('../db');
const { verifyToken } = require('./auth');
const crypto = require('crypto');

const router = express.Router();

// GET /chats - Get user conversations
router.get('/', verifyToken, async (req, res) => {
  const userId = req.userId;

  try {
    // 1. Get all chats where this user is a participant
    const chats = await db.query(
      `SELECT c.*, cp.unread_count 
       FROM chats c
       JOIN chat_participants cp ON c.id = cp.chat_id
       WHERE cp.user_id = $1
       ORDER BY c.updated_at_ms DESC`,
      [userId]
    );

    const conversations = [];

    for (const chat of chats) {
      // 2. Fetch all participants for this chat to get names/avatars
      const participants = await db.query(
        `SELECT cp.user_id, cp.unread_count, u.full_name, u.nick_name, u.avatar_url 
         FROM chat_participants cp
         JOIN users u ON cp.user_id = u.uid
         WHERE cp.chat_id = $1`,
        [chat.id]
      );

      const participantIds = participants.map(p => p.user_id);
      const participantNames = {};
      const participantAvatars = {};

      participants.forEach(p => {
        participantNames[p.user_id] = p.full_name || p.nick_name || 'User';
        participantAvatars[p.user_id] = p.avatar_url || '';
      });

      conversations.push({
        id: chat.id,
        postId: chat.post_id,
        itemName: chat.item_name,
        participants: participantIds,
        participantNames,
        participantAvatars,
        lastMessageText: chat.last_message_text || '',
        lastSenderId: chat.last_sender_id || '',
        updatedAtMs: parseInt(chat.updated_at_ms),
        unreadCounts: {
          [userId]: chat.unread_count
        }
      });
    }

    res.status(200).json(conversations);
  } catch (err) {
    console.error('Fetch chats error:', err);
    res.status(500).json({ message: 'Error loading conversations.' });
  }
});

// GET /chats/:id/messages - Get messages in a chat
router.get('/:id/messages', verifyToken, async (req, res) => {
  const chatId = req.params.id;
  const limit = parseInt(req.query.limit) || 20;
  const cursor = req.query.cursor ? parseInt(req.query.cursor) : null;

  try {
    // Check if user is a participant
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

    // Map fields to client-side camelCase
    const items = messages.map(msg => ({
      id: msg.id,
      chatId: msg.chat_id,
      senderId: msg.sender_id,
      text: msg.text,
      createdAtMs: parseInt(msg.created_at_ms),
      isRead: !!msg.is_read
    }));

    // Reset unread count for current user
    await db.exec(
      'UPDATE chat_participants SET unread_count = 0 WHERE chat_id = $1 AND user_id = $2',
      [chatId, req.userId]
    );

    const hasMore = items.length === limit;
    const nextCursor = hasMore && items.length > 0 ? items[items.length - 1].createdAtMs.toString() : null;

    res.status(200).json({
      items,
      nextCursor,
      hasMore
    });
  } catch (err) {
    console.error('Fetch messages error:', err);
    res.status(500).json({ message: 'Error loading messages.' });
  }
});

// POST /chats/initiate - Start or get a chat
router.post('/initiate', verifyToken, async (req, res) => {
  const { peerId, postId, itemName } = req.body;
  const currentUserId = req.userId;

  if (!peerId || !postId || !itemName) {
    return res.status(400).json({ message: 'peerId, postId, and itemName are required.' });
  }

  // Generate unique chatId
  const ids = [currentUserId, peerId].sort();
  const chatId = `${postId}_${ids[0]}_${ids[1]}`;

  try {
    // Check if chat already exists
    const existingChat = await db.queryOne('SELECT * FROM chats WHERE id = $1', [chatId]);
    if (existingChat) {
      return res.status(200).json({ chatId });
    }

    const now = Date.now();

    // 1. Create chat
    await db.exec(
      `INSERT INTO chats (id, post_id, item_name, last_message_text, last_sender_id, created_at_ms, updated_at_ms)
       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [chatId, postId, itemName, '', '', now, now]
    );

    // 2. Add participants
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

// POST /chats/:id/messages - Send a message via REST
router.post('/:id/messages', verifyToken, async (req, res) => {
  const chatId = req.params.id;
  const { text } = req.body;
  const senderId = req.userId;

  if (!text || text.trim().isEmpty) {
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

    const msgId = crypto.randomUUID();
    const now = Date.now();

    // 1. Insert message
    await db.exec(
      `INSERT INTO messages (id, chat_id, sender_id, text, is_read, created_at_ms)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [msgId, chatId, senderId, text.trim(), false, now]
    );

    // 2. Update chat last message metadata
    await db.exec(
      `UPDATE chats 
       SET last_message_text = $1, last_sender_id = $2, updated_at_ms = $3
       WHERE id = $4`,
      [text.trim(), senderId, now, chatId]
    );

    // 3. Increment unread count for other participants
    await db.exec(
      `UPDATE chat_participants 
       SET unread_count = unread_count + 1 
       WHERE chat_id = $1 AND user_id != $2`,
      [chatId, senderId]
    );

    res.status(201).json({
      id: msgId,
      chatId,
      senderId,
      text: text.trim(),
      createdAtMs: now,
      isRead: false
    });
  } catch (err) {
    console.error('Send message error:', err);
    res.status(500).json({ message: 'Error sending message.' });
  }
});

module.exports = router;
