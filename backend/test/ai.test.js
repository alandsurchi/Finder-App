// node --test: the AI client never throws, parses defensively and speaks each
// provider's dialect. `fetch` is mocked; no network.
const test = require('node:test');
const assert = require('node:assert/strict');

process.env.GEMINI_API_KEY = 'test-key-1234567890abcdefghij';
process.env.NODE_ENV = 'test';
delete process.env.OPENAI_API_KEY;
delete process.env.ANTHROPIC_API_KEY;
delete process.env.AI_API_KEY;
const ai = require('../lib/ai');

const ok = body => ({ status: 200, ok: true, text: async () => '', json: async () => body });
const gemini = (answer, { status = 200, fenced = false } = {}) => {
  const text = fenced ? '```json\n' + JSON.stringify(answer) + '\n```' : JSON.stringify(answer);
  return { status, ok: status >= 200 && status < 300, text: async () => '', json: async () => ({ candidates: [{ content: { parts: [{ text }] } }] }) };
};

test('translatePost keeps the source text, trims and limits the rest', async () => {
  global.fetch = async () => gemini({
    sourceLang: 'ckb',
    en: { title: ' Lost wallet ', description: 'Brown wallet.' },
    ar: { title: 'محفظة', description: 'بنية' },
    ckb: { title: 'IGNORED', description: 'IGNORED' },
  }, { fenced: true });
  const t = await ai.translatePost({ title: 'جزدان', description: 'قاوەیی' });
  assert.equal(t.sourceLang, 'ckb');
  assert.equal(t.ckb.title, 'جزدان');
  assert.equal(t.en.title, 'Lost wallet');
});

test('moderatePost retries once on 503 and flags unchecked images', async () => {
  let calls = 0;
  global.fetch = async () => (++calls === 1 ? gemini({}, { status: 503 }) : gemini({ risk: 12.4, reasons: ['ordinary item'] }));
  const m = await ai.moderatePost({ title: 'x', description: 'y', category: 'Keys', isLost: true, location: '', imageBuffer: Buffer.alloc(1), imageMime: 'image/gif' });
  assert.equal(calls, 2);
  assert.deepEqual(m, { risk: 12, reasons: ['ordinary item', 'image_not_checked'] });
});

test('malformed answers and timeouts resolve to null', async () => {
  global.fetch = async () => gemini({ nope: 1 });
  assert.equal(await ai.moderatePost({ title: 'x', description: 'y', category: 'Keys', isLost: false, location: '' }), null);
  global.fetch = async () => { throw Object.assign(new Error('aborted'), { name: 'AbortError' }); };
  assert.equal(await ai.translatePost({ title: 'a', description: 'b' }), null);
});

test('google request shape: key header, JSON mode, inline image', async () => {
  let seen;
  global.fetch = async (url, init) => { seen = { url, init }; return gemini({ risk: 3, reasons: [] }); };
  await ai.moderatePost({ title: 'x', description: 'y', category: 'Keys', isLost: true, location: '', imageBuffer: Buffer.from('img'), imageMime: 'image/png' });
  assert.match(seen.url, /generativelanguage\.googleapis\.com\/v1beta\/models\/gemini-2\.5-flash-lite:generateContent$/);
  assert.equal(seen.init.headers['x-goog-api-key'], 'test-key-1234567890abcdefghij');
  const body = JSON.parse(seen.init.body);
  assert.equal(body.generationConfig.responseMimeType, 'application/json');
  assert.equal(body.contents[0].parts[1].inlineData.mimeType, 'image/png');
});

test('openai request shape: bearer token, json_object, data-url image', async () => {
  delete process.env.GEMINI_API_KEY;
  process.env.OPENAI_API_KEY = 'sk-openai-test-key-000';
  let seen;
  global.fetch = async (url, init) => { seen = { url, init }; return ok({ choices: [{ message: { content: '{"risk": 50, "reasons": ["ad"]}' } }] }); };
  const m = await ai.moderatePost({ title: 'x', description: 'y', category: 'Keys', isLost: true, location: '', imageBuffer: Buffer.from('img'), imageMime: 'image/jpeg' });
  assert.deepEqual(m, { risk: 50, reasons: ['ad'] });
  assert.equal(seen.url, 'https://api.openai.com/v1/chat/completions');
  assert.equal(seen.init.headers.Authorization, 'Bearer sk-openai-test-key-000');
  const body = JSON.parse(seen.init.body);
  assert.equal(body.model, 'gpt-4o-mini');
  assert.equal(body.response_format.type, 'json_object');
  assert.equal(body.max_completion_tokens, 256);
  assert.match(body.messages[0].content[1].image_url.url, /^data:image\/jpeg;base64,/);
  assert.equal(ai.aiInfo().provider, 'openai');
  delete process.env.OPENAI_API_KEY;
});

test('anthropic request shape: x-api-key, version header, image block first', async () => {
  process.env.ANTHROPIC_API_KEY = 'sk-ant-test-key-000000';
  let seen;
  global.fetch = async (url, init) => { seen = { url, init }; return ok({ content: [{ type: 'text', text: '```json\n{"risk": 7, "reasons": []}\n```' }] }); };
  const m = await ai.moderatePost({ title: 'x', description: 'y', category: 'Keys', isLost: true, location: '', imageBuffer: Buffer.from('img'), imageMime: 'image/webp' });
  assert.deepEqual(m, { risk: 7, reasons: [] });
  assert.equal(seen.url, 'https://api.anthropic.com/v1/messages');
  assert.equal(seen.init.headers['x-api-key'], 'sk-ant-test-key-000000');
  assert.equal(seen.init.headers['anthropic-version'], '2023-06-01');
  const body = JSON.parse(seen.init.body);
  assert.equal(body.model, 'claude-haiku-4-5-20251001');
  assert.equal(body.messages[0].content[0].type, 'image');
  assert.equal(body.messages[0].content[1].type, 'text');
  delete process.env.ANTHROPIC_API_KEY;
});

test('custom provider: base URL from env, retries without response_format on 400', async () => {
  process.env.AI_API_KEY = 'custom-key-000000000';
  process.env.AI_PROVIDER = 'custom';
  process.env.AI_BASE_URL = 'http://localhost:11434/v1/';
  process.env.AI_MODEL = 'llama3';
  const bodies = [];
  global.fetch = async (url, init) => {
    bodies.push({ url, body: JSON.parse(init.body) });
    if (bodies.length === 1) return { status: 400, ok: false, text: async () => 'response_format unsupported', json: async () => ({}) };
    return ok({ choices: [{ message: { content: '{"risk": 1, "reasons": []}' } }] });
  };
  const m = await ai.moderatePost({ title: 'x', description: 'y', category: 'Keys', isLost: true, location: '' });
  assert.deepEqual(m, { risk: 1, reasons: [] });
  assert.equal(bodies.length, 2);
  assert.equal(bodies[0].url, 'http://localhost:11434/v1/chat/completions');
  assert.ok(bodies[0].body.response_format);
  assert.equal(bodies[1].body.response_format, undefined);
  assert.equal(bodies[1].body.max_tokens, 256);
  assert.equal(bodies[1].body.model, 'llama3');
  delete process.env.AI_API_KEY; delete process.env.AI_PROVIDER; delete process.env.AI_BASE_URL; delete process.env.AI_MODEL;
});

test('without a key nothing is called', async () => {
  let called = false;
  global.fetch = async () => { called = true; return ok({}); };
  assert.equal(ai.aiEnabled(), false);
  assert.equal(await ai.translatePost({ title: 'a', description: 'b' }), null);
  assert.equal(called, false);
});
