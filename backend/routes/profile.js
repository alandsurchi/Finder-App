const express = require('express');
const crypto = require('crypto');
const db = require('../db');
const { verifyToken } = require('./auth');
const {
  truthy,
  isBlocked,
  getSettings,
  saveSettings,
  POST_SELECT,
  mapPost,
  displayName,
  bool,
} = require('../lib/helpers');

const router = express.Router();

function ownProfile(user) {
  return {
    uid: user.uid,
    email: user.email,
    fullName: user.full_name || '',
    nickName: user.nick_name || '',
    phone: user.phone || '',
    address: user.address || '',
    job: user.job || '',
    avatarUrl: user.avatar_url || '',
    identityVerified: truthy(user.identity_verified),
    createdAtMs: parseInt(user.created_at),
  };
}

// GET /profile - current user
router.get('/', verifyToken, async (req, res) => {
  try {
    const user = await db.queryOne('SELECT * FROM users WHERE uid = $1', [req.userId]);
    if (!user) return res.status(404).json({ message: 'User not found.' });
    res.status(200).json(ownProfile(user));
  } catch (err) {
    console.error('Get profile error:', err);
    res.status(500).json({ message: 'Error fetching profile.' });
  }
});

// PUT /profile - update profile details
router.put('/', verifyToken, async (req, res) => {
  const { fullName, nickName, phone, address, job, avatarUrl } = req.body;

  try {
    const user = await db.queryOne('SELECT * FROM users WHERE uid = $1', [req.userId]);
    if (!user) return res.status(404).json({ message: 'User not found.' });

    const now = Date.now();
    await db.exec(
      `UPDATE users
       SET full_name = $1, nick_name = $2, phone = $3, address = $4, job = $5, avatar_url = $6, updated_at = $7
       WHERE uid = $8`,
      [
        fullName !== undefined ? fullName : user.full_name,
        nickName !== undefined ? nickName : user.nick_name,
        phone !== undefined ? phone : user.phone,
        address !== undefined ? address : user.address,
        job !== undefined ? job : user.job,
        avatarUrl !== undefined ? avatarUrl : user.avatar_url,
        now,
        req.userId,
      ]
    );

    const updated = await db.queryOne('SELECT * FROM users WHERE uid = $1', [req.userId]);
    res.status(200).json(ownProfile(updated));
  } catch (err) {
    console.error('Update profile error:', err);
    res.status(500).json({ message: 'Error updating profile.' });
  }
});

// ── Privacy settings ────────────────────────────────────────────────────────
function privacyView(s) {
  return {
    showProfile: s.show_profile,
    allowMessages: s.allow_messages,
    showLocation: s.show_location,
    hidePhone: s.hide_phone,
  };
}

router.get('/privacy', verifyToken, async (req, res) => {
  try {
    res.status(200).json(privacyView(await getSettings(req.userId)));
  } catch (err) {
    console.error('Get privacy error:', err);
    res.status(500).json({ message: 'Error loading privacy settings.' });
  }
});

router.put('/privacy', verifyToken, async (req, res) => {
  const { showProfile, allowMessages, showLocation, hidePhone } = req.body;
  try {
    const next = await saveSettings(req.userId, {
      show_profile: showProfile,
      allow_messages: allowMessages,
      show_location: showLocation,
      hide_phone: hidePhone,
    });
    res.status(200).json(privacyView(next));
  } catch (err) {
    console.error('Update privacy error:', err);
    res.status(500).json({ message: 'Error updating privacy settings.' });
  }
});

// ── Notification settings ───────────────────────────────────────────────────
function notificationView(s) {
  return {
    messages: s.notify_messages,
    matches: s.notify_matches,
    updates: s.notify_updates,
    marketing: s.notify_marketing,
    email: s.notify_email,
  };
}

router.get('/notification-settings', verifyToken, async (req, res) => {
  try {
    res.status(200).json(notificationView(await getSettings(req.userId)));
  } catch (err) {
    console.error('Get notification settings error:', err);
    res.status(500).json({ message: 'Error loading notification settings.' });
  }
});

