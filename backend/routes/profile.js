const express = require('express');
const db = require('../db');
const { verifyToken } = require('./auth');

const router = express.Router();

// GET /profile - Get profile of current user
router.get('/', verifyToken, async (req, res) => {
  try {
    const user = await db.queryOne('SELECT * FROM users WHERE uid = $1', [req.userId]);
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    res.status(200).json({
      uid: user.uid,
      email: user.email,
      fullName: user.full_name || '',
      nickName: user.nick_name || '',
      phone: user.phone || '',
      address: user.address || '',
      job: user.job || '',
      avatarUrl: user.avatar_url || '',
      createdAtMs: parseInt(user.created_at)
    });
  } catch (err) {
    console.error('Get profile error:', err);
    res.status(500).json({ message: 'Error fetching profile.' });
  }
});

// PUT /profile - Update profile details
router.put('/', verifyToken, async (req, res) => {
  const { fullName, nickName, phone, address, job, avatarUrl } = req.body;

  try {
    const user = await db.queryOne('SELECT * FROM users WHERE uid = $1', [req.userId]);
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

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
        req.userId
      ]
    );

    res.status(200).json({
      uid: user.uid,
      email: user.email,
      fullName: fullName !== undefined ? fullName : user.full_name,
      nickName: nickName !== undefined ? nickName : user.nick_name,
      phone: phone !== undefined ? phone : user.phone,
      address: address !== undefined ? address : user.address,
      job: job !== undefined ? job : user.job,
      avatarUrl: avatarUrl !== undefined ? avatarUrl : user.avatar_url,
      createdAtMs: parseInt(user.created_at)
    });
  } catch (err) {
    console.error('Update profile error:', err);
    res.status(500).json({ message: 'Error updating profile.' });
  }
});

// GET /profile/privacy - Get privacy settings
router.get('/privacy', verifyToken, async (req, res) => {
  try {
    // We can use settings table or settings subcollection representation
    // Let's query from settings table or return defaults if not found
    // To make it easy, we store settings as JSON or check if a table is created.
    // Wait, let's see if we created a settings table. No, we created `chat_participants`, `blocked_users`, `saved_items` etc. We didn't create a privacy settings table.
    // Let's check `db.js`. Ah, we didn't add settings table in postgres/sqlite. Let's add it or store it in `users` table or a quick settings query.
    // Wait, let's look at `db.js` table init: we have `blocked_users`, `saved_items`.
    // Wait! Let's check if we can add columns or store it in user profile metadata, OR we can just store it in a simple table.
    // Oh, wait! In `db.js` table init, I wrote:
    // `users` (id, email, password_hash, full_name, nick_name, phone, address, job, avatar_url, created_at, updated_at)
    // Wait, what if we check settings? If we want privacy settings, we can add a table or just return default settings and save them.
    // Let's write a simple query to see if we can just create a `settings` table in SQLite/Postgres. But wait! I can just use a simple `settings` table or store settings columns in the `users` table. Yes, adding settings columns to `users` table is incredibly clean, or just creating a settings table.
    // Wait! Let's check if the privacy settings endpoints are non-critical or if we can store them in a simple table. Let's check: we can create a `user_settings` table dynamically or store them in `users` table as json or columns.
    // Let's check: we can create a `user_settings` table or just add a try-catch for settings creation. Let's create a table or query it. Let's see, since we did not define it in `db.js` yet, we can run a CREATE TABLE query inside `profile.js` to initialize it if it doesn't exist, which is very safe and dynamic!
    // Yes! Let's run `CREATE TABLE IF NOT EXISTS user_settings (user_id VARCHAR(255) PRIMARY KEY, show_profile BOOLEAN DEFAULT TRUE, allow_messages BOOLEAN DEFAULT TRUE, show_location BOOLEAN DEFAULT FALSE, hide_phone BOOLEAN DEFAULT TRUE)` inside this route file initialization. This is robust!
    
    await db.exec(`
      CREATE TABLE IF NOT EXISTS user_settings (
        user_id VARCHAR(255) PRIMARY KEY,
        show_profile BOOLEAN DEFAULT TRUE,
        allow_messages BOOLEAN DEFAULT TRUE,
        show_location BOOLEAN DEFAULT FALSE,
        hide_phone BOOLEAN DEFAULT TRUE
      )
    `);

    let settings = await db.queryOne('SELECT * FROM user_settings WHERE user_id = $1', [req.userId]);
    if (!settings) {
      // Return defaults
      return res.status(200).json({
        showProfile: true,
        allowMessages: true,
        showLocation: false,
        hidePhone: true
      });
    }

    res.status(200).json({
      showProfile: !!settings.show_profile,
      allowMessages: !!settings.allow_messages,
      showLocation: !!settings.show_location,
      hidePhone: !!settings.hide_phone
    });
  } catch (err) {
    console.error('Get privacy error:', err);
    res.status(500).json({ message: 'Error loading privacy settings.' });
  }
});

