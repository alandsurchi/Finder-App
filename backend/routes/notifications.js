const express = require('express');
const db = require('../db');
const { verifyToken } = require('./auth');
const { truthy, bool, parseNotificationData } = require('../lib/helpers');

const router = express.Router();

function mapNotification(item) {
  return {
    id: item.id,
    title: item.title,
    message: item.message,
    type: item.type,
    isUnread: truthy(item.is_unread),
    createdAtMs: parseInt(item.created_at_ms),
    data: parseNotificationData(item.data),
  };
}

// GET /notifications - newest first
router.get('/', verifyToken, async (req, res) => {
  try {
    const list = await db.query(
      `SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at_ms DESC LIMIT 200`,
      [req.userId]
    );
    res.status(200).json(list.map(mapNotification));
  } catch (err) {
    console.error('Get notifications error:', err);
    res.status(500).json({ message: 'Error loading notifications.' });
  }
});

// PUT /notifications/read-all
router.put('/read-all', verifyToken, async (req, res) => {
  try {
    await db.exec(
      'UPDATE notifications SET is_unread = $1 WHERE user_id = $2',
      [bool(false), req.userId]
    );
    res.status(200).json({ message: 'All notifications marked as read.' });
  } catch (err) {
    console.error('Mark all read error:', err);
    res.status(500).json({ message: 'Error updating notifications.' });
  }
});

// PUT /notifications/:id/read
router.put('/:id/read', verifyToken, async (req, res) => {
  const { id } = req.params;
  try {
    const notif = await db.queryOne('SELECT * FROM notifications WHERE id = $1', [id]);
    if (!notif) return res.status(404).json({ message: 'Notification not found.' });
    if (notif.user_id !== req.userId) return res.status(403).json({ message: 'Not authorized.' });

    await db.exec('UPDATE notifications SET is_unread = $1 WHERE id = $2', [bool(false), id]);
    res.status(200).json({ message: 'Notification marked as read.' });
  } catch (err) {
    console.error('Mark read notification error:', err);
    res.status(500).json({ message: 'Error updating notification.' });
  }
});

module.exports = router;
