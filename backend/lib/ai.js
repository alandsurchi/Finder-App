// Gemini (Google AI Studio) client for post translation and the moderation
// pre-check. Every public function resolves to null on any failure so the
// callers never block a user action on the AI: posting works without a key,
// without network and when the model answers nonsense.
//
// Key lookup order: GEMINI_API_KEY env var, then the file an admin saved
// through POST /admin/ai-key (config.privateDir/gemini-key.json).
const fs = require('fs');
const path = require('path');
const { z } = require('zod');
const config = require('../config');

const KEY_FILE = path.join(config.privateDir, 'gemini-key.json');
const ENDPOINT = 'https://generativelanguage.googleapis.com/v1beta/models';
const LANGS = ['en', 'ar', 'ckb'];

let fileKey = null;
try {
  const parsed = JSON.parse(fs.readFileSync(KEY_FILE, 'utf8'));
  if (parsed && typeof parsed.key === 'string') fileKey = parsed.key.trim();
} catch (_) { /* no stored key */ }

function apiKey() {
  return (process.env.GEMINI_API_KEY || '').trim() || fileKey || '';
}

function aiEnabled() {
  return !!apiKey() && config.gemini.enabled;
}

/** Status for the admin console; never returns the key itself. */
function aiInfo() {
  const key = apiKey();
  return {
    configured: !!key,
    enabled: aiEnabled(),
    source: (process.env.GEMINI_API_KEY || '').trim() ? 'env' : (fileKey ? 'file' : 'none'),
    model: config.gemini.model,
    keyHint: key ? `…${key.slice(-4)}` : '',
  };
}

/** Stores a key an admin pasted in the console. A quick test call validates it. */
async function setApiKey(key) {
  const clean = String(key || '').trim();
  if (!/^[A-Za-z0-9_-]{20,200}$/.test(clean)) throw new Error('That does not look like a Google AI Studio key.');
  const ok = await ping(clean);
  if (!ok) throw new Error('Google AI Studio rejected the key.');
  await fs.promises.mkdir(path.dirname(KEY_FILE), { recursive: true });
  await fs.promises.writeFile(KEY_FILE, JSON.stringify({ key: clean, savedAtMs: Date.now() }), { mode: 0o600 });
  fileKey = clean;
  return true;
}

async function ping(key) {
  try {
    const res = await fetch(`${ENDPOINT}/${config.gemini.model}?key=${encodeURIComponent(key)}`, {
      signal: AbortSignal.timeout(8000),
    });
    return res.ok;
  } catch (_) {
    return false;
  }
}

// ── Low-level call ─────────────────────────────────────────────────────────

/**
 * One generateContent call with JSON output. Retries once on 429/5xx/timeout.
 * Returns the parsed JSON (validated by `schema`) or null.
 */
async function generate({ parts, schema, maxOutputTokens, label }) {
  const key = apiKey();
  if (!key || !config.gemini.enabled) return null;
  const url = `${ENDPOINT}/${config.gemini.model}:generateContent`;
  const body = JSON.stringify({
    contents: [{ role: 'user', parts }],
    generationConfig: {
      temperature: 0,
      responseMimeType: 'application/json',
      maxOutputTokens,
    },
  });

  for (let attempt = 0; attempt < 2; attempt++) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), config.gemini.timeoutMs);
    try {
      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'x-goog-api-key': key },
        body,
        signal: controller.signal,
      });
      if (res.status === 429 || res.status >= 500) {
        throw Object.assign(new Error(`Gemini responded ${res.status}`), { retry: true });
      }
      if (!res.ok) {
        const text = await res.text().catch(() => '');
        console.error(`AI ${label}: Gemini responded ${res.status} ${text.slice(0, 200)}`);
        return null;
      }
      const json = await res.json();
      const text = json?.candidates?.[0]?.content?.parts?.map(p => p.text || '').join('') || '';
      const parsed = schema.safeParse(JSON.parse(stripFences(text)));
      if (!parsed.success) {
        console.error(`AI ${label}: unexpected answer shape: ${parsed.error.issues[0]?.message}`);
        return null;
      }
      return parsed.data;
    } catch (err) {
      const retry = err.retry || err.name === 'AbortError';
      if (retry && attempt === 0) {
        await new Promise(r => setTimeout(r, 1500));
        continue;
      }
      console.error(`AI ${label}: ${err.message}`);
      return null;
    } finally {
      clearTimeout(timer);
    }
  }
  return null;
}

