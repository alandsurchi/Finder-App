// node --test: the Gemini client never throws and parses defensively.
const test = require('node:test');
const assert = require('node:assert/strict');

process.env.GEMINI_API_KEY = 'test-key-1234567890abcdefghij';
process.env.NODE_ENV = 'test';
const ai = require('../lib/ai');

function respond(answer, { status = 200, fenced = false } = {}) {
  const text = fenced ? '```json\n' + JSON.stringify(answer) + '\n```' : JSON.stringify(answer);
  return { status, ok: status >= 200 && status < 300, text: async () => '', json: async () => ({ candidates: [{ content: { parts: [{ text }] } }] }) };
}

test('translatePost keeps the source text, trims and limits the rest', async () => {
  global.fetch = async () => respond({
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
  global.fetch = async () => (++calls === 1 ? respond({}, { status: 503 }) : respond({ risk: 12.4, reasons: ['ordinary item'] }));
  const m = await ai.moderatePost({ title: 'x', description: 'y', category: 'Keys', isLost: true, location: '', imageBuffer: Buffer.alloc(1), imageMime: 'image/gif' });
  assert.equal(calls, 2);
  assert.deepEqual(m, { risk: 12, reasons: ['ordinary item', 'image_not_checked'] });
});

test('malformed answers and timeouts resolve to null', async () => {
  global.fetch = async () => respond({ nope: 1 });
  assert.equal(await ai.moderatePost({ title: 'x', description: 'y', category: 'Keys', isLost: false, location: '' }), null);
  global.fetch = async () => { throw Object.assign(new Error('aborted'), { name: 'AbortError' }); };
  assert.equal(await ai.translatePost({ title: 'a', description: 'b' }), null);
});

test('without a key nothing is called', async () => {
  const saved = process.env.GEMINI_API_KEY;
  process.env.GEMINI_API_KEY = '';
  let called = false;
  global.fetch = async () => { called = true; return respond({}); };
  assert.equal(ai.aiEnabled(), false);
  assert.equal(await ai.translatePost({ title: 'a', description: 'b' }), null);
  assert.equal(called, false);
  process.env.GEMINI_API_KEY = saved;
});
