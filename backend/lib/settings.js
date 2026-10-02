// Server-wide settings stored in the database (`app_settings`), so they
// survive redeploys on hosts without a persistent disk. Values marked secret
// are sealed with AES-256-GCM under a key derived from JWT_SECRET: a database
// dump alone does not reveal API keys.
//
// `load()` runs once at boot; afterwards `get()` is synchronous from the cache
// and every `set()`/`remove()` writes through and refreshes the cache.
const crypto = require('crypto');
const db = require('../db');
const config = require('../config');

const cache = new Map();
let loaded = false;

function sealKey() {
  return crypto.createHash('sha256').update(String(config.jwtSecret)).digest();
}

/** `enc:v1:<iv>:<tag>:<ciphertext>` (all base64). */
function seal(plain) {
  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv('aes-256-gcm', sealKey(), iv);
  const data = Buffer.concat([cipher.update(String(plain), 'utf8'), cipher.final()]);
  return `enc:v1:${iv.toString('base64')}:${cipher.getAuthTag().toString('base64')}:${data.toString('base64')}`;
}

function open(sealed) {
  const s = String(sealed || '');
  if (!s.startsWith('enc:v1:')) return s;
  const [, , iv, tag, data] = s.split(':');
  const decipher = crypto.createDecipheriv('aes-256-gcm', sealKey(), Buffer.from(iv, 'base64'));
  decipher.setAuthTag(Buffer.from(tag, 'base64'));
  return Buffer.concat([decipher.update(Buffer.from(data, 'base64')), decipher.final()]).toString('utf8');
}

async function load() {
  const rows = await db.query('SELECT key, value, updated_at_ms, updated_by FROM app_settings');
  cache.clear();
  for (const r of rows) cache.set(r.key, { value: r.value, updatedAtMs: Number(r.updated_at_ms) || 0, updatedBy: r.updated_by || null });
  loaded = true;
  return cache.size;
}

function isLoaded() { return loaded; }

/** Raw stored string (sealed values stay sealed) or null. */
function get(key) {
  const row = cache.get(key);
  return row ? row.value : null;
}

function meta(key) {
  const row = cache.get(key);
  return row ? { updatedAtMs: row.updatedAtMs, updatedBy: row.updatedBy } : null;
}

/** JSON value; fields listed in `secretFields` are unsealed on read. */
function getJson(key, secretFields = []) {
  const raw = get(key);
  if (!raw) return null;
  try {
    const obj = JSON.parse(raw);
    for (const f of secretFields) {
      if (typeof obj[f] === 'string') {
        try { obj[f] = open(obj[f]); } catch (_) { obj[f] = ''; }
      }
    }
    return obj;
  } catch (_) {
    return null;
  }
}

async function set(key, value, by = null) {
  const now = Date.now();
  const existing = await db.queryOne('SELECT key FROM app_settings WHERE key = $1', [key]);
  if (existing) {
    await db.exec('UPDATE app_settings SET value = $1, updated_at_ms = $2, updated_by = $3 WHERE key = $4', [value, now, by, key]);
  } else {
    await db.exec('INSERT INTO app_settings (key, value, updated_at_ms, updated_by) VALUES ($1, $2, $3, $4)', [key, value, now, by]);
  }
  cache.set(key, { value, updatedAtMs: now, updatedBy: by });
}

async function setJson(key, obj, secretFields = [], by = null) {
  const copy = { ...obj };
  for (const f of secretFields) if (typeof copy[f] === 'string' && copy[f]) copy[f] = seal(copy[f]);
  await set(key, JSON.stringify(copy), by);
}

async function remove(key) {
  await db.exec('DELETE FROM app_settings WHERE key = $1', [key]);
  cache.delete(key);
}

module.exports = { load, isLoaded, get, getJson, set, setJson, remove, meta, seal, open };