function stripFences(text) {
  return String(text).trim().replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '');
}

// ── Translation ────────────────────────────────────────────────────────────

const translationSchema = z.object({
  sourceLang: z.enum(['en', 'ar', 'ckb', 'other']),
  en: z.object({ title: z.string(), description: z.string() }),
  ar: z.object({ title: z.string(), description: z.string() }),
  ckb: z.object({ title: z.string(), description: z.string() }),
});

const TRANSLATE_PROMPT = `You translate lost-and-found posts for an app used in Iraq and Kurdistan.
Detect the language of the TITLE and DESCRIPTION: "en" = English, "ar" = Arabic, "ckb" = Central Kurdish (Sorani, Arabic script), "other" = anything else.
Produce faithful, natural translations into English, Arabic and Sorani Kurdish. Keep names, phone numbers, brands, model numbers, plate numbers, addresses and emojis unchanged. Do not add or remove information. Do not add quotation marks. For the source language return the original text unchanged. Keep each title under 120 characters and each description under 2000 characters.
Answer with JSON only, exactly this shape:
{"sourceLang":"en|ar|ckb|other","en":{"title":"","description":""},"ar":{"title":"","description":""},"ckb":{"title":"","description":""}}`;

/**
 * Detects the language and translates into the other two.
 * Resolves { sourceLang, en, ar, ckb } or null.
 */
async function translatePost({ title, description }) {
  const result = await generate({
    label: 'translate',
    schema: translationSchema,
    maxOutputTokens: 2048,
    parts: [{ text: `${TRANSLATE_PROMPT}\n\nTITLE: ${title}\nDESCRIPTION: ${description}` }],
  });
  if (!result) return null;
  // Belt and braces: the source language keeps the exact original text.
  if (LANGS.includes(result.sourceLang)) result[result.sourceLang] = { title, description };
  for (const l of LANGS) {
    result[l].title = result[l].title.trim().slice(0, 120) || title;
    result[l].description = result[l].description.trim().slice(0, 2000) || description;
  }
  return result;
}

// ── Moderation ─────────────────────────────────────────────────────────────

const moderationSchema = z.object({
  risk: z.number().min(0).max(100),
  reasons: z.array(z.string().max(80)).max(6),
});

const MODERATE_PROMPT = `You are the pre-check for a human moderator of a lost-and-found app used in Iraq and Kurdistan. Posts may be in English, Arabic or Kurdish.
Rate how likely this post should NOT be published: 0 = clearly fine, 100 = certainly reject.
Reject-worthy: scams or asking the owner for money before returning an item, selling goods, advertising, spam or gibberish, hate or harassment, sexual content, weapons or drugs, personal data of third parties (ID cards, bank cards, passports of other people), content unrelated to lost or found items, an image that is explicit, violent, or clearly unrelated to the text.
Fine: ordinary lost or found descriptions, a reward offered by the owner, the poster's own contact details, photos of the item or the place.
Give at most 6 short, concrete reasons in English (each under 60 characters). Mention the image when it drives the score.
Answer with JSON only: {"risk": 0-100, "reasons": ["..."]}`;

/**
 * Scores a post. `imageBuffer`/`imageMime` are optional; unsupported or large
 * images are skipped and reported as a reason. Resolves { risk, reasons } or null.
 */
async function moderatePost({ title, description, category, isLost, location, imageBuffer, imageMime }) {
  const parts = [{
    text: `${MODERATE_PROMPT}\n\nTYPE: ${isLost ? 'lost' : 'found'}\nCATEGORY: ${category}\nLOCATION: ${location || ''}\nTITLE: ${title}\nDESCRIPTION: ${description}`,
  }];
  let imageSkipped = false;
  if (imageBuffer && imageMime && ['image/jpeg', 'image/png', 'image/webp'].includes(imageMime) && imageBuffer.length <= 4 * 1024 * 1024) {
    parts.push({ inlineData: { mimeType: imageMime, data: imageBuffer.toString('base64') } });
  } else if (imageBuffer || imageMime) {
    imageSkipped = true;
  }
  const result = await generate({ label: 'moderate', schema: moderationSchema, maxOutputTokens: 256, parts });
  if (!result) return null;
  const reasons = result.reasons.map(r => r.trim()).filter(Boolean);
  if (imageSkipped) reasons.push('image_not_checked');
  return { risk: Math.round(result.risk), reasons: reasons.slice(0, 6) };
}

module.exports = { aiEnabled, aiInfo, setApiKey, translatePost, moderatePost, LANGS };
