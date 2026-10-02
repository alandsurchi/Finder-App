// node --test: app_settings persistence and sealed secrets on a throw-away SQLite file.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');

const tmp = path.join(os.tmpdir(), `finder-settings-${process.pid}.sqlite`);
process.env.SQLITE_PATH = tmp;
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-secret-that-is-long-enough-for-the-tests-123456';
delete process.env.DATABASE_URL;
delete process.env.GEMINI_API_KEY;
delete process.env.OPENAI_API_KEY;
delete process.env.ANTHROPIC_API_KEY;
delete process.env.AI_API_KEY;

const db = require('../db');
const settings = require('../lib/settings');
const ai = require('../lib/ai');

test.before(async () => {
  await db.initDb();
  await settings.load();
});

test.after(async () => {
  try { fs.unlinkSync(tmp); } catch (_) {}
});

test('seal/open round trip, tampering is detected', () => {
  const sealed = settings.seal('sk-super-secret');
  assert.ok(sealed.startsWith('enc:v1:'));
  assert.notEqual(sealed.includes('sk-super-secret'), true);
  assert.equal(settings.open(sealed), 'sk-super-secret');
  assert.equal(settings.open('plain'), 'plain');
  const parts = sealed.split(':');
  parts[4] = Buffer.from('xxxxxxxxxxxx').toString('base64');
  assert.throws(() => settings.open(parts.join(':')));
});

test('setJson stores secrets sealed and survives a reload from the database', async () => {
  assert.equal(ai.aiInfo().configured, false);
  await settings.setJson('ai', { provider: 'openai', model: 'gpt-4o-mini', key: 'sk-test-1234567890', baseUrl: '' }, ['key'], 'admin-1');
  const raw = await db.queryOne('SELECT value, updated_by FROM app_settings WHERE key = $1', ['ai']);
  assert.ok(!raw.value.includes('sk-test-1234567890'));
  assert.equal(raw.updated_by, 'admin-1');

  settings.get('ai'); // cached
  await settings.load(); // simulate a restart
  const info = ai.aiInfo();
  assert.equal(info.configured, true);
  assert.equal(info.source, 'db');
  assert.equal(info.provider, 'openai');
  assert.equal(info.model, 'gpt-4o-mini');
  assert.equal(info.keyHint, '…7890');
  assert.equal(info.updatedBy, 'admin-1');
});

test('clearSettings falls back to the environment, then to nothing', async () => {
  process.env.ANTHROPIC_API_KEY = 'sk-ant-env-key-000000';
  await ai.clearSettings();
  let info = ai.aiInfo();
  assert.equal(info.source, 'env');
  assert.equal(info.provider, 'anthropic');
  assert.equal(info.model, 'claude-haiku-4-5-20251001');
  delete process.env.ANTHROPIC_API_KEY;
  info = ai.aiInfo();
  assert.equal(info.configured, false);
  assert.equal(info.source, 'none');
});

test('setSettings rejects bad input before touching the network', async () => {
  let called = false;
  global.fetch = async () => { called = true; return { ok: true, status: 200, text: async () => '' }; };
  await assert.rejects(ai.setSettings({ provider: 'google', key: 'short' }), /API key/);
  await assert.rejects(ai.setSettings({ provider: 'custom', key: 'a-long-enough-key', model: 'm' }), /base URL/);
  assert.equal(called, false);
  await ai.setSettings({ provider: 'custom', key: 'a-long-enough-key', model: 'llama3', baseUrl: 'http://localhost:11434/v1/' }, 'admin-2');
  assert.equal(called, true);
  const info = ai.aiInfo();
  assert.equal(info.provider, 'custom');
  assert.equal(info.baseUrl, 'http://localhost:11434/v1');
  await ai.clearSettings();
});
