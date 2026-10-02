const express = require('express');
const db = require('../db');
const { verifyToken } = require('./auth');
const crypto = require('crypto');
const { POST_SELECT, mapPost, bool, truthy, notify, blockedIdsFor, getSettings, POST_PUBLIC_STATUSES } = require('../lib/helpers');
const { validate, schemas } = require('../lib/validate');
const matching = require('../lib/matching');
const moderation = require('../lib/moderation');
const limits = require('../lib/limits');

const router = express.Router();

/** Coordinates are optional; anything that is not a finite number is stored as NULL. */
function coord(v) {
  return typeof v === 'number' && Number.isFinite(v) ? v : null;
}

async function isAdmin(userId) {
  const me = await db.queryOne('SELECT is_admin FROM users WHERE uid = $1', [userId]);
  return !!(me && truthy(me.is_admin));
}

/** Pending, rejected and expired posts are only for their owner and admins. */
async function canSee(row, userId) {
  if (!row) return false;
  if (POST_PUBLIC_STATUSES.includes(row.status || 'active')) return true;
  if (row.owner_id === userId) return true;
  return isAdmin(userId);
}

// GET /posts
router.get('/', verifyToken, async (req, res) => {
  const limit = Math.min(parseInt(req.query.limit) || 20, 100);
  const cursor = req.query.cursor ? parseInt(req.query.cursor) : null;
  const category = req.query.category; // e.g. "All Items", "Lost", "Found"
  const ownerId = req.query.ownerId;
  const status = req.query.status; // optional: active | resolved (owner/admin: any)
  // Server-side search over the original text and every translation.
  const q = String(req.query.q || '').trim().toLowerCase().slice(0, 80);
  // Nearby: near=lat,lng&km=25 (bounding box, then exact distance in JS).
  const near = String(req.query.near || '').split(',').map(Number);
  const hasNear = near.length === 2 && near.every(Number.isFinite);
  const km = Math.min(Math.max(parseFloat(req.query.km) || 25, 1), 500);

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

  const mine = !!ownerId && ownerId === req.userId;
  if (status) {
    if (!POST_PUBLIC_STATUSES.includes(status) && !mine && !(await isAdmin(req.userId))) {
      return res.status(400).json({ message: 'That status is not public.' });
    }
    params.push(status);
    conditions.push(`p.status = $${params.length}`);
  } else if (!mine) {
    // Other people only ever see live and returned posts.
    conditions.push(`p.status IN ('active', 'resolved')`);
  }

  if (q) {
    // SQLite placeholders are positional: push the term once per use.
    const term = `%${q}%`;
    const i = params.length + 1;
    const uses = 9;
    for (let k = 0; k < (db.isPostgres ? 1 : uses); k++) params.push(term);
    const ph = n => db.isPostgres ? `$${i}` : `$${i + n}`;
    conditions.push(`(LOWER(p.title) LIKE ${ph(0)} OR LOWER(p.description) LIKE ${ph(1)} OR LOWER(p.location) LIKE ${ph(2)}
      OR LOWER(COALESCE(p.title_en, '')) LIKE ${ph(3)} OR LOWER(COALESCE(p.title_ar, '')) LIKE ${ph(4)} OR LOWER(COALESCE(p.title_ckb, '')) LIKE ${ph(5)}
      OR LOWER(COALESCE(p.description_en, '')) LIKE ${ph(6)} OR LOWER(COALESCE(p.description_ar, '')) LIKE ${ph(7)} OR LOWER(COALESCE(p.description_ckb, '')) LIKE ${ph(8)})`);
  }
  if (hasNear) {
    const dLat = km / 111;
    const dLng = km / (111 * Math.max(0.2, Math.cos(near[0] * Math.PI / 180)));
    params.push(near[0] - dLat); conditions.push(`p.latitude >= $${params.length}`);
    params.push(near[0] + dLat); conditions.push(`p.latitude <= $${params.length}`);
    params.push(near[1] - dLng); conditions.push(`p.longitude >= $${params.length}`);
    params.push(near[1] + dLng); conditions.push(`p.longitude <= $${params.length}`);
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
  sql += ` ORDER BY CASE WHEN p.status IN ('active', 'pending') THEN 0 ELSE 1 END, p.created_at_ms DESC LIMIT $${params.length}`;

  try {
    let rows = await db.query(sql, params);
    if (hasNear) {
      rows = rows
        .map(r => ({ r, d: matching.haversineKm(near[0], near[1], Number(r.latitude), Number(r.longitude)) }))
        .filter(x => x.d <= km)
        .sort((a, b) => a.d - b.d)
        .map(x => Object.assign(x.r, { distance_km: x.d }));
    }
    const items = rows.map(r => {
      const out = mapPost(r, { lang: req.lang });
      if (hasNear) out.distanceKm = Math.round(r.distance_km * 10) / 10;
      return out;
    });
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
    if (!row || !(await canSee(row, req.userId))) return res.status(404).json({ message: 'Post not found.' });
    res.status(200).json(mapPost(row, { lang: req.lang }));
  } catch (err) {
    console.error('Fetch post error:', err);
    res.status(500).json({ message: 'Error loading post.' });
  }
});

// GET /posts/:id/matches — smart matches for my own post (owner or admin)
router.get('/:id/matches', verifyToken, async (req, res) => {
  try {
    const post = await db.queryOne('SELECT * FROM posts WHERE id = $1', [req.params.id]);
    if (!post) return res.status(404).json({ message: 'Post not found.' });
    if (post.owner_id !== req.userId) {
      const me = await db.queryOne('SELECT is_admin FROM users WHERE uid = $1', [req.userId]);
      if (!me || !truthy(me.is_admin)) return res.status(403).json({ message: 'You do not own this post.' });
    }
    const matches = await matching.findMatches(post, { limit: 10 });
    res.status(200).json(matches.map(m => ({
      ...mapPost(m.row, { lang: req.lang }),
      matchScore: m.score,
      distanceKm: m.distanceKm === null || m.distanceKm === undefined ? null : Math.round(m.distanceKm * 10) / 10,
      matchReasons: m.reasons,
    })));
  } catch (err) {
    console.error('Fetch matches error:', err);
    res.status(500).json({ message: 'Error loading matches.' });
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
    const items = rows.filter(r => !blocked.has(r.owner_id)).slice(0, 6).map(r => mapPost(r, { lang: req.lang }));
    res.status(200).json(items);
  } catch (err) {
    console.error('Fetch similar posts error:', err);
    res.status(500).json({ message: 'Error loading similar posts.' });
  }
});

// POST /posts (Create)
router.post('/', verifyToken, limits.posts, validate(schemas.createPost), async (req, res) => {
  const { title, description, category, isLost, reward, location, imageUrl, lostOn, latitude, longitude } = req.body;

  try {
    const id = crypto.randomUUID();
    const now = Date.now();
    const ownerId = req.userId;

    await db.exec(
      `INSERT INTO posts (id, owner_id, title, description, category, is_lost, reward, location, image_url, lost_on, status, created_at_ms, updated_at_ms, latitude, longitude, translation_status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)`,
      [id, ownerId, title, description, category, bool(!!isLost), reward === undefined || reward === null || reward === '' ? null : String(reward), location, imageUrl || '', lostOn || null, 'pending', now, now, coord(latitude), coord(longitude), 'pending']
    );

    const row = await db.queryOne(`${POST_SELECT} WHERE p.id = $1`, [id]);
    res.status(201).json(mapPost(row, { lang: req.lang }));
    // Translate, pre-check and wake the admins after replying; the AI must never delay the post.
    // Lost/found matching runs once an admin approves the post.
    moderation.processNewPost(id).catch(err => console.error('Review pipeline error:', err.message));
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
    const underReview = post.status === 'pending' || post.status === 'rejected';
    if (underReview && status !== undefined) {
      return res.status(400).json({ message: 'This post is awaiting review.' });
    }
    const contentChanged = ['title', 'description', 'category', 'imageUrl']
      .some(k => k in req.body && String(req.body[k] ?? '') !== String(post[k === 'imageUrl' ? 'image_url' : k] ?? ''));
    // Edits to a rejected post send it back to the queue; edits to a live post keep it live.
    let nextStatus = status !== undefined ? status : post.status;
    if (post.status === 'rejected' && contentChanged) nextStatus = 'pending';
    if (post.status === 'expired' && status === 'active') nextStatus = 'active';
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
        const settings = await getSettings(peer.user_id);
        if (!settings.notify_updates) continue;
        await notify(peer.user_id, {
          title: 'Item returned',
          message: `"${post.title}" has been marked as returned to its owner.`,
          type: 'update',
          data: { type: 'post_resolved', postId: id },
        });
      }
    }

    if (contentChanged) {
      // Fresh translations and, for a resubmission, a fresh pre-check.
      await db.exec(
        `UPDATE posts SET translation_status = 'pending', translation_attempts = 0${nextStatus === 'pending' ? ", rejection_reason = NULL, ai_risk = NULL, ai_reasons = NULL, ai_checked_at_ms = NULL" : ''} WHERE id = $1`,
        [id]
      );
    }

    const row = await db.queryOne(`${POST_SELECT} WHERE p.id = $1`, [id]);
    res.status(200).json(mapPost(row, { lang: req.lang }));
    if (nextStatus === 'pending' && (contentChanged || post.status === 'rejected')) {
      moderation.processNewPost(id).catch(err => console.error('Review pipeline error:', err.message));
      return;
    }
    if (contentChanged) moderation.retranslate(id).catch(err => console.error('Translate error:', err.message));
    const changed = ['title', 'description', 'category', 'location', 'latitude', 'longitude']
      .some(k => k in req.body && String(req.body[k] ?? '') !== String(post[k] ?? ''));
    if (changed && nextStatus === 'active') {
      matching.notifyMatches(row).catch(err => console.error('Match error:', err.message));
    }
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
      const me = await db.queryOne('SELECT is_admin FROM users WHERE uid = $1', [req.userId]);
      const isAdminUser = me && truthy(me.is_admin);
      if (!isAdminUser) return res.status(403).json({ message: 'You do not own this post.' });
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
    const post = await db.queryOne('SELECT id, status FROM posts WHERE id = $1', [id]);
    if (!post || !POST_PUBLIC_STATUSES.includes(post.status || 'active')) return res.status(404).json({ message: 'Post not found.' });

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