router.put('/notification-settings', verifyToken, async (req, res) => {
  const { messages, matches, updates, marketing, email } = req.body;
  try {
    const next = await saveSettings(req.userId, {
      notify_messages: messages,
      notify_matches: matches,
      notify_updates: updates,
      notify_marketing: marketing,
      notify_email: email,
    });
    res.status(200).json(notificationView(next));
  } catch (err) {
    console.error('Update notification settings error:', err);
    res.status(500).json({ message: 'Error updating notification settings.' });
  }
});

// ── Identity verification ───────────────────────────────────────────────────
router.get('/verification', verifyToken, async (req, res) => {
  try {
    const user = await db.queryOne('SELECT identity_verified FROM users WHERE uid = $1', [req.userId]);
    if (user && truthy(user.identity_verified)) {
      return res.status(200).json({ status: 'approved' });
    }
    const latest = await db.queryOne(
      'SELECT * FROM verification_requests WHERE user_id = $1 ORDER BY created_at_ms DESC LIMIT 1',
      [req.userId]
    );
    if (!latest) return res.status(200).json({ status: 'none' });
    res.status(200).json({
      status: latest.status,
      docType: latest.doc_type,
      createdAtMs: parseInt(latest.created_at_ms),
    });
  } catch (err) {
    console.error('Get verification error:', err);
    res.status(500).json({ message: 'Error loading verification status.' });
  }
});

