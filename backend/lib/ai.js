// AI client for post translation and the moderation pre-check. Works with
// any of four providers: Google AI Studio (Gemini), OpenAI, Anthropic, or a
// custom OpenAI-compatible server (OpenRouter, Groq, DeepSeek, Mistral,
// Ollama…). Every public function resolves to null on any failure so callers
// never block a user action on the AI.
//
// Settings lookup order (sync, from the settings cache loaded at boot):
//   1. `app_settings['ai']` saved by an admin through POST /admin/ai (sealed key)
//   2. environment: GEMINI_API_KEY / OPENAI_API_KEY / ANTHROPIC_API_KEY /
//      AI_API_KEY (+ AI_PROVIDER, AI_MODEL, AI_BASE_URL)
//   3. the legacy `gemini-key.json` file, migrated into the database on boot.
const fs = require('fs');
const path = require('path');
const { z } = require('zod');
const config = require('../config');
const settings = require('./settings');

const LANGS = ['en', 'ar', 'ckb'];
const SETTINGS_KEY = 'ai';
const LEGACY_KEY_FILE = path.join(config.privateDir, 'gemini-key.json');

const PROVIDERS = {
  google: { label: 'Google AI Studio', defaultModel: 'gemini-2.5-flash-lite', baseUrl: 'https://generativelanguage.googleapis.com/v1beta' },
  openai: { label: 'OpenAI', defaultModel: 'gpt-4o-mini', baseUrl: 'https://api.openai.com/v1' },
  anthropic: { label: 'Anthropic', defaultModel: 'claude-haiku-4-5-20251001', baseUrl: 'https://api.anthropic.com/v1' },
  custom: { label: 'OpenAI-compatible', defaultModel: '', baseUrl: '' },
};
const PROVIDER_IDS = Object.keys(PROVIDERS);

// ── Settings ───────────────────────────────────────────────────────────────

function readLegacyFile() {
  try {
    const parsed = JSON.parse(fs.readFileSync(LEGACY_KEY_FILE, 'utf8'));
    return parsed && typeof parsed.key === 'string' ? parsed.key.trim() : '';
  } catch (_) {
    return '';
  }
}

function normalize(input) {
  const provider = PROVIDER_IDS.includes(input.provider) ? input.provider : 'google';
  const def = PROVIDERS[provider];
  const model = String(input.model || '').trim() || def.defaultModel;
  const baseUrl = String(input.baseUrl || '').trim().replace(/\/+$/, '') || def.baseUrl;
  return { provider, model, baseUrl, key: String(input.key || '').trim() };
}

function fromEnv() {
  const env = process.env;
  const model = (env.AI_MODEL || env.GEMINI_MODEL || '').trim();
  const baseUrl = (env.AI_BASE_URL || '').trim();
  const pick = (name, provider) => ((env[name] || '').trim()
    ? normalize({ provider, key: env[name], model, baseUrl })
    : null);
  if ((env.AI_API_KEY || '').trim() && PROVIDER_IDS.includes(env.AI_PROVIDER)) return pick('AI_API_KEY', env.AI_PROVIDER);
  return pick('GEMINI_API_KEY', 'google') || pick('OPENAI_API_KEY', 'openai') || pick('ANTHROPIC_API_KEY', 'anthropic');
}

/** The active settings and where they came from. Never null. */
function current() {
  const saved = settings.getJson(SETTINGS_KEY, ['key']);
  if (saved && saved.key) return { ...normalize(saved), source: 'db' };
  const env = fromEnv();
  if (env) return { ...env, source: 'env' };
  const legacy = readLegacyFile();
  if (legacy) return { ...normalize({ provider: 'google', key: legacy }), source: 'file' };
  return { ...normalize({ provider: 'google' }), key: '', source: 'none' };
}

/** Boot: move a legacy key file into the database so it survives redeploys. */
async function init() {
  if (settings.getJson(SETTINGS_KEY, ['key'])) return;
  const legacy = readLegacyFile();
  if (!legacy) return;
  try {
    await settings.setJson(SETTINGS_KEY, normalize({ provider: 'google', key: legacy }), ['key'], 'migration');
    console.log('AI: migrated the Gemini key file into app_settings');
  } catch (err) {
    console.error('AI: could not migrate the key file:', err.message);
  }
}

function aiEnabled() {
  return !!current().key && config.ai.enabled;
}

