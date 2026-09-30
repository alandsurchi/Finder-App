const express = require('express');
const db = require('../db');
const config = require('../config');
const { truthy } = require('../lib/helpers');

/**
 * Public share pages. No auth: anyone who receives a link sees a small preview
 * of the post (title, status, image, place, excerpt) and an "Open in Finder"
 * button. Owner contact details are never included.
 */
const router = express.Router();

const esc = (s) => String(s ?? '')
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;').replace(/'/g, '&#39;');

const excerpt = (s, n) => {
  const t = String(s || '').replace(/\s+/g, ' ').trim();
  return t.length > n ? `${t.slice(0, n - 1).trimEnd()}…` : t;
};

function page({ title, description, image, url, body, status = 200 }) {
  return { status, html: `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(title)} · Finder</title>
<meta name="description" content="${esc(description)}">
<meta property="og:type" content="article">
<meta property="og:site_name" content="Finder">
<meta property="og:title" content="${esc(title)}">
<meta property="og:description" content="${esc(description)}">
${image ? `<meta property="og:image" content="${esc(image)}">\n<meta name="twitter:card" content="summary_large_image">` : '<meta name="twitter:card" content="summary">'}
<meta property="og:url" content="${esc(url)}">
<meta name="twitter:title" content="${esc(title)}">
<meta name="twitter:description" content="${esc(description)}">
<style>
  :root { color-scheme: light dark; --bg:#F6F5F1; --fg:#17201F; --muted:#5E6866; --card:#FFFFFF; --line:#E2E5E3; --primary:#0B6E6A; --lost:#C2410C; --found:#0B6E6A; }
  @media (prefers-color-scheme: dark) { :root { --bg:#0F1413; --fg:#E6EBEA; --muted:#9AA6A4; --card:#182120; --line:#25302E; --primary:#4FC3BD; --found:#4FC3BD; --lost:#F59E7B; } }
  * { box-sizing: border-box; }
  body { margin:0; font: 16px/1.55 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; background: var(--bg); color: var(--fg); }
  main { max-width: 560px; margin: 0 auto; padding: 24px 16px 64px; }
  .brand { display:flex; align-items:center; gap:10px; color: var(--primary); font-weight: 700; letter-spacing: .2px; margin-bottom: 20px; }
  .brand svg { width: 26px; height: 26px; }
  .card { background: var(--card); border: 1px solid var(--line); border-radius: 20px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,.06); }
  .img { width: 100%; aspect-ratio: 4/3; object-fit: cover; display:block; background: var(--line); }
  .noimg { width:100%; aspect-ratio: 4/3; display:flex; align-items:center; justify-content:center; color: var(--muted); background: linear-gradient(135deg, var(--line), var(--card)); }
  .body { padding: 18px 18px 20px; }
  .badge { display:inline-block; font-size: 12px; font-weight: 700; letter-spacing: .6px; padding: 4px 10px; border-radius: 999px; color: #fff; }
  .lost { background: var(--lost); } .found { background: var(--found); } .returned { background: var(--muted); }
  h1 { font-size: 1.45rem; margin: 10px 0 6px; line-height: 1.25; }
  .meta { color: var(--muted); font-size: .95rem; margin: 0 0 12px; }
  p.desc { margin: 0 0 18px; white-space: pre-line; }
  .btn { display:block; text-align:center; text-decoration:none; font-weight:600; padding: 14px 18px; border-radius: 14px; }
  .primary { background: var(--primary); color: #fff; }
  .ghost { color: var(--primary); margin-top: 8px; }
  footer { color: var(--muted); font-size: .85rem; text-align:center; margin-top: 24px; }
</style>
</head>
<body>
<main>
  <div class="brand"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="3"/><path d="M12 3v3M12 18v3M3 12h3M18 12h3"/></svg>Finder</div>
  ${body}
  <footer>Finder helps people report lost and found items and get them back to their owners.</footer>
</main>
</body>
</html>` };
}

function notFound(url) {
  return page({
    title: 'Post not available', description: 'This post is no longer available on Finder.', url, status: 404,
    body: `<div class="card"><div class="body"><h1>This post is no longer available</h1><p class="meta">It may have been removed by its owner.</p><a class="btn primary" href="finder://home">Open Finder</a></div></div>`,
  });
}

async function loadPost(id) {
  if (!/^[A-Za-z0-9-]{8,64}$/.test(id)) return null;
  const row = await db.queryOne(
    `SELECT p.*, u.is_banned AS owner_banned FROM posts p LEFT JOIN users u ON u.uid = p.owner_id WHERE p.id = $1`,
    [id]
  );
  if (!row || truthy(row.owner_banned)) return null;
  return row;
}

// GET /p/:id — public preview of a post (Open Graph friendly)
router.get('/:id', async (req, res) => {
  const base = config.publicUrl || `${req.protocol}://${req.get('host')}`;
  const url = `${base}/p/${encodeURIComponent(req.params.id)}`;
  try {
    const row = await loadPost(req.params.id);
    if (!row) {
      const p = notFound(url);
      return res.status(p.status).type('html').send(p.html);
    }
    const isLost = truthy(row.is_lost);
    const returned = row.status === 'resolved';
    const kind = returned ? 'returned' : (isLost ? 'lost' : 'found');
    const label = returned ? 'RETURNED' : (isLost ? 'LOST' : 'FOUND');
    const title = `${isLost ? 'Lost' : 'Found'}: ${row.title}`;
    const description = excerpt(`${row.location ? `${row.location} · ` : ''}${row.description}`, 180);
    const image = row.image_url || '';
    const appLink = `finder://post/${encodeURIComponent(row.id)}`;
    const body = `
  <div class="card">
    ${image ? `<img class="img" src="${esc(image)}" alt="${esc(row.title)}">` : `<div class="noimg">No photo</div>`}
    <div class="body">
      <span class="badge ${kind}">${label}</span>
      <h1>${esc(row.title)}</h1>
      <p class="meta">${esc(row.location || '')}${row.lost_on ? ` · ${esc(row.lost_on)}` : ''}${row.category ? ` · ${esc(row.category)}` : ''}</p>
      <p class="desc">${esc(excerpt(row.description, 600))}</p>
      <a class="btn primary" href="${appLink}">Open in Finder</a>
      <a class="btn ghost" href="${appLink}">Don't have the app yet? Ask the sender for the Finder app.</a>
    </div>
  </div>`;
    const p = page({ title, description, image, url, body });
    res.set('Cache-Control', 'public, max-age=300');
    res.status(200).type('html').send(p.html);
  } catch (err) {
    console.error('Share page error:', err);
    res.status(500).type('html').send('<h1>Something went wrong</h1>');
  }
});

/** Android App Links: lets https://<host>/p/... open the app without a chooser. */
function assetLinks() {
  const prints = config.androidCertSha256;
  if (!prints.length) return [];
  return [{
    relation: ['delegate_permission/common.handle_all_urls'],
    target: { namespace: 'android_app', package_name: 'com.finderapp.finder', sha256_cert_fingerprints: prints },
  }];
}

/** iOS universal links (needs the paid Apple team id; empty until then). */
function appleAssociation() {
  const team = config.appleTeamId;
  if (!team) return { applinks: { apps: [], details: [] } };
  return {
    applinks: { apps: [], details: [{ appID: `${team}.com.finderapp.finder`, paths: ['/p/*'] }] },
  };
}

module.exports = { router, assetLinks, appleAssociation };
