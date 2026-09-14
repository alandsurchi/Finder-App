const config = require('./config');

const express = require('express');
const http = require('http');
const path = require('path');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const db = require('./db');
const { router: authRouter } = require('./routes/auth');
const postsRouter = require('./routes/posts');
const chatsRouter = require('./routes/chats');
const profileRouter = require('./routes/profile');
const notificationsRouter = require('./routes/notifications');
const usersRouter = require('./routes/users');
const { router: uploadsRouter } = require('./routes/uploads');
const { router: adminRouter } = require('./routes/admin');
const push = require('./lib/push');
const geoRouter = require('./routes/geo');
const { initWebSocket } = require('./websocket');

const app = express();

// Behind Railway/Render/Fly the client IP arrives in X-Forwarded-For.
app.set('trust proxy', 1);
app.disable('x-powered-by');

app.use(helmet({
  // Images under /static are loaded by the app from another origin.
  crossOriginResourcePolicy: { policy: 'cross-origin' },
  contentSecurityPolicy: false,
}));

app.use(cors({
  origin: config.corsOrigins,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 86400,
}));

app.use(express.json({ limit: '1mb' }));

// Request log: method path status ms
app.use((req, res, next) => {
  const started = Date.now();
  res.on('finish', () => {
    console.log(`${req.method} ${req.originalUrl} ${res.statusCode} ${Date.now() - started}ms`);
  });
  next();
});

const limiter = (max, message) => rateLimit({
  windowMs: config.rateLimit.windowMs,
  max,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message },
});

app.use(limiter(config.rateLimit.general, 'Too many requests. Please slow down.'));
const authLimiter = limiter(config.rateLimit.auth, 'Too many sign-in attempts. Try again in 15 minutes.');
const resetLimiter = limiter(config.rateLimit.passwordReset, 'Too many reset requests. Try again later.');

// Demo images, legal pages and any other static assets
app.use('/static', express.static(path.join(__dirname, 'public'), { maxAge: '1d' }));
// User uploads (posts, avatars, chat photos, verification documents)
app.use('/uploads', express.static(config.uploadsDir, { maxAge: '7d', index: false, dotfiles: 'deny' }));
app.get('/legal/:doc(privacy|terms)', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'legal', `${req.params.doc}.html`));
});

// Routes
app.use('/auth/login', authLimiter);
app.use('/auth/signup', authLimiter);
app.use('/auth/google-login', authLimiter);
app.use('/auth/forgot-password', resetLimiter);
app.use('/auth/resend-verification', resetLimiter);
app.use('/auth', authRouter);
app.use('/posts', postsRouter);
app.use('/chats', chatsRouter);
app.use('/profile', profileRouter);
app.use('/notifications', notificationsRouter);
app.use('/users', usersRouter);
app.use('/uploads', uploadsRouter);
app.use('/geo', geoRouter);
app.use('/admin', adminRouter);

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    await db.queryOne('SELECT 1 AS ok');
    res.status(200).json({
      status: 'healthy',
      database: db.isPostgres ? 'postgresql' : 'sqlite',
      uploads: config.uploadsDir,
      push: push.pushConfigured() ? 'fcm' : 'disabled',
    });
  } catch (err) {
    res.status(503).json({ status: 'unhealthy', message: err.message });
  }
});

// 404
app.use((req, res) => {
  res.status(404).json({ message: `Not found: ${req.method} ${req.originalUrl}` });
});

// Error handler
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  if (err && err.type === 'entity.parse.failed') {
    return res.status(400).json({ message: 'Request body is not valid JSON.' });
  }
  console.error('Unhandled error:', err);
  if (res.headersSent) return;
  res.status(err.status || 500).json({
    message: config.isProduction ? 'Internal server error.' : (err.message || 'Internal server error.'),
  });
});

const server = http.createServer(app);
initWebSocket(server);

db.initDb()
  .then(async () => {
    console.log('Database initialized successfully.');

    if (process.env.RUN_MIGRATION === 'true') {
      try {
        const { runMigration } = require('./migrate');
        await runMigration();
      } catch (migErr) {
        console.error('Migration failed on startup:', migErr);
      }
    }

    server.listen(config.port, () => {
      console.log(`Finder backend listening on port ${config.port} (${config.isProduction ? 'production' : 'development'})`);
    });
  })
  .catch((err) => {
    console.error('Failed to initialize database:', err);
    process.exit(1);
  });

function shutdown(signal) {
  console.log(`${signal} received, shutting down.`);
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(0), 5000).unref();
}
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
