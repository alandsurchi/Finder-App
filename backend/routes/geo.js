// Geocoding for the location picker, proxied over OpenStreetMap's Nominatim.
// The apps never talk to Nominatim directly: this keeps one identifiable
// User-Agent (their usage policy), caches answers and hides the provider so it
// can be swapped later without an app release.
const express = require('express');
const rateLimit = require('express-rate-limit');
const config = require('../config');
const { verifyToken } = require('./auth');

const router = express.Router();

const BASE_URL = (process.env.NOMINATIM_URL || 'https://nominatim.openstreetmap.org').replace(/\/$/, '');
const USER_AGENT = `Finder/1.0 (${config.supportEmail})`;
const CACHE_TTL_MS = 6 * 60 * 60 * 1000;
const CACHE_MAX = 1000;
const cache = new Map();

function fromCache(key) {
  const hit = cache.get(key);
  if (!hit) return null;
  if (Date.now() - hit.at > CACHE_TTL_MS) {
    cache.delete(key);
    return null;
  }
  return hit.value;
}

function remember(key, value) {
  if (cache.size >= CACHE_MAX) cache.delete(cache.keys().next().value);
  cache.set(key, { at: Date.now(), value });
}

async function nominatim(pathname, params, language) {
  const url = new URL(BASE_URL + pathname);
  for (const [k, v] of Object.entries(params)) url.searchParams.set(k, String(v));
  url.searchParams.set('format', 'jsonv2');
  url.searchParams.set('addressdetails', '1');

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 8000);
  try {
    const res = await fetch(url, {
      headers: { 'User-Agent': USER_AGENT, 'Accept-Language': language || 'en' },
      signal: controller.signal,
    });
    if (!res.ok) throw new Error(`Nominatim responded ${res.status}`);
    return await res.json();
  } finally {
    clearTimeout(timer);
  }
}

/** A short, human label: "Street 12, Neighbourhood, City". */
function shortLabel(item) {
  const a = item.address || {};
  const parts = [];
  const street = [a.road || a.pedestrian || a.footway || a.path, a.house_number].filter(Boolean).join(' ');
  const area = a.neighbourhood || a.suburb || a.quarter || a.village || a.hamlet;
  const city = a.city || a.town || a.municipality || a.county || a.state_district;
  for (const p of [street, area, city]) {
    if (p && !parts.includes(p)) parts.push(p);
  }
  if (parts.length === 0 && item.name) parts.push(item.name);
  if (a.country && parts.length < 3 && !parts.includes(a.country)) parts.push(a.country);
  return parts.join(', ');
}

function coordsLabel(lat, lon) {
  return `${Number(lat).toFixed(5)}, ${Number(lon).toFixed(5)}`;
}

function mapPlace(item, fallbackLat, fallbackLon) {
  const lat = Number(item.lat ?? fallbackLat);
  const lon = Number(item.lon ?? fallbackLon);
  const label = shortLabel(item) || item.display_name || coordsLabel(lat, lon);
  return { label, fullLabel: item.display_name || label, latitude: lat, longitude: lon };
}

function language(req) {
  const raw = req.get('accept-language') || 'en';
  return raw.split(',')[0].trim().slice(0, 10) || 'en';
}

router.use(
  verifyToken,
  rateLimit({ windowMs: 60 * 1000, max: 60, standardHeaders: true, legacyHeaders: false,
    message: { message: 'Too many location lookups. Please slow down.' } })
);

// GET /geo/search?q=…  → [{label, fullLabel, latitude, longitude}]
router.get('/search', async (req, res) => {
  const q = String(req.query.q || '').trim().slice(0, 200);
  if (q.length < 2) return res.json([]);
  const lang = language(req);
  const key = `s:${lang}:${q.toLowerCase()}`;
  const cached = fromCache(key);
  if (cached) return res.json(cached);

  try {
    const items = await nominatim('/search', { q, limit: 6 }, lang);
    const places = (Array.isArray(items) ? items : []).map(i => mapPlace(i));
    remember(key, places);
    res.json(places);
  } catch (err) {
    console.error('Geo search error:', err.message);
    res.status(502).json({ message: 'Location search is unavailable right now. Try again in a moment.' });
  }
});

// GET /geo/reverse?lat=…&lon=…  → {label, fullLabel, latitude, longitude}
router.get('/reverse', async (req, res) => {
  const lat = Number(req.query.lat);
  const lon = Number(req.query.lon);
  if (!Number.isFinite(lat) || !Number.isFinite(lon) || Math.abs(lat) > 90 || Math.abs(lon) > 180) {
    return res.status(400).json({ message: 'lat and lon are required.' });
  }
  const lang = language(req);
  const key = `r:${lang}:${lat.toFixed(5)},${lon.toFixed(5)}`;
  const cached = fromCache(key);
  if (cached) return res.json(cached);

  const fallback = { label: coordsLabel(lat, lon), fullLabel: coordsLabel(lat, lon), latitude: lat, longitude: lon };
  try {
    const item = await nominatim('/reverse', { lat, lon, zoom: 18 }, lang);
    const place = item && !item.error ? mapPlace(item, lat, lon) : fallback;
    remember(key, place);
    res.json(place);
  } catch (err) {
    console.error('Geo reverse error:', err.message);
    res.json(fallback);
  }
});

module.exports = router;
