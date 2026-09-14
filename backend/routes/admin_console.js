// Admin console: overview, users, posts and reports. Mounted under /admin
// next to the verification routes; requireAdmin guards everything.
const express = require('express');
const db = require('../db');
const { requireAdmin } = require('../lib/admin');
const { notify, displayName, bool, truthy, POST_SELECT, mapPost } = require('../lib/helpers');
const { deleteUserData, deletePostData } = require('../lib/users');
const { validate, schemas } = require('../lib/validate');

const router = express.Router();
router.use(requireAdmin);

function mapUser(row) {
  return {
    uid: row.uid,
    name: displayName(row),
    email: row.email || '',
    avatarUrl: row.avatar_url || '',
    identityVerified: truthy(row.identity_verified),
    isAdmin: truthy(row.is_admin),
    isBanned: truthy(row.is_banned),
    authProvider: row.auth_provider || 'email',
    postsCount: parseInt(row.posts_count) || 0,
    reportsAgainst: parseInt(row.reports_against) || 0,
    createdAtMs: parseInt(row.created_at) || 0,
  };
}

const USER_SELECT = `
  SELECT u.*,
         (SELECT COUNT(*) FROM posts p WHERE p.owner_id = u.uid) AS posts_count,
         (SELECT COUNT(*) FROM reports r JOIN posts p2 ON p2.id = r.post_id WHERE p2.owner_id = u.uid) AS reports_against
  FROM users u`;

// GET /admin/stats
router.get('/stats', async (req, res) => {
  try {
    const one = async (sql, params = []) => parseInt((await db.queryOne(sql, params)).n) || 0;
    res.json({
      users: await one('SELECT COUNT(*) AS n FROM users'),
      bannedUsers: await one('SELECT COUNT(*) AS n FROM users WHERE is_banned = $1', [bool(true)]),
      verifiedUsers: await one('SELECT COUNT(*) AS n FROM users WHERE identity_verified = $1', [bool(true)]),
      posts: await one('SELECT COUNT(*) AS n FROM posts'),
      openPosts: await one("SELECT COUNT(*) AS n FROM posts WHERE status = 'active'"),
      returnedPosts: await one("SELECT COUNT(*) AS n FROM posts WHERE status = 'resolved'"),
      pendingReports: await one("SELECT COUNT(*) AS n FROM reports WHERE status = 'pending'"),
      pendingVerifications: await one("SELECT COUNT(*) AS n FROM verification_requests WHERE status = 'pending'"),
      messagesToday: await one('SELECT COUNT(*) AS n FROM messages WHERE created_at_ms > $1', [Date.now() - 86400000]),
    });
  } catch (err) {
    console.error('Admin stats error:', err);
    res.status(500).json({ message: 'Error loading statistics.' });
  }
});

// GET /admin/users?q=&filter=all|banned|admins|verified
router.get('/users', async (req, res) => {
  const q = String(req.query.q || '').trim().toLowerCase().slice(0, 60);
  const filter = String(req.query.filter || 'all');
  const conditions = [];
  const params = [];
  if (q) {
    params.push(`%${q}%`);
    conditions.push(`(LOWER(u.full_name) LIKE $${params.length} OR LOWER(u.nick_name) LIKE $${params.length} OR LOWER(u.email) LIKE $${params.length})`);
  }
  if (filter === 'banned') { params.push(bool(true)); conditions.push(`u.is_banned = $${params.length}`); }
  if (filter === 'admins') { params.push(bool(true)); conditions.push(`u.is_admin = $${params.length}`); }
  if (filter === 'verified') { params.push(bool(true)); conditions.push(`u.identity_verified = $${params.length}`); }
  try {
    const rows = await db.query(
      `${USER_SELECT}${conditions.length ? ' WHERE ' + conditions.join(' AND ') : ''}
       ORDER BY u.created_at DESC LIMIT 100`,
      params
    );
    res.json(rows.map(mapUser));
  } catch (err) {
    console.error('Admin users error:', err);
    res.status(500).json({ message: 'Error loading users.' });
  }
});

// GET /admin/users/:uid
router.get('/users/:uid', async (req, res) => {
  try {
    const row = await db.queryOne(`${USER_SELECT} WHERE u.uid = $1`, [req.params.uid]);
    if (!row) return res.status(404).json({ message: 'User not found.' });
    res.json(mapUser(row));
  } catch (err) {
    console.error('Admin user error:', err);
    res.status(500).json({ message: 'Error loading the user.' });
  }
});

async function loadTarget(req, res) {
  const row = await db.queryOne('SELECT * FROM users WHERE uid = $1', [req.params.uid]);
  if (!row) {
    res.status(404).json({ message: 'User not found.' });
    return null;
  }
  return row;
}