router.post('/verification', verifyToken, async (req, res) => {
  const { docType, frontUrl, backUrl, selfieUrl } = req.body;
  if (!docType || !frontUrl || !selfieUrl) {
    return res.status(400).json({ message: 'docType, frontUrl and selfieUrl are required.' });
  }
  try {
    const user = await db.queryOne('SELECT identity_verified FROM users WHERE uid = $1', [req.userId]);
    if (user && truthy(user.identity_verified)) {
      return res.status(400).json({ message: 'Your identity is already verified.' });
    }
    const pending = await db.queryOne(
      `SELECT id FROM verification_requests WHERE user_id = $1 AND status = 'pending'`,
      [req.userId]
    );
    if (pending) {
      return res.status(400).json({ message: 'You already have a verification request under review.' });
    }
    const now = Date.now();
    await db.exec(
      `INSERT INTO verification_requests (id, user_id, doc_type, front_url, back_url, selfie_url, status, created_at_ms)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [crypto.randomUUID(), req.userId, docType, frontUrl, backUrl || '', selfieUrl, 'pending', now]
    );
    res.status(201).json({ status: 'pending', docType, createdAtMs: now });
  } catch (err) {
    console.error('Submit verification error:', err);
    res.status(500).json({ message: 'Error submitting verification.' });
  }
});

// ── Blocked users ───────────────────────────────────────────────────────────
router.get('/blocked', verifyToken, async (req, res) => {
  try {
    const list = await db.query(
      `SELECT bu.blocked_user_id AS id, u.full_name, u.nick_name, u.avatar_url
       FROM blocked_users bu
       JOIN users u ON bu.blocked_user_id = u.uid
       WHERE bu.user_id = $1`,
      [req.userId]
    );
    res.status(200).json(list.map(user => ({
      id: user.id,
      name: displayName(user),
      avatarLabel: displayName(user)[0].toUpperCase(),
      avatarUrl: user.avatar_url || '',
    })));
  } catch (err) {
    console.error('Get blocked error:', err);
    res.status(500).json({ message: 'Error fetching blocked users.' });
  }
});

router.post('/blocked', verifyToken, async (req, res) => {
  const { blockedUserId } = req.body;
  if (!blockedUserId) return res.status(400).json({ message: 'blockedUserId is required.' });
  if (blockedUserId === req.userId) return res.status(400).json({ message: 'You cannot block yourself.' });

  try {
    const target = await db.queryOne('SELECT uid FROM users WHERE uid = $1', [blockedUserId]);
    if (!target) return res.status(404).json({ message: 'User not found.' });
    const exists = await db.queryOne(
      'SELECT * FROM blocked_users WHERE user_id = $1 AND blocked_user_id = $2',
      [req.userId, blockedUserId]
    );
    if (!exists) {
      await db.exec(
        'INSERT INTO blocked_users (user_id, blocked_user_id) VALUES ($1, $2)',
        [req.userId, blockedUserId]
      );
    }
    res.status(200).json({ message: 'User blocked successfully.' });
  } catch (err) {
    console.error('Block user error:', err);
    res.status(500).json({ message: 'Error blocking user.' });
  }
});

router.delete('/blocked/:blockedUserId', verifyToken, async (req, res) => {
  try {
    await db.exec(
      'DELETE FROM blocked_users WHERE user_id = $1 AND blocked_user_id = $2',
      [req.userId, req.params.blockedUserId]
    );
    res.status(200).json({ message: 'User unblocked successfully.' });
  } catch (err) {
    console.error('Unblock user error:', err);
    res.status(500).json({ message: 'Error unblocking user.' });
  }
});

// ── Saved items ─────────────────────────────────────────────────────────────
router.get('/saved', verifyToken, async (req, res) => {
  try {
    const rows = await db.query(
      `${POST_SELECT}
       JOIN saved_items s ON s.post_id = p.id
       WHERE s.user_id = $1
       ORDER BY p.created_at_ms DESC`,
      [req.userId]
    );
    res.status(200).json(rows.map(mapPost));
  } catch (err) {
    console.error('Get saved items error:', err);
    res.status(500).json({ message: 'Error loading saved items.' });
  }
});

router.post('/saved', verifyToken, async (req, res) => {
  const { postId } = req.body;
  if (!postId) return res.status(400).json({ message: 'postId is required.' });

  try {
    const post = await db.queryOne('SELECT id FROM posts WHERE id = $1', [postId]);
    if (!post) return res.status(404).json({ message: 'Post not found.' });
    const exists = await db.queryOne(
      'SELECT * FROM saved_items WHERE user_id = $1 AND post_id = $2',
      [req.userId, postId]
    );
    if (!exists) {
      await db.exec('INSERT INTO saved_items (user_id, post_id) VALUES ($1, $2)', [req.userId, postId]);
    }
    res.status(200).json({ message: 'Post saved successfully.' });
  } catch (err) {
    console.error('Save post error:', err);
    res.status(500).json({ message: 'Error saving post.' });
  }
});

router.delete('/saved/:postId', verifyToken, async (req, res) => {
  try {
    await db.exec(
      'DELETE FROM saved_items WHERE user_id = $1 AND post_id = $2',
      [req.userId, req.params.postId]
    );
    res.status(200).json({ message: 'Post removed from saved list.' });
  } catch (err) {
    console.error('Remove saved post error:', err);
    res.status(500).json({ message: 'Error removing saved post.' });
  }
});

// ── Public profile (privacy-aware) ──────────────────────────────────────────
router.get('/:userId', verifyToken, async (req, res) => {
  const targetId = req.params.userId;
  try {
    const user = await db.queryOne('SELECT * FROM users WHERE uid = $1', [targetId]);
    if (!user) return res.status(404).json({ message: 'User not found.' });

    if (targetId === req.userId) {
      return res.status(200).json(ownProfile(user));
    }
    if (await isBlocked(req.userId, targetId)) {
      return res.status(404).json({ message: 'User not found.' });
    }

    const settings = await getSettings(targetId);
    const countRow = await db.queryOne('SELECT COUNT(*) AS n FROM posts WHERE owner_id = $1', [targetId]);
    const base = {
      uid: user.uid,
      fullName: user.full_name || '',
      nickName: user.nick_name || '',
      avatarUrl: user.avatar_url || '',
      identityVerified: truthy(user.identity_verified),
      memberSinceMs: parseInt(user.created_at),
      createdAtMs: parseInt(user.created_at),
      postsCount: parseInt(countRow ? countRow.n : 0) || 0,
      email: '',
      phone: '',
      address: '',
      job: '',
    };
    if (!settings.show_profile) {
      return res.status(200).json(base);
    }
    res.status(200).json({
      ...base,
      job: user.job || '',
      phone: settings.hide_phone ? '' : (user.phone || ''),
      address: settings.show_location ? (user.address || '') : '',
    });
  } catch (err) {
    console.error('Get specific user profile error:', err);
    res.status(500).json({ message: 'Error fetching user profile.' });
  }
});

module.exports = router;
