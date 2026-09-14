// Central runtime configuration. Loaded once; fails fast on unsafe production settings.
require('./env').loadEnv();
const path = require('path');

const isProduction = process.env.NODE_ENV === 'production';
const DEV_JWT_SECRET = 'finder_dev_secret_do_not_use_in_production';

function readJwtSecret() {
  const secret = process.env.JWT_SECRET;
  if (secret && secret.length >= 32) return secret;
  if (isProduction) {
    console.error(
      'FATAL: JWT_SECRET must be set to a random string of at least 32 characters in production.\n' +
      '       Generate one with: node -e "console.log(require(\'crypto\').randomBytes(48).toString(\'hex\'))"'
    );
    process.exit(1);
  }
  if (secret) {
    console.warn('WARNING: JWT_SECRET is shorter than 32 characters; fine for development only.');
    return secret;
  }
  console.warn('WARNING: JWT_SECRET not set; using the development secret. Never do this in production.');
  return DEV_JWT_SECRET;
}

function readCorsOrigins() {
  const raw = (process.env.CORS_ORIGINS || '').trim();
  if (!raw) {
    if (isProduction) {
      console.warn('WARNING: CORS_ORIGINS not set; the API will only accept same-origin browser requests.');
      return [];
    }
    return '*';
  }
  if (raw === '*') return '*';
  return raw.split(',').map(s => s.trim()).filter(Boolean);
}

function readServiceAccount() {
  const raw = (process.env.FIREBASE_SERVICE_ACCOUNT || '').trim();
  if (!raw) return null;
  try {
    const json = raw.startsWith('{') ? raw : Buffer.from(raw, 'base64').toString('utf8');
    const parsed = JSON.parse(json);
    if (!parsed.project_id || !parsed.private_key) throw new Error('missing project_id/private_key');
    return parsed;
  } catch (err) {
    console.error('FIREBASE_SERVICE_ACCOUNT is not valid service-account JSON (base64 or raw):', err.message);
    return null;
  }
}

const config = {
  isProduction,
  port: parseInt(process.env.PORT, 10) || 3001,
  jwtSecret: readJwtSecret(),
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '30d',
  corsOrigins: readCorsOrigins(),
  publicUrl: (process.env.PUBLIC_URL || '').replace(/\/$/, ''),
  // Where uploaded images live. Mount a persistent volume here in production.
  uploadsDir: path.resolve(process.env.UPLOADS_DIR || path.join(__dirname, 'uploads')),
  rateLimit: {
    windowMs: 15 * 60 * 1000,
    general: parseInt(process.env.RATE_LIMIT_GENERAL, 10) || 600,
    auth: parseInt(process.env.RATE_LIMIT_AUTH, 10) || 30,
    passwordReset: parseInt(process.env.RATE_LIMIT_RESET, 10) || 5,
  },
  supportEmail: process.env.SUPPORT_EMAIL || 'support@finder.app',
  // OAuth client ids whose Google ID tokens the API accepts (comma separated).
  // The Web client id is the audience for both the web app and Android
  // (Android passes it as serverClientId).
  // E-mail addresses that get the admin role (verification review queue).
  adminEmails: (process.env.ADMIN_EMAILS || '')
    .split(',').map(s => s.trim().toLowerCase()).filter(Boolean),
  // Firebase Cloud Messaging service account (base64 JSON). Null disables push.
  firebaseServiceAccount: readServiceAccount(),
  // Files that must never be served publicly (identity documents, selfies).
  privateDir: path.resolve(process.env.PRIVATE_DIR || path.join(process.env.UPLOADS_DIR ? path.dirname(path.resolve(process.env.UPLOADS_DIR)) : __dirname, 'private')),
  googleClientIds: (process.env.GOOGLE_CLIENT_IDS || '209379285612-tbfoc97sjf1p4c5lv3kvmoaub3n0a8h5.apps.googleusercontent.com')
    .split(',').map(s => s.trim()).filter(Boolean),
};

module.exports = config;
