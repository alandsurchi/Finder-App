const express = require('express');
const http = require('http');
const cors = require('cors');
const db = require('./db');
const { router: authRouter } = require('./routes/auth');
const postsRouter = require('./routes/posts');
const chatsRouter = require('./routes/chats');
const profileRouter = require('./routes/profile');
const notificationsRouter = require('./routes/notifications');
const { initWebSocket } = require('./websocket');

const app = express();
const port = process.env.PORT || 3000;

// Enable CORS
app.use(cors());

// Parse JSON request body
app.use(express.json());

// Routes mapping
app.use('/auth', authRouter);
app.use('/posts', postsRouter);
app.use('/chats', chatsRouter);
app.use('/profile', profileRouter);
app.use('/notifications', notificationsRouter);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', database: db.isPostgres ? 'postgresql' : 'sqlite' });
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
