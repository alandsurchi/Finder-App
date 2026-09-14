const express = require('express');
const db = require('../db');
const { verifyToken } = require('./auth');
const crypto = require('crypto');
const { POST_SELECT, mapPost, bool, truthy, notify, blockedIdsFor } = require('../lib/helpers');
const { validate, schemas } = require('../lib/validate');

const router = express.Router();

/** Coordinates are optional; anything that is not a finite number is stored as NULL. */
function coord(v) {
  return typeof v === 'number' && Number.isFinite(v) ? v : null;
}

// GET /posts
router.get('/', verifyToken, async (req, res) => {
  const limit = Math.min(parseInt(req.query.limit) || 20, 100);
  const cursor = req.query.cursor ? parseInt(req.query.cursor) : null;
  const category = req.query.category; // e.g. "All Items", "Lost", "Found"
  const ownerId = req.query.ownerId;
  const status = req.query.status; // optional: active | resolved

  let sql = POST_SELECT;
  const params = [];
  const conditions = [];

  if (cursor !== null) {
    params.push(cursor);
    conditions.push(`p.created_at_ms < $${params.length}`);
  }

  if (category && category !== 'All Items') {
    const isLost = category === 'Lost';
    params.push(bool(isLost));
    conditions.push(`p.is_lost = $${params.length}`);
  }

  if (ownerId) {
    params.push(ownerId);
    conditions.push(`p.owner_id = $${params.length}`);
  }

  if (status) {
    params.push(status);
    conditions.push(`p.status = $${params.length}`);
  }

  // Hide posts from users blocked in either direction.
  params.push(req.userId);
  conditions.push(`p.owner_id NOT IN (SELECT blocked_user_id FROM blocked_users WHERE user_id = $${params.length})`);
  params.push(req.userId);
  conditions.push(`p.owner_id NOT IN (SELECT user_id FROM blocked_users WHERE blocked_user_id = $${params.length})`);

  if (conditions.length > 0) {
    sql += ' WHERE ' + conditions.join(' AND ');
  }

  params.push(limit);
  // Open posts first so returned ones never crowd them out of the page.
  sql += ` ORDER BY CASE WHEN p.status = 'active' THEN 0 ELSE 1 END, p.created_at_ms DESC LIMIT $${params.length}`;

  try {
    const rows = await db.query(sql, params);
    const items = rows.map(mapPost);
    const hasMore = items.length === limit;
    const nextCursor = hasMore && items.length > 0 ? items[items.length - 1].createdAtMs.toString() : null;
    res.status(200).json({ items, nextCursor, hasMore });
  } catch (err) {
    console.error('Fetch posts error:', err);
    res.status(500).json({ message: 'Error loading posts.' });
  }
});

// GET /posts/:id
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const row = await db.queryOne(`${POST_SELECT} WHERE p.id = $1`, [req.params.id]);
    if (!row) return res.status(404).json({ message: 'Post not found.' });
    res.status(200).json(mapPost(row));
  } catch (err) {
    console.error('Fetch post error:', err);
    res.status(500).json({ message: 'Error loading post.' });
  }
});

// GET /posts/:id/similar — same category, opposite lost/found first, newest
router.get('/:id/similar', verifyToken, async (req, res) => {
  try {
    const post = await db.queryOne('SELECT * FROM posts WHERE id = $1', [req.params.id]);
    if (!post) return res.status(404).json({ message: 'Post not found.' });

    const blocked = await blockedIdsFor(req.userId);
    const rows = await db.query(
      `${POST_SELECT}
       WHERE p.category = $1 AND p.id != $2 AND p.status = 'active'
       ORDER BY CASE WHEN p.is_lost = $3 THEN 1 ELSE 0 END ASC, p.created_at_ms DESC
       LIMIT 12`,
      [post.category, post.id, bool(truthy(post.is_lost))]
    );
    const items = rows.filter(r => !blocked.has(r.owner_id)).slice(0, 6).map(mapPost);
    res.status(200).json(items);
  } catch (err) {
    console.error('Fetch similar posts error:', err);
    res.status(500).json({ message: 'Error loading similar posts.' });
  }
});

// POST /posts (Create)
router.post('/', verifyToken, validate(schemas.createPost), async (req, res) => {
  const { title, description, category, isLost, reward, location, imageUrl, lostOn, latitude, longitude } = req.body;

  try {
    const id = crypto.randomUUID();
    const now = Date.now();
    const ownerId = req.userId;

    await db.exec(
      `INSERT INTO posts (id, owner_id, title, description, category, is_lost, reward, location, image_url, lost_on, status, created_at_ms, updated_at_ms, latitude, longitude)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)`,
      [id, ownerId, title, description, category, bool(!!isLost), reward === undefined || reward === null || reward === '' ? null : String(reward), location, imageUrl || '', lostOn || null, 'active', now, now, coord(latitude), coord(longitude)]
    );

    const row = await db.queryOne(`${POST_SELECT} WHERE p.id = $1`, [id]);
    res.status(201).json(mapPost(row));
  } catch (err) {
    console.error('Create post error:', err);
    res.status(500).json({ message: 'Error creating post.' });
  }
});