// POST /admin/users/:uid/ban { banned: true|false }
router.post('/users/:uid/ban', validate(schemas.adminFlag), async (req, res) => {
  const banned = req.body.value === true;
  try {
    const target = await loadTarget(req, res);
    if (!target) return;
    if (target.uid === req.userId) return res.status(400).json({ message: 'You cannot suspend your own account.' });
    if (truthy(target.is_admin) && banned) return res.status(400).json({ message: 'Remove the admin role before suspending this account.' });
    await db.exec('UPDATE users SET is_banned = $1 WHERE uid = $2', [bool(banned), target.uid]);
    if (banned) {
      // A suspended account must not keep receiving pushes.
      await db.exec('DELETE FROM device_tokens WHERE user_id = $1', [target.uid]);
    }
    res.json({ uid: target.uid, isBanned: banned });
  } catch (err) {
    console.error('Admin ban error:', err);
    res.status(500).json({ message: 'Could not update the account.' });
  }
});

// POST /admin/users/:uid/verify { value: true|false }
router.post('/users/:uid/verify', validate(schemas.adminFlag), async (req, res) => {
  const verified = req.body.value === true;
  try {
    const target = await loadTarget(req, res);
    if (!target) return;
    await db.exec('UPDATE users SET identity_verified = $1 WHERE uid = $2', [bool(verified), target.uid]);
    if (!verified) {
      await db.exec(`UPDATE verification_requests SET status = 'rejected', rejection_reason = 'Verification was removed by an administrator.', reviewed_at_ms = $1, reviewer_id = $2 WHERE user_id = $3 AND status = 'approved'`, [Date.now(), req.userId, target.uid]);
    }
    await notify(target.uid, {
      title: verified ? 'Identity verified' : 'Verification removed',
      message: verified
        ? 'An administrator verified your identity. The badge now shows on your profile and posts.'
        : 'Your verified badge was removed by an administrator. You can submit new documents from Get verified.',
      type: 'update',
      data: { type: 'verification', status: verified ? 'approved' : 'rejected' },
    });
    res.json({ uid: target.uid, identityVerified: verified });
  } catch (err) {
    console.error('Admin verify error:', err);
    res.status(500).json({ message: 'Could not update the account.' });
  }
});

// POST /admin/users/:uid/admin { value: true|false }
router.post('/users/:uid/admin', validate(schemas.adminFlag), async (req, res) => {
  const admin = req.body.value === true;
  try {
    const target = await loadTarget(req, res);
    if (!target) return;
    if (target.uid === req.userId && !admin) return res.status(400).json({ message: 'You cannot remove your own admin role.' });
    await db.exec('UPDATE users SET is_admin = $1 WHERE uid = $2', [bool(admin), target.uid]);
    if (admin) await db.exec('UPDATE users SET is_banned = $1 WHERE uid = $2', [bool(false), target.uid]);
    await notify(target.uid, {
      title: admin ? 'You are now an administrator' : 'Admin role removed',
      message: admin
        ? 'Open Profile → Admin console to review users, posts and reports.'
        : 'Your administrator access to Finder was removed.',
      type: 'system',
      push: admin,
    });
    res.json({ uid: target.uid, isAdmin: admin });
  } catch (err) {
    console.error('Admin role error:', err);
    res.status(500).json({ message: 'Could not update the account.' });
  }
});

// DELETE /admin/users/:uid
router.delete('/users/:uid', async (req, res) => {
  try {
    const target = await loadTarget(req, res);
    if (!target) return;
    if (target.uid === req.userId) return res.status(400).json({ message: 'You cannot delete your own account here.' });
    if (truthy(target.is_admin)) return res.status(400).json({ message: 'Remove the admin role before deleting this account.' });
    await deleteUserData(target.uid);
    console.log(`[ADMIN] ${req.adminUser.email} deleted account ${target.email}`);
    res.json({ message: 'Account deleted.' });
  } catch (err) {
    console.error('Admin delete user error:', err);
    res.status(500).json({ message: 'Could not delete the account.' });
  }
});

// GET /admin/posts?q=&status=all|active|resolved|reported
router.get('/posts', async (req, res) => {
  const q = String(req.query.q || '').trim().toLowerCase().slice(0, 60);
  const status = String(req.query.status || 'all');
  const conditions = [];
  const params = [];
  if (q) {
    params.push(`%${q}%`);
    conditions.push(`(LOWER(p.title) LIKE $${params.length} OR LOWER(p.description) LIKE $${params.length} OR LOWER(u.full_name) LIKE $${params.length} OR LOWER(u.email) LIKE $${params.length})`);
  }
  if (status === 'active' || status === 'resolved') { params.push(status); conditions.push(`p.status = $${params.length}`); }
  if (status === 'reported') conditions.push(`p.id IN (SELECT post_id FROM reports WHERE status = 'pending')`);
  try {
    const rows = await db.query(
      `${POST_SELECT}${conditions.length ? ' WHERE ' + conditions.join(' AND ') : ''}
       ORDER BY p.created_at_ms DESC LIMIT 100`,
      params
    );
    res.json(rows.map(mapPost));
  } catch (err) {
    console.error('Admin posts error:', err);
    res.status(500).json({ message: 'Error loading posts.' });
  }
});

