const express = require('express');
const db = require('../db');
const { verifyToken } = require('./auth');
const crypto = require('crypto');

const router = express.Router();

// GET /posts
router.get('/', verifyToken, async (req, res) => {
  const limit = parseInt(req.query.limit) || 20;
  const cursor = req.query.cursor ? parseInt(req.query.cursor) : null;
  const category = req.query.category; // e.g. "All Items", "Lost", "Found"
  
  let sql = 'SELECT * FROM posts';
  const params = [];

  const conditions = [];

  if (cursor !== null) {
    params.push(cursor);
    conditions.push(`created_at_ms < $${params.length}`);
  }

  if (category && category !== 'All Items') {
    const isLost = category === 'Lost';
    params.push(isLost);
    conditions.push(`is_lost = $${params.length}`);
  }

  if (conditions.length > 0) {
    sql += ' WHERE ' + conditions.join(' AND ');
  }

  params.push(limit);
  sql += ` ORDER BY created_at_ms DESC LIMIT $${params.length}`;

  try {
    const posts = await db.query(sql, params);
    
    // Map database fields (e.g. snake_case) to client-side model camelCase
    const items = posts.map(post => ({
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

    const hasMore = items.length === limit;
    const nextCursor = hasMore && items.length > 0 ? items[items.length - 1].createdAtMs.toString() : null;

    res.status(200).json({
      items,
      nextCursor,
      hasMore
    });
  } catch (err) {
    console.error('Fetch posts error:', err);
    res.status(500).json({ message: 'Error loading posts.' });
  }
});

// POST /posts (Create)
router.post('/', verifyToken, async (req, res) => {
  const { title, description, category, isLost, reward, location, imageUrl } = req.body;
  
  if (!title || !description || !category || !location) {
    return res.status(400).json({ message: 'Title, description, category, and location are required.' });
  }

  try {
    const id = crypto.randomUUID();
    const now = Date.now();
    const ownerId = req.userId;

    await db.exec(
      `INSERT INTO posts (id, owner_id, title, description, category, is_lost, reward, location, image_url, status, created_at_ms, updated_at_ms)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
      [id, ownerId, title, description, category, isLost, reward || null, location, imageUrl || '', 'active', now, now]
    );

    res.status(201).json({
      id,
      title,
      description,
      category,
      isLost,
      reward,
      ownerId,
      location,
      imageUrl: imageUrl || '',
      createdAtMs: now,
      updatedAtMs: now,
      status: 'active'
    });
  } catch (err) {
    console.error('Create post error:', err);
    res.status(500).json({ message: 'Error creating post.' });
  }
});

// PUT /posts/:id (Update)
router.put('/:id', verifyToken, async (req, res) => {
  const { id } = req.params;
  const { title, description, category, isLost, reward, location, imageUrl, status } = req.body;

  try {
    // Verify ownership
    const post = await db.queryOne('SELECT * FROM posts WHERE id = $1', [id]);
    if (!post) {
      return res.status(404).json({ message: 'Post not found.' });
    }
    if (post.owner_id !== req.userId) {
      return res.status(403).json({ message: 'You do not own this post.' });
    }

    const now = Date.now();
    await db.exec(
      `UPDATE posts 
       SET title = $1, description = $2, category = $3, is_lost = $4, reward = $5, location = $6, image_url = $7, status = $8, updated_at_ms = $9
       WHERE id = $10`,
      [
        title !== undefined ? title : post.title,
        description !== undefined ? description : post.description,
        category !== undefined ? category : post.category,
        isLost !== undefined ? isLost : post.is_lost,
        reward !== undefined ? reward : post.reward,
        location !== undefined ? location : post.location,
        imageUrl !== undefined ? imageUrl : post.image_url,
        status !== undefined ? status : post.status,
        now,
        id
      ]
    );

    res.status(200).json({
      id,
      title: title !== undefined ? title : post.title,
      description: description !== undefined ? description : post.description,
      category: category !== undefined ? category : post.category,
      isLost: isLost !== undefined ? isLost : !!post.is_lost,
      reward: reward !== undefined ? reward : post.reward,
      ownerId: post.owner_id,
      location: location !== undefined ? location : post.location,
      imageUrl: imageUrl !== undefined ? imageUrl : post.image_url,
      createdAtMs: parseInt(post.created_at_ms),
      updatedAtMs: now,
      status: status !== undefined ? status : post.status
    });
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

    await db.exec('DELETE FROM posts WHERE id = $1', [id]);
    res.status(200).json({ message: 'Post deleted successfully.' });
  } catch (err) {
    console.error('Delete post error:', err);
    res.status(500).json({ message: 'Error deleting post.' });
  }
});

// POST /posts/:id/report (Report a post)
router.post('/:id/report', verifyToken, async (req, res) => {
  const { id } = req.params;
  const { reason } = req.body;

  try {
    const reportId = crypto.randomUUID();
    const now = Date.now();

    await db.exec(
      `INSERT INTO reports (id, post_id, reporter_id, reason, status, created_at_ms)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [reportId, id, req.userId, reason || '', 'pending', now]
    );

    res.status(201).json({ message: 'Report submitted successfully.' });
  } catch (err) {
    console.error('Report post error:', err);
    res.status(500).json({ message: 'Error submitting report.' });
  }
});

module.exports = router;
