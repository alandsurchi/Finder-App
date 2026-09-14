// Admin review of identity verification requests.
//
// Documents and selfies live under config.privateDir (never served as static
// files); admins fetch them through /admin/verification/:id/file/:slot with
// their token, the owner through /profile/verification/file/:slot.
const express = require('express');
const path = require('path');
const fs = require('fs');
const db = require('../db');
const config = require('../config');
const { requireAdmin } = require('../lib/admin');
const { notify, displayName, bool } = require('../lib/helpers');
const { validate, schemas } = require('../lib/validate');

const router = express.Router();
router.use(requireAdmin);

const SLOTS = { front: 'front_url', back: 'back_url', selfie: 'selfie_url' };
const STATUSES = ['pending', 'approved', 'rejected'];

function mapRequest(row) {
  return {
    id: row.id,
    userId: row.user_id,
    userName: displayName(row),
    email: row.email || '',
    avatarUrl: row.avatar_url || '',
    docType: row.doc_type,
    status: row.status,
    hasBack: !!row.back_url,
    createdAtMs: parseInt(row.created_at_ms),
    reviewedAtMs: row.reviewed_at_ms ? parseInt(row.reviewed_at_ms) : null,
    rejectionReason: row.rejection_reason || null,
  };
}

const SELECT = `
  SELECT v.*, u.email, u.full_name, u.nick_name, u.avatar_url
  FROM verification_requests v
  LEFT JOIN users u ON u.uid = v.user_id`;

// GET /admin/verification?status=pending|approved|rejected|all
router.get('/verification', async (req, res) => {
  const status = String(req.query.status || 'pending');
  try {
    const rows = STATUSES.includes(status)
      ? await db.query(`${SELECT} WHERE v.status = $1 ORDER BY v.created_at_ms DESC LIMIT 200`, [status])
      : await db.query(`${SELECT} ORDER BY v.created_at_ms DESC LIMIT 200`);
    res.json(rows.map(mapRequest));
  } catch (err) {
    console.error('Admin list verification error:', err);
    res.status(500).json({ message: 'Error loading verification requests.' });
  }
});

// GET /admin/verification/:id
router.get('/verification/:id', async (req, res) => {
  try {
    const row = await db.queryOne(`${SELECT} WHERE v.id = $1`, [req.params.id]);
    if (!row) return res.status(404).json({ message: 'Request not found.' });
    res.json(mapRequest(row));
  } catch (err) {
    console.error('Admin get verification error:', err);
    res.status(500).json({ message: 'Error loading the request.' });
  }
});

// GET /admin/verification/:id/file/:slot  (front | back | selfie)
router.get('/verification/:id/file/:slot', async (req, res) => {
  const column = SLOTS[req.params.slot];
  if (!column) return res.status(400).json({ message: 'slot must be front, back or selfie.' });
  try {
    const row = await db.queryOne('SELECT * FROM verification_requests WHERE id = $1', [req.params.id]);
    if (!row) return res.status(404).json({ message: 'Request not found.' });
    sendVerificationFile(res, row[column]);
  } catch (err) {
    console.error('Admin verification file error:', err);
    res.status(500).json({ message: 'Error loading the file.' });
  }
});

/** Streams a stored verification image, or redirects to a legacy URL. */
function sendVerificationFile(res, value) {
  if (!value) return res.status(404).json({ message: 'No file for this slot.' });
  if (/^https?:\/\//i.test(value)) return res.redirect(value);
  const name = path.basename(value);
  const dir = path.join(config.privateDir, 'verification');
  if (!fs.existsSync(path.join(dir, name))) {
    return res.status(404).json({ message: 'File no longer exists.' });
  }
  res.sendFile(name, { root: dir, headers: { 'Cache-Control': 'private, max-age=300' } });
}

async function loadPending(req, res) {
  const row = await db.queryOne('SELECT * FROM verification_requests WHERE id = $1', [req.params.id]);
  if (!row) {
    res.status(404).json({ message: 'Request not found.' });
    return null;
  }
  if (row.status !== 'pending') {
    res.status(409).json({ message: `This request was already ${row.status}.` });
    return null;
  }
  return row;
}

// POST /admin/verification/:id/approve
router.post('/verification/:id/approve', async (req, res) => {
  try {
    const row = await loadPending(req, res);
    if (!row) return;
    const now = Date.now();
    await db.exec(
      `UPDATE verification_requests SET status = 'approved', reviewed_at_ms = $1, reviewer_id = $2, rejection_reason = NULL WHERE id = $3`,
      [now, req.userId, row.id]
    );
    await db.exec('UPDATE users SET identity_verified = $1 WHERE uid = $2', [bool(true), row.user_id]);
    await notify(row.user_id, {
      title: 'Identity verified',
      message: 'Your ID was reviewed and approved. The verified badge now shows on your profile and posts.',
      type: 'update',
      data: { type: 'verification', status: 'approved' },
    });
    res.json({ id: row.id, status: 'approved', reviewedAtMs: now });
  } catch (err) {
    console.error('Admin approve error:', err);
    res.status(500).json({ message: 'Could not approve the request.' });
  }
});

// POST /admin/verification/:id/reject  { reason }
router.post('/verification/:id/reject', validate(schemas.rejectVerification), async (req, res) => {
  const { reason } = req.body;
  try {
    const row = await loadPending(req, res);
    if (!row) return;
    const now = Date.now();
    await db.exec(
      `UPDATE verification_requests SET status = 'rejected', reviewed_at_ms = $1, reviewer_id = $2, rejection_reason = $3 WHERE id = $4`,
      [now, req.userId, reason, row.id]
    );
    await notify(row.user_id, {
      title: 'Verification not approved',
      message: `Your ID could not be verified: ${reason} You can submit new photos from Get verified.`,
      type: 'update',
      data: { type: 'verification', status: 'rejected' },
    });
    res.json({ id: row.id, status: 'rejected', reviewedAtMs: now, rejectionReason: reason });
  } catch (err) {
    console.error('Admin reject error:', err);
    res.status(500).json({ message: 'Could not reject the request.' });
  }
});

module.exports = { router, sendVerificationFile };