// POST /admin/posts/:id/status { status: active|resolved }
router.post('/posts/:id/status', validate(schemas.adminPostStatus), async (req, res) => {
  try {
    const post = await db.queryOne('SELECT * FROM posts WHERE id = $1', [req.params.id]);
    if (!post) return res.status(404).json({ message: 'Post not found.' });
    await db.exec('UPDATE posts SET status = $1, updated_at_ms = $2 WHERE id = $3', [req.body.status, Date.now(), post.id]);
    const row = await db.queryOne(`${POST_SELECT} WHERE p.id = $1`, [post.id]);
    res.json(mapPost(row));
  } catch (err) {
    console.error('Admin post status error:', err);
    res.status(500).json({ message: 'Could not update the post.' });
  }
});

// DELETE /admin/posts/:id  { reason? }
router.delete('/posts/:id', async (req, res) => {
  try {
    const post = await db.queryOne('SELECT * FROM posts WHERE id = $1', [req.params.id]);
    if (!post) return res.status(404).json({ message: 'Post not found.' });
    const reason = String((req.body && req.body.reason) || '').trim().slice(0, 300);
    await deletePostData(post.id);
    await notify(post.owner_id, {
      title: 'Your post was removed',
      message: `"${post.title}" was removed by a moderator${reason ? `: ${reason}` : '.'}`,
      type: 'update',
    });
    console.log(`[ADMIN] ${req.adminUser.email} deleted post ${post.id}`);
    res.json({ message: 'Post deleted.' });
  } catch (err) {
    console.error('Admin delete post error:', err);
    res.status(500).json({ message: 'Could not delete the post.' });
  }
});

// GET /admin/reports?status=pending|resolved|all
router.get('/reports', async (req, res) => {
  const status = String(req.query.status || 'pending');
  const params = [];
  let where = '';
  if (status === 'pending' || status === 'resolved') { params.push(status); where = ` WHERE r.status = $1`; }
  try {
    const rows = await db.query(
      `SELECT r.*, p.title AS post_title, p.owner_id AS post_owner_id, p.status AS post_status,
              rep.full_name AS reporter_full_name, rep.nick_name AS reporter_nick_name, rep.email AS reporter_email,
              own.full_name AS owner_full_name, own.nick_name AS owner_nick_name
       FROM reports r
       LEFT JOIN posts p ON p.id = r.post_id
       LEFT JOIN users rep ON rep.uid = r.reporter_id
       LEFT JOIN users own ON own.uid = p.owner_id${where}
       ORDER BY r.created_at_ms DESC LIMIT 200`,
      params
    );
    res.json(rows.map(r => ({
      id: r.id,
      postId: r.post_id || '',
      postTitle: r.post_title || '(post deleted)',
      postStatus: r.post_status || '',
      postOwnerId: r.post_owner_id || '',
      postOwnerName: r.owner_full_name || r.owner_nick_name || '',
      reporterId: r.reporter_id || '',
      reporterName: r.reporter_full_name || r.reporter_nick_name || 'Finder User',
      reporterEmail: r.reporter_email || '',
      reason: r.reason || '',
      status: r.status || 'pending',
      createdAtMs: parseInt(r.created_at_ms) || 0,
      reviewedAtMs: r.reviewed_at_ms ? parseInt(r.reviewed_at_ms) : null,
      resolution: r.resolution || null,
    })));
  } catch (err) {
    console.error('Admin reports error:', err);
    res.status(500).json({ message: 'Error loading reports.' });
  }
});

// POST /admin/reports/:id/resolve { action: dismiss|remove_post }
router.post('/reports/:id/resolve', validate(schemas.adminResolveReport), async (req, res) => {
  const { action } = req.body;
  try {
    const report = await db.queryOne('SELECT * FROM reports WHERE id = $1', [req.params.id]);
    if (!report) return res.status(404).json({ message: 'Report not found.' });
    const now = Date.now();
    if (action === 'remove_post' && report.post_id) {
      const post = await db.queryOne('SELECT * FROM posts WHERE id = $1', [report.post_id]);
      if (post) {
        // Every report on this post is settled by removing it.
        await db.exec(`UPDATE reports SET status = 'resolved', resolution = 'removed', reviewed_at_ms = $1, reviewer_id = $2 WHERE post_id = $3`, [now, req.userId, post.id]);
        await deletePostData(post.id);
        await notify(post.owner_id, {
          title: 'Your post was removed',
          message: `"${post.title}" was removed after a report was reviewed by a moderator.`,
          type: 'update',
        });
        // deletePostData already removed the reports rows, so nothing more to update.
        return res.json({ id: report.id, status: 'resolved', resolution: 'removed' });
      }
    }
    await db.exec(`UPDATE reports SET status = 'resolved', resolution = 'dismissed', reviewed_at_ms = $1, reviewer_id = $2 WHERE id = $3`, [now, req.userId, report.id]);
    res.json({ id: report.id, status: 'resolved', resolution: 'dismissed' });
  } catch (err) {
    console.error('Admin resolve report error:', err);
    res.status(500).json({ message: 'Could not resolve the report.' });
  }
});

module.exports = { router };