/** Status for the admin console; never returns the key itself. */
function aiInfo() {
  const s = current();
  const meta = s.source === 'db' ? settings.meta(SETTINGS_KEY) : null;
  return {
    configured: !!s.key,
    enabled: aiEnabled(),
    provider: s.provider,
    providerLabel: PROVIDERS[s.provider].label,
    model: s.model,
    baseUrl: s.provider === 'custom' ? s.baseUrl : '',
    source: s.source,
    keyHint: s.key ? `…${s.key.slice(-4)}` : '',
    updatedAtMs: meta ? meta.updatedAtMs : null,
    updatedBy: meta ? meta.updatedBy : null,
    providers: PROVIDER_IDS.map(id => ({ id, label: PROVIDERS[id].label, defaultModel: PROVIDERS[id].defaultModel })),
  };
}

/** Admin saved new settings: validate, test them once, store sealed. */
async function setSettings(input, by = null) {
  const s = normalize(input);
  if (!/^[\x21-\x7E]{10,400}$/.test(s.key)) throw new Error('That does not look like an API key.');
  if (!s.model) throw new Error('A model name is required.');
  if (s.provider === 'custom' && !/^https?:\/\/\S+$/i.test(s.baseUrl)) throw new Error('A base URL is required for a custom provider.');
  await verify(s);
  await settings.setJson(SETTINGS_KEY, s, ['key'], by);
  return aiInfo();
}

async function clearSettings() {
  await settings.remove(SETTINGS_KEY);
  return aiInfo();
}

/** One cheap request; throws a human-readable error when the key or model is wrong. */
async function verify(s) {
  const label = PROVIDERS[s.provider].label;
  let res;
  try {
    if (s.provider === 'google') {
      res = await fetch(`${s.baseUrl}/models/${encodeURIComponent(s.model)}`, {
        headers: { 'x-goog-api-key': s.key },
        signal: AbortSignal.timeout(8000),
      });
    } else if (s.provider === 'anthropic') {
      res = await fetch(`${s.baseUrl}/messages`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'x-api-key': s.key, 'anthropic-version': '2023-06-01' },
        body: JSON.stringify({ model: s.model, max_tokens: 1, messages: [{ role: 'user', content: 'ping' }] }),
        signal: AbortSignal.timeout(10000),
      });
    } else {
      const limit = s.provider === 'openai' ? { max_completion_tokens: 1 } : { max_tokens: 1 };
      res = await fetch(`${s.baseUrl}/chat/completions`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${s.key}` },
        body: JSON.stringify({ model: s.model, messages: [{ role: 'user', content: 'ping' }], ...limit }),
        signal: AbortSignal.timeout(10000),
      });
    }
  } catch (_) {
    throw new Error(`Could not reach ${label}.`);
  }
  if (res.ok) return true;
  const text = await res.text().catch(() => '');
  if (res.status === 401 || res.status === 403) throw new Error(`${label} rejected the key.`);
  if (res.status === 404 || (/model/i.test(text) && /not (found|exist|supported)|unknown|invalid model/i.test(text))) {
    throw new Error('Model not found.');
  }
  if (res.status === 400 && s.provider === 'google') throw new Error(`${label} rejected the key.`);
  if (res.status === 429) return true; // quota exhausted, but the key and model are valid
  throw new Error(`${label} responded ${res.status}.`);
}

// ── Low-level call ─────────────────────────────────────────────────────────

const RETRY = { retry: true };

/**
 * One JSON-answer request to the active provider. Retries once on
 * 429/5xx/timeout. Returns the parsed JSON (validated by `schema`) or null.
 * `image` is `{buffer, mime}` or null.
 */
async function generate({ text, image, schema, maxOutputTokens, label }) {
  const s = current();
  if (!s.key || !config.ai.enabled) return null;

  for (let attempt = 0; attempt < 2; attempt++) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), config.ai.timeoutMs);
    try {
      const answer = await callProvider(s, { text, image, maxOutputTokens, signal: controller.signal });
      const parsed = schema.safeParse(JSON.parse(stripFences(answer)));
      if (!parsed.success) {
        console.error(`AI ${label}: unexpected answer shape: ${parsed.error.issues[0]?.message}`);
        return null;
      }
      return parsed.data;
    } catch (err) {
      const retry = err.retry || err.name === 'AbortError' || err.name === 'TimeoutError';
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

function callProvider(s, req) {
  if (s.provider === 'google') return callGoogle(s, req);
  if (s.provider === 'anthropic') return callAnthropic(s, req);
  return callOpenAi(s, req);
}

async function fail(res, s) {
  const label = PROVIDERS[s.provider].label;
  if (res.status === 429 || res.status >= 500) throw Object.assign(new Error(`${label} responded ${res.status}`), RETRY);
  const text = await res.text().catch(() => '');
  throw new Error(`${label} responded ${res.status} ${text.slice(0, 200)}`);
}

async function callGoogle(s, { text, image, maxOutputTokens, signal }) {
  const parts = [{ text }];
  if (image) parts.push({ inlineData: { mimeType: image.mime, data: image.buffer.toString('base64') } });
  const res = await fetch(`${s.baseUrl}/models/${encodeURIComponent(s.model)}:generateContent`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'x-goog-api-key': s.key },
    body: JSON.stringify({
      contents: [{ role: 'user', parts }],
      generationConfig: { temperature: 0, responseMimeType: 'application/json', maxOutputTokens },
    }),
    signal,
  });
  if (!res.ok) await fail(res, s);
  const json = await res.json();
  return json?.candidates?.[0]?.content?.parts?.map(p => p.text || '').join('') || '';
}

async function callOpenAi(s, { text, image, maxOutputTokens, signal }) {
  const content = [{ type: 'text', text }];
  if (image) content.push({ type: 'image_url', image_url: { url: `data:${image.mime};base64,${image.buffer.toString('base64')}` } });
  const base = {
    model: s.model,
    messages: [{ role: 'user', content }],
    // Newer OpenAI models reject max_tokens/temperature; compatible servers often lack the new names.
    ...(s.provider === 'openai' ? { max_completion_tokens: maxOutputTokens } : { max_tokens: maxOutputTokens, temperature: 0 }),
  };
  const send = body => fetch(`${s.baseUrl}/chat/completions`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${s.key}` },
    body: JSON.stringify(body),
    signal,
  });
  let res = await send({ ...base, response_format: { type: 'json_object' } });
  // Some compatible servers reject response_format; the prompt already demands JSON.
  if (res.status === 400 && s.provider === 'custom') res = await send(base);
  if (!res.ok) await fail(res, s);
  const json = await res.json();
  const msg = json?.choices?.[0]?.message?.content;
  return Array.isArray(msg) ? msg.map(p => p.text || '').join('') : (msg || '');
}

