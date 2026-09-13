const express = require('express');
const db = require('../db');
const { verifyToken } = require('./auth');
const { blockedIdsFor, displayName, truthy } = require('../lib/helpers');

const router = express.Router();

// GET /users/search?q=  — find people to message (excludes self and blocks)
router.get('/search', verifyToken, async (req, res) => {
  const q = (req.query.q || '').toString().trim().toLowerCase();
  if (q.length < 2) return res.status(200).json([]);

  try {
    const like = `%${q}%`;
    const rows = await db.query(
      `SELECT uid, full_name, nick_name, avatar_url, email, identity_verified
       FROM users
       WHERE uid != $1
         AND (LOWER(full_name) LIKE $2 OR LOWER(nick_name) LIKE $3 OR LOWER(email) LIKE $4)
       ORDER BY full_name ASC
       LIMIT 25`,
      [req.userId, like, like, like]
    );
    const blocked = await blockedIdsFor(req.userId);
    const users = rows
      .filter(r => !blocked.has(r.uid))
      .slice(0, 10)
      .map(r => ({
        uid: r.uid,
        fullName: displayName(r),
        nickName: r.nick_name || '',
        avatarUrl: r.avatar_url || '',
        identityVerified: truthy(r.identity_verified),
      }));
    res.status(200).json(users);
  } catch (err) {
    console.error('User search error:', err);
    res.status(500).json({ message: 'Error searching users.' });
  }
});

module.exports = router;
