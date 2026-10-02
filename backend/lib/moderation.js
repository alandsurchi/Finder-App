// Post review pipeline: translate, AI pre-check, tell the admins. Runs after
// the HTTP response so a slow model never delays the user. A periodic sweep
// retries what failed and archives posts nobody touched for 90 days.
const fs = require('fs');
const path = require('path');
const db = require('../db');
const config = require('../config');
const ai = require('./ai');
const { notify, displayName, bool, truthy } = require('./helpers');
const { syncAdminFlag } = require('./admin');
const { sniffImage } = require('../routes/uploads');

const SWEEP_EVERY_MS = 5 * 60 * 1000;
const EXPIRE_AFTER_MS = 90 * 86400000;
const MAX_TRANSLATION_ATTEMPTS = 3;

/** Reads the post's own image from disk for the vision check (never fetches over HTTP). */
async function readPostImage(imageUrl) {
  if (!imageUrl) return null;
  let name;
  try { name = path.basename(new URL(imageUrl).pathname); } catch (_) { return null; }
  if (!/^[\w.-]+$/.test(name)) return null;
  const file = path.join(config.uploadsDir, 'posts', name);
  try {
    const buffer = await fs.promises.readFile(file);
    const kind = sniffImage(buffer);
    return kind ? { buffer, mime: kind.mime } : null;
  } catch (_) {
    return null;
  }
}

/** Translate title/description into all three languages and store them. */
async function translate(post) {
  const now = Date.now();
  if (!ai.aiEnabled()) {
    await db.exec(`UPDATE posts SET translation_status = 'skipped' WHERE id = $1`, [post.id]);
    return false;
  }
  const result = await ai.translatePost({ title: post.title, description: post.description });
  if (!result) {
    await db.exec(
      `UPDATE posts SET translation_status = 'failed', translation_attempts = COALESCE(translation_attempts, 0) + 1 WHERE id = $1`,
      [post.id]
    );
    return false;
  }
  await db.exec(
    `UPDATE posts SET source_lang = $1,
       title_en = $2, title_ar = $3, title_ckb = $4,
       description_en = $5, description_ar = $6, description_ckb = $7,
       translation_status = 'done', translation_attempts = COALESCE(translation_attempts, 0) + 1, updated_at_ms = $8
     WHERE id = $9`,
    [result.sourceLang, result.en.title, result.ar.title, result.ckb.title,
      result.en.description, result.ar.description, result.ckb.description, now, post.id]
  );
  return true;
}

/** AI risk score for the admin queue. */
async function moderate(post) {
  const now = Date.now();
  // No AI configured: leave ai_checked_at_ms NULL so the sweeper scores the
  // post once an admin saves a key.
  if (!ai.aiEnabled()) return null;
  const image = await readPostImage(post.image_url);
  const result = await ai.moderatePost({
    title: post.title,
    description: post.description,
    category: post.category,
    isLost: truthy(post.is_lost),
    location: post.location,
    imageBuffer: image ? image.buffer : (post.image_url ? Buffer.alloc(0) : null),
    imageMime: image ? image.mime : (post.image_url ? 'unknown' : null),
  });
  await db.exec(
    'UPDATE posts SET ai_risk = $1, ai_reasons = $2, ai_checked_at_ms = $3 WHERE id = $4',
    [result ? result.risk : null, result ? JSON.stringify(result.reasons) : null, now, post.id]
  );
  return result;
}

async function notifyAdmins(post, risk) {
  try {
    const owner = await db.queryOne('SELECT full_name, nick_name FROM users WHERE uid = $1', [post.owner_id]);
    const users = await db.query('SELECT uid, email, is_admin FROM users');
    for (const u of users) {
      if (u.uid === post.owner_id) continue;
      if (!(await syncAdminFlag(u))) continue;
      await notify(u.uid, {
        title: 'New post to review',
        message: `${displayName(owner)}: "${post.title}"${risk === null || risk === undefined ? '' : ` · risk ${risk}`}`,
        type: 'update',
        data: { type: 'post_review', postId: post.id },
      });
    }
  } catch (err) {
    console.error('Review notify error:', err.message);
  }
}

/** New or resubmitted post: translate, score, then wake the admins once. */
async function processNewPost(postId) {
  const post = await db.queryOne('SELECT * FROM posts WHERE id = $1', [postId]);
  if (!post || post.status !== 'pending') return;
  await translate(post).catch(err => console.error('Translate error:', err.message));
  const result = await moderate(post).catch(err => { console.error('Moderate error:', err.message); return null; });
  await notifyAdmins(post, result ? result.risk : null);
}

/** Owner edited a live post: refresh the translations only. */
async function retranslate(postId) {
  const post = await db.queryOne('SELECT * FROM posts WHERE id = $1', [postId]);
  if (!post) return;
  await translate(post).catch(err => console.error('Translate error:', err.message));
}