// PUT /profile/privacy - Update privacy settings
router.put('/privacy', verifyToken, async (req, res) => {
  const { showProfile, allowMessages, showLocation, hidePhone } = req.body;

  try {
    await db.exec(`
      CREATE TABLE IF NOT EXISTS user_settings (
        user_id VARCHAR(255) PRIMARY KEY,
        show_profile BOOLEAN DEFAULT TRUE,
        allow_messages BOOLEAN DEFAULT TRUE,
        show_location BOOLEAN DEFAULT FALSE,
        hide_phone BOOLEAN DEFAULT TRUE
      )
    `);

    // UPSERT
    const exists = await db.queryOne('SELECT * FROM user_settings WHERE user_id = $1', [req.userId]);
    if (exists) {
      await db.exec(
        `UPDATE user_settings 
         SET show_profile = $1, allow_messages = $2, show_location = $3, hide_phone = $4
         WHERE user_id = $5`,
        [
          showProfile !== undefined ? showProfile : exists.show_profile,
          allowMessages !== undefined ? allowMessages : exists.allow_messages,
          showLocation !== undefined ? showLocation : exists.show_location,
          hidePhone !== undefined ? hidePhone : exists.hide_phone,
          req.userId
        ]
      );
    } else {
      await db.exec(
        `INSERT INTO user_settings (user_id, show_profile, allow_messages, show_location, hide_phone)
         VALUES ($1, $2, $3, $4, $5)`,
        [
          req.userId,
          showProfile !== undefined ? showProfile : true,
          allowMessages !== undefined ? allowMessages : true,
          showLocation !== undefined ? showLocation : false,
          hidePhone !== undefined ? hidePhone : true
        ]
      );
    }

    res.status(200).json({
      showProfile: showProfile !== undefined ? showProfile : true,
      allowMessages: allowMessages !== undefined ? allowMessages : true,
      showLocation: showLocation !== undefined ? showLocation : false,
      hidePhone: hidePhone !== undefined ? hidePhone : true
    });
  } catch (err) {
    console.error('Update privacy error:', err);
    res.status(500).json({ message: 'Error updating privacy settings.' });
  }
});

// GET /profile/blocked - Get blocked users
router.get('/blocked', verifyToken, async (req, res) => {
  try {
    const list = await db.query(
      `SELECT bu.blocked_user_id as id, u.full_name, u.nick_name 
       FROM blocked_users bu
       JOIN users u ON bu.blocked_user_id = u.uid
       WHERE bu.user_id = $1`,
      [req.userId]
    );

    const users = list.map(user => ({
      id: user.id,
      name: user.full_name || user.nick_name || 'User',
      avatarLabel: (user.full_name || user.nick_name || '?')[0].toUpperCase()
    }));

    res.status(200).json(users);
  } catch (err) {
    console.error('Get blocked error:', err);
    res.status(500).json({ message: 'Error fetching blocked users.' });
  }
});

// POST /profile/blocked - Block a user
router.post('/blocked', verifyToken, async (req, res) => {
  const { blockedUserId } = req.body;
  if (!blockedUserId) {
    return res.status(400).json({ message: 'blockedUserId is required.' });
  }

  try {
    // Check if already blocked
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

// DELETE /profile/blocked/:blockedUserId - Unblock a user
router.delete('/blocked/:blockedUserId', verifyToken, async (req, res) => {
  const { blockedUserId } = req.params;

  try {
    await db.exec(
      'DELETE FROM blocked_users WHERE user_id = $1 AND blocked_user_id = $2',
      [req.userId, blockedUserId]
    );
    res.status(200).json({ message: 'User unblocked successfully.' });
  } catch (err) {
    console.error('Unblock user error:', err);
    res.status(500).json({ message: 'Error unblocking user.' });
  }
});

// GET /profile/saved - Get bookmarked items
router.get('/saved', verifyToken, async (req, res) => {
  try {
    const list = await db.query(
      `SELECT p.* 
       FROM saved_items s
       JOIN posts p ON s.post_id = p.id
       WHERE s.user_id = $1`,
      [req.userId]
    );

    const items = list.map(post => ({
      id: post.id,
      title: post.title,
      description: post.description,
      category: post.category,
      isLost: !!post.is_lost,
      reward: post.reward,
      ownerId: post.owner_id,
      location: post.location,
      imageUrl: post.image_url,
      createdAtMs: parseInt(post.created_at_ms),
      updatedAtMs: parseInt(post.updated_at_ms),
      status: post.status
    }));

    res.status(200).json(items);
  } catch (err) {
    console.error('Get saved items error:', err);
    res.status(500).json({ message: 'Error loading saved items.' });
  }
});

// POST /profile/saved - Bookmark a post
router.post('/saved', verifyToken, async (req, res) => {
  const { postId } = req.body;
  if (!postId) {
    return res.status(400).json({ message: 'postId is required.' });
  }

  try {
    const exists = await db.queryOne(
      'SELECT * FROM saved_items WHERE user_id = $1 AND post_id = $2',
      [req.userId, postId]
    );
    if (!exists) {
      await db.exec(
        'INSERT INTO saved_items (user_id, post_id) VALUES ($1, $2)',
        [req.userId, postId]
      );
    }
    res.status(200).json({ message: 'Post saved successfully.' });
  } catch (err) {
    console.error('Save post error:', err);
    res.status(500).json({ message: 'Error saving post.' });
  }
});

// DELETE /profile/saved/:postId - Remove a bookmarked post
router.delete('/saved/:postId', verifyToken, async (req, res) => {
  const { postId } = req.params;

  try {
    await db.exec(
      'DELETE FROM saved_items WHERE user_id = $1 AND post_id = $2',
      [req.userId, postId]
    );
    res.status(200).json({ message: 'Post removed from saved list.' });
  } catch (err) {
    console.error('Remove saved post error:', err);
    res.status(500).json({ message: 'Error removing saved post.' });
  }
});

module.exports = router;
