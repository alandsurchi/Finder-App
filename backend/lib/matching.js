const db = require('../db');
const { POST_SELECT, bool, truthy, notify, getSettings, isBlocked } = require('./helpers');

/**
 * Smart matching between Lost and Found posts.
 *
 * A match needs the same category and then enough signal: shared words in
 * the titles, shared words in the descriptions, a nearby location, or dates
 * that line up. Scores are additive so a very close location can make up for
 * a vague title and vice versa.
 */

const STOP = new Set(('a an the and or of in on at to for with my our your his her their its is was were be been ' +
  'lost found item items please help near around this that these those from by it i me we you he she they ' +
  'have has had not no yes very some any one two black white blue red green grey gray brown new old').split(' '));

function tokens(text) {
  return new Set(String(text || '')
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s]/gu, ' ')
    .split(/\s+/)
    .filter(w => w.length >= 3 && !STOP.has(w)));
}

function overlap(a, b) {
  let n = 0;
  for (const w of a) if (b.has(w)) n++;
  return n;
}

function haversineKm(lat1, lon1, lat2, lon2) {
  const toRad = d => (d * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
}

function num(v) {
  return v === null || v === undefined ? null : Number(v);
}

function daysBetween(a, b) {
  const da = Date.parse(a);
  const dbb = Date.parse(b);
  if (!Number.isFinite(da) || !Number.isFinite(dbb)) return null;
  return Math.abs(da - dbb) / 86400000;
}

/** Returns { score, distanceKm } for two post rows, or null when they cannot match. */
function scoreMatch(a, b) {
  if (!a || !b || a.category !== b.category) return null;
  if (truthy(a.is_lost) === truthy(b.is_lost)) return null;

  let score = 0;
  const reasons = [];

  const titleHits = overlap(tokens(a.title), tokens(b.title));
  if (titleHits) { score += 3 * titleHits; reasons.push('title'); }

  const descHits = Math.min(5, overlap(tokens(`${a.title} ${a.description}`), tokens(`${b.title} ${b.description}`)) - titleHits);
  if (descHits > 0) { score += descHits; reasons.push('description'); }

  let distanceKm = null;
  const [la1, lo1, la2, lo2] = [num(a.latitude), num(a.longitude), num(b.latitude), num(b.longitude)];
  if ([la1, lo1, la2, lo2].every(v => Number.isFinite(v))) {
    distanceKm = haversineKm(la1, lo1, la2, lo2);
    if (distanceKm <= 5) { score += 2; reasons.push('nearby'); }
    else if (distanceKm <= 25) { score += 1; reasons.push('area'); }
    else if (distanceKm > 100) score -= 2;
  }

  if (overlap(tokens(a.location), tokens(b.location))) { score += 1; reasons.push('place'); }

  const days = daysBetween(a.lost_on, b.lost_on);
  if (days !== null && days <= 14) { score += 1; reasons.push('date'); }

  return { score, distanceKm, reasons };
}

const THRESHOLD = 3;

/** Candidate posts of the opposite kind in the same category, newest first. */
async function candidatesFor(post) {
  const since = Date.now() - 90 * 86400000;
  return db.query(
    `${POST_SELECT}
     WHERE p.category = $1 AND p.is_lost = $2 AND p.status = 'active'
       AND p.owner_id != $3 AND p.id != $4 AND p.created_at_ms >= $5
       AND p.owner_id NOT IN (SELECT blocked_user_id FROM blocked_users WHERE user_id = $6)
       AND p.owner_id NOT IN (SELECT user_id FROM blocked_users WHERE blocked_user_id = $7)
       AND COALESCE(u.is_banned, ${db.isPostgres ? 'FALSE' : '0'}) = ${db.isPostgres ? 'FALSE' : '0'}
     ORDER BY p.created_at_ms DESC
     LIMIT 400`,
    [post.category, bool(!truthy(post.is_lost)), post.owner_id, post.id, since, post.owner_id, post.owner_id]
  );
}

/** Scored matches for a post row, best first. Each entry is { row, score, distanceKm, reasons }. */
async function findMatches(post, { limit = 10 } = {}) {
  const rows = await candidatesFor(post);
  const out = [];
  for (const row of rows) {
    const s = scoreMatch(post, row);
    if (s && s.score >= THRESHOLD) out.push({ row, ...s });
  }
  out.sort((x, y) => y.score - x.score || y.row.created_at_ms - x.row.created_at_ms);
  return out.slice(0, limit);
}

function describe(match, post) {
  const parts = [`"${post.title}"`];
  if (match.distanceKm !== null && match.distanceKm !== undefined) {
    parts.push(match.distanceKm < 1 ? 'less than 1 km away' : `about ${Math.round(match.distanceKm)} km away`);
  } else if (post.location) {
    parts.push(post.location);
  }
  return parts.join(' · ');
}

/**
 * Records new matches for `post` and notifies the people involved. Safe to
 * call again after an edit: pairs already in post_matches are skipped.
 */
async function notifyMatches(post) {
  const matches = await findMatches(post);
  if (!matches.length) return 0;
  const now = Date.now();
  let fresh = 0;
  let best = null;

  for (const m of matches) {
    const other = m.row;
    const seen = await db.queryOne(
      'SELECT 1 AS hit FROM post_matches WHERE (post_id = $1 AND matched_post_id = $2) OR (post_id = $3 AND matched_post_id = $4)',
      [post.id, other.id, other.id, post.id]
    );
    if (seen) continue;
    await db.exec(
      'INSERT INTO post_matches (post_id, matched_post_id, score, created_at_ms) VALUES ($1, $2, $3, $4)',
      [post.id, other.id, m.score, now]
    );
    fresh++;
    if (!best) best = m;

    if (await isBlocked(post.owner_id, other.owner_id)) continue;
    const settings = await getSettings(other.owner_id);
    if (!settings.notify_matches) continue;
    const postIsLost = truthy(post.is_lost);
    await notify(other.owner_id, {
      title: postIsLost ? 'Someone lost an item like the one you found' : 'A found item may match what you lost',
      message: describe(m, post),
      type: 'match',
      data: { type: 'match', postId: post.id, myPostId: other.id },
    });
  }

  if (fresh > 0) {
    const settings = await getSettings(post.owner_id);
    if (settings.notify_matches && best) {
      const postIsLost = truthy(post.is_lost);
      await notify(post.owner_id, {
        title: fresh === 1 ? '1 possible match for your post' : `${fresh} possible matches for your post`,
        message: postIsLost
          ? `"${best.row.title}" was reported found${best.distanceKm != null ? ` about ${Math.max(1, Math.round(best.distanceKm))} km away` : ''}. Take a look.`
          : `"${best.row.title}" was reported lost${best.distanceKm != null ? ` about ${Math.max(1, Math.round(best.distanceKm))} km away` : ''}. Take a look.`,
        type: 'match',
        data: { type: 'match', postId: best.row.id, myPostId: post.id },
      });
    }
  }
  return fresh;
}

module.exports = { tokens, scoreMatch, findMatches, notifyMatches, haversineKm, THRESHOLD };