// PUT /posts/:id (Update)
router.put('/:id', verifyToken, validate(schemas.updatePost), async (req, res) => {
  const { id } = req.params;
  const { title, description, category, isLost, reward, location, imageUrl, lostOn, status, latitude, longitude } = req.body;

  try {
    const post = await db.queryOne('SELECT * FROM posts WHERE id = $1', [id]);
    if (!post) {
      return res.status(404).json({ message: 'Post not found.' });
    }
    if (post.owner_id !== req.userId) {
      return res.status(403).json({ message: 'You do not own this post.' });
    }

    const now = Date.now();
    const nextStatus = status !== undefined ? status : post.status;
    await db.exec(
      `UPDATE posts
       SET title = $1, description = $2, category = $3, is_lost = $4, reward = $5, location = $6,
           image_url = $7, lost_on = $8, status = $9, updated_at_ms = $10, latitude = $11, longitude = $12
       WHERE id = $13`,
      [
        title !== undefined ? title : post.title,
        description !== undefined ? description : post.description,
        category !== undefined ? category : post.category,
        isLost !== undefined ? bool(!!isLost) : post.is_lost,
        reward !== undefined ? (reward === null || reward === '' ? null : String(reward)) : post.reward,
        location !== undefined ? location : post.location,
        imageUrl !== undefined ? imageUrl : post.image_url,
        lostOn !== undefined ? lostOn : post.lost_on,
        nextStatus,
        now,
        latitude !== undefined ? coord(latitude) : post.latitude,
        longitude !== undefined ? coord(longitude) : post.longitude,
        id,
      ]
    );

    // Tell everyone who chatted about this item that it was resolved.
    if (nextStatus === 'resolved' && post.status !== 'resolved') {
      const peers = await db.query(
        `SELECT DISTINCT cp.user_id FROM chat_participants cp
         JOIN chats c ON c.id = cp.chat_id
         WHERE c.post_id = $1 AND cp.user_id != $2`,
        [id, req.userId]
      );
      for (const peer of peers) {
        await notify(peer.user_id, {
          title: 'Item resolved',
          message: `"${post.title}" has been marked as resolved.`,
          type: 'update',
        });
      }
    }

    const row = await db.queryOne(`${POST_SELECT} WHERE p.id = $1`, [id]);
    res.status(200).json(mapPost(row));
  } catch (err) {
    console.error('Update post error:', err);
    res.status(500).json({ message: 'Error updating post.' });
  }
});

// DELETE /posts/:id
router.delete('/:id', verifyToken, async (req, res) => {
  const { id } = req.params;

  try {
    const post = await db.queryOne('SELECT * FROM posts WHERE id = $1', [id]);
    if (!post) {
      return res.status(404).json({ message: 'Post not found.' });
    }
    if (post.owner_id !== req.userId) {
      return res.status(403).json({ message: 'You do not own this post.' });
    }

    // SQLite does not enforce the foreign keys, so clean up by hand.
    await db.exec('DELETE FROM saved_items WHERE post_id = $1', [id]);
    await db.exec('DELETE FROM reports WHERE post_id = $1', [id]);
    await db.exec(
      'DELETE FROM messages WHERE chat_id IN (SELECT id FROM chats WHERE post_id = $1)',
      [id]
    );
    await db.exec(
      'DELETE FROM chat_participants WHERE chat_id IN (SELECT id FROM chats WHERE post_id = $1)',
      [id]
    );
    await db.exec('DELETE FROM chats WHERE post_id = $1', [id]);
    await db.exec('DELETE FROM posts WHERE id = $1', [id]);
    res.status(200).json({ message: 'Post deleted successfully.' });
  } catch (err) {
    console.error('Delete post error:', err);
    res.status(500).json({ message: 'Error deleting post.' });
  }
});

// POST /posts/:id/report (Report a post)
router.post('/:id/report', verifyToken, validate(schemas.reportPost), async (req, res) => {
  const { id } = req.params;
  const { reason } = req.body;

  try {
    const post = await db.queryOne('SELECT id FROM posts WHERE id = $1', [id]);
    if (!post) return res.status(404).json({ message: 'Post not found.' });

    const existing = await db.queryOne(
      'SELECT id FROM reports WHERE post_id = $1 AND reporter_id = $2',
      [id, req.userId]
    );
    if (existing) {
      return res.status(200).json({ message: 'You already reported this post.' });
    }

    await db.exec(
      `INSERT INTO reports (id, post_id, reporter_id, reason, status, created_at_ms)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [crypto.randomUUID(), id, req.userId, reason || '', 'pending', Date.now()]
    );

    res.status(201).json({ message: 'Report submitted successfully.' });
  } catch (err) {
    console.error('Report post error:', err);
    res.status(500).json({ message: 'Error submitting report.' });
  }
});

module.exports = router;