/** Posts nobody resolved in 90 days leave the feed; the owner can reopen. */
async function expireOldPosts() {
  const cutoff = Date.now() - EXPIRE_AFTER_MS;
  const rows = await db.query(
    `SELECT id, owner_id, title FROM posts WHERE status = 'active' AND created_at_ms < $1 LIMIT 50`,
    [cutoff]
  );
  for (const p of rows) {
    const now = Date.now();
    await db.exec(`UPDATE posts SET status = 'expired', expired_at_ms = $1, updated_at_ms = $2 WHERE id = $3 AND status = 'active'`, [now, now, p.id]);
    await notify(p.owner_id, {
      title: 'Still looking?',
      message: `"${p.title}" was posted 90 days ago and has been archived. Open it and tap Reopen if it is still relevant.`,
      type: 'update',
      data: { type: 'post_expired', postId: p.id },
    });
  }
  return rows.length;
}

let sweeping = false;
let queued = null;

/** Posts whose translations are missing or failed (and still retryable). */
async function pendingTranslationsCount() {
  const row = await db.queryOne(
    `SELECT COUNT(*) AS n FROM posts
     WHERE (translation_status IS NULL OR translation_status <> 'done')
       AND COALESCE(translation_attempts, 0) < $1
       AND status IN ('pending', 'active', 'resolved')`,
    [MAX_TRANSLATION_ATTEMPTS]
  );
  return Number(row?.n) || 0;
}

/** Posts waiting for an admin that never got an AI score. */
async function unscoredPendingCount() {
  const row = await db.queryOne(`SELECT COUNT(*) AS n FROM posts WHERE status = 'pending' AND ai_risk IS NULL`);
  return Number(row?.n) || 0;
}

/**
 * One pass. `batch` bounds the AI calls per pass; `notify` wakes the admins
 * for posts scored late (off after a key change: they were already told);
 * `minAgeMs` skips posts whose own pipeline may still be running.
 */
async function sweep({ batch = 20, notify: wakeAdmins = true, minAgeMs = 2 * 60 * 1000 } = {}) {
  if (sweeping) return;
  sweeping = true;
  try {
    if (ai.aiEnabled()) {
      // Translations that never ran or failed (old posts, transient errors).
      const todo = await db.query(
        `SELECT * FROM posts
         WHERE (translation_status IS NULL OR translation_status IN ('pending', 'failed', 'skipped'))
           AND COALESCE(translation_attempts, 0) < $1
           AND status IN ('pending', 'active', 'resolved')
         ORDER BY created_at_ms DESC LIMIT $2`,
        [MAX_TRANSLATION_ATTEMPTS, batch]
      );
      for (const post of todo) await translate(post).catch(() => {});
      // Pending posts that never got their AI score (no key at the time, or a
      // restart mid-way).
      const unchecked = await db.query(
        `SELECT * FROM posts WHERE status = 'pending' AND ai_risk IS NULL AND ai_checked_at_ms IS NULL AND created_at_ms < $1 LIMIT $2`,
        [Date.now() - minAgeMs, batch]
      );
      for (const post of unchecked) {
        const result = await moderate(post).catch(() => null);
        if (wakeAdmins) await notifyAdmins(post, result ? result.risk : null);
      }
    }
    await expireOldPosts();
  } catch (err) {
    console.error('Sweep error:', err.message);
  } finally {
    sweeping = false;
  }
}

/**
 * Run a pass right now (after an admin saved AI settings). Failed rows get
 * their attempts back (the old key may have been the problem) and the pass
 * is bigger, so a backlog clears within minutes instead of hours.
 */
async function sweepNow({ afterKeyChange = false } = {}) {
  if (afterKeyChange) {
    await db.exec(`UPDATE posts SET translation_attempts = 0 WHERE translation_status IN ('failed', 'skipped')`);
    await db.exec(`UPDATE posts SET ai_checked_at_ms = NULL WHERE status = 'pending' AND ai_risk IS NULL`);
  }
  // Posts created while no AI was configured finished their pipeline at once,
  // so nothing is in flight: score them regardless of age.
  const opts = afterKeyChange ? { batch: 50, notify: false, minAgeMs: 0 } : { batch: 20 };
  if (sweeping) { queued = opts; return; }
  await sweep(opts);
  while (queued) {
    const next = queued;
    queued = null;
    await sweep(next);
  }
}

function startSweeper() {
  setTimeout(() => sweep().catch(() => {}), 20 * 1000).unref();
  setInterval(() => sweep().catch(() => {}), SWEEP_EVERY_MS).unref();
}

module.exports = { processNewPost, retranslate, expireOldPosts, sweep, sweepNow, startSweeper, readPostImage, pendingTranslationsCount, unscoredPendingCount };
