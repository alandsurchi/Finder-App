require('./env').loadEnv();

const express = require('express');
const http = require('http');
const path = require('path');
const cors = require('cors');
const db = require('./db');
const { router: authRouter } = require('./routes/auth');
const postsRouter = require('./routes/posts');
const chatsRouter = require('./routes/chats');
const profileRouter = require('./routes/profile');
const notificationsRouter = require('./routes/notifications');
const usersRouter = require('./routes/users');
const { initWebSocket } = require('./websocket');

const app = express();
const port = process.env.PORT || 3001;

// Enable CORS
app.use(cors());

// Parse JSON request body
app.use(express.json({ limit: '2mb' }));

// Request log: method path status ms
app.use((req, res, next) => {
  const started = Date.now();
  res.on('finish', () => {
    console.log(`${req.method} ${req.originalUrl} ${res.statusCode} ${Date.now() - started}ms`);
  });
  next();
});

// Demo images and any other static assets
app.use('/static', express.static(path.join(__dirname, 'public'), { maxAge: '1d' }));

// Routes mapping
app.use('/auth', authRouter);
app.use('/posts', postsRouter);
app.use('/chats', chatsRouter);
app.use('/profile', profileRouter);
app.use('/notifications', notificationsRouter);
app.use('/users', usersRouter);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', database: db.isPostgres ? 'postgresql' : 'sqlite' });
});

// 404
app.use((req, res) => {
  res.status(404).json({ message: `Not found: ${req.method} ${req.originalUrl}` });
});

// Error handler
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  if (res.headersSent) return;
  res.status(err.status || 500).json({ message: err.message || 'Internal server error.' });
});

// Create HTTP server
const server = http.createServer(app);

// Initialize WebSockets
initWebSocket(server);

// Initialize DB and start server
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

    server.listen(port, () => {
      console.log(`Finder custom backend server running on port ${port}`);
    });
  })
  .catch((err) => {
    console.error('Failed to initialize database:', err);
    process.exit(1);
  });
