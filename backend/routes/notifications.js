const express = require('express');
const db = require('../db');
const { verifyToken } = require('./auth');
const crypto = require('crypto');

const router = express.Router();

// GET /notifications - Fetch user notifications
router.get('/', verifyToken, async (req, res) => {
  try {
    const list = await db.query(
      `SELECT * FROM notifications 
       WHERE user_id = $1 
       ORDER BY created_at_ms DESC`,
      [req.userId]
    );

    const notifications = list.map(item => ({
      id: item.id,
      title: item.title,
      message: item.message,
      type: item.type,
      isUnread: !!item.is_unread,
      createdAtMs: parseInt(item.created_at_ms)
    }));

    res.status(200).json(notifications);
  } catch (err) {
    console.error('Get notifications error:', err);
    res.status(500).json({ message: 'Error loading notifications.' });
  }
});

// PUT /notifications/:id/read - Mark notification as read
router.put('/:id/read', verifyToken, async (req, res) => {
  const { id } = req.params;

  try {
    const notif = await db.queryOne('SELECT * FROM notifications WHERE id = $1', [id]);
    if (!notif) {
      return res.status(404).json({ message: 'Notification not found.' });
    }
    if (notif.user_id !== req.userId) {
      return res.status(403).json({ message: 'Not authorized.' });
    }

    await db.exec(
      'UPDATE notifications SET is_unread = FALSE WHERE id = $1',
      [id]
    );

    res.status(200).json({ message: 'Notification marked as read.' });
  } catch (err) {
    console.error('Mark read notification error:', err);
    res.status(500).json({ message: 'Error updating notification.' });
  }
});

// POST /notifications - Add a notification
router.post('/', verifyToken, async (req, res) => {
  const { userId, title, message, type } = req.body;

  if (!userId || !title || !message || !type) {
    return res.status(400).json({ message: 'userId, title, message, and type are required.' });
  }

  try {
    const id = crypto.randomUUID();
    const now = Date.now();

    await db.exec(
      `INSERT INTO notifications (id, user_id, title, message, type, is_unread, created_at_ms)
       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [id, userId, title, message, type, true, now]
    );

    res.status(201).json({ id, message: 'Notification created successfully.' });
  } catch (err) {
    console.error('Create notification error:', err);
    res.status(500).json({ message: 'Error creating notification.' });
  }
});

module.exports = router;
