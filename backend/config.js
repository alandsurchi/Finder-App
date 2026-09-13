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
};

module.exports = config;