async function callAnthropic(s, { text, image, maxOutputTokens, signal }) {
  const content = [];
  if (image) content.push({ type: 'image', source: { type: 'base64', media_type: image.mime, data: image.buffer.toString('base64') } });
  content.push({ type: 'text', text });
  const res = await fetch(`${s.baseUrl}/messages`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'x-api-key': s.key, 'anthropic-version': '2023-06-01' },
    body: JSON.stringify({ model: s.model, max_tokens: maxOutputTokens, temperature: 0, messages: [{ role: 'user', content }] }),
    signal,
  });
  if (!res.ok) await fail(res, s);
  const json = await res.json();
  return (json?.content || []).map(p => p.text || '').join('');
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
    text: `${TRANSLATE_PROMPT}\n\nTITLE: ${title}\nDESCRIPTION: ${description}`,
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
  let image = null;
  let imageSkipped = false;
  if (imageBuffer && imageMime && ['image/jpeg', 'image/png', 'image/webp'].includes(imageMime) && imageBuffer.length <= 4 * 1024 * 1024) {
    image = { buffer: imageBuffer, mime: imageMime };
  } else if (imageBuffer || imageMime) {
    imageSkipped = true;
  }
  const result = await generate({
    label: 'moderate',
    schema: moderationSchema,
    maxOutputTokens: 256,
    image,
    text: `${MODERATE_PROMPT}\n\nTYPE: ${isLost ? 'lost' : 'found'}\nCATEGORY: ${category}\nLOCATION: ${location || ''}\nTITLE: ${title}\nDESCRIPTION: ${description}`,
  });
  if (!result) return null;
  const reasons = result.reasons.map(r => r.trim()).filter(Boolean);
  if (imageSkipped) reasons.push('image_not_checked');
  return { risk: Math.round(result.risk), reasons: reasons.slice(0, 6) };
}

module.exports = { init, aiEnabled, aiInfo, setSettings, clearSettings, translatePost, moderatePost, LANGS, PROVIDERS };
