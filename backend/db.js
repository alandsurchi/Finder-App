const { Pool } = require('pg');
const path = require('path');

const databaseUrl = process.env.DATABASE_URL;
const isPostgres = !!databaseUrl;

let pgPool = null;
let sqliteDb = null;

if (isPostgres) {
  console.log('Connecting to PostgreSQL database at:', databaseUrl);
  const useSsl = databaseUrl.includes('sslmode=disable') ? false : { rejectUnauthorized: false };
  pgPool = new Pool({
    connectionString: databaseUrl,
    ssl: useSsl
  });
} else {
  const sqlite3 = require('sqlite3').verbose();
  const dbPath = path.resolve(__dirname, 'database.sqlite');
  console.log('Connecting to local SQLite database at:', dbPath);
  sqliteDb = new sqlite3.Database(dbPath);
}

// Convert $1, $2 etc. placeholders to ? for SQLite
function formatQuery(sql) {
  if (isPostgres) return sql;
  return sql.replace(/\$\d+/g, '?');
}

/**
 * Execute a query that returns multiple rows.
 */
function query(sql, params = []) {
  const formattedSql = formatQuery(sql);
  if (isPostgres) {
    return pgPool.query(formattedSql, params).then(res => res.rows);
  } else {
    return new Promise((resolve, reject) => {
      sqliteDb.all(formattedSql, params, (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  }
}

/**
 * Execute a query that returns a single row.
 */
function queryOne(sql, params = []) {
  const formattedSql = formatQuery(sql);
  if (isPostgres) {
    return pgPool.query(formattedSql, params).then(res => res.rows[0] || null);
  } else {
    return new Promise((resolve, reject) => {
      sqliteDb.get(formattedSql, params, (err, row) => {
        if (err) reject(err);
        else resolve(row || null);
      });
    });
  }
}

/**
 * Execute a write query (INSERT, UPDATE, DELETE).
 */
function exec(sql, params = []) {
  const formattedSql = formatQuery(sql);
  if (isPostgres) {
    return pgPool.query(formattedSql, params).then(res => ({
      affectedRows: res.rowCount,
      rows: res.rows
    }));
  } else {
    return new Promise((resolve, reject) => {
      sqliteDb.run(formattedSql, params, function (err) {
        if (err) reject(err);
        else resolve({
          affectedRows: this.changes,
          lastID: this.lastID
        });
      });
    });
  }
}

// Initialize tables
async function initDb() {
  if (isPostgres) {
    await pgPool.query(`
      CREATE TABLE IF NOT EXISTS users (
        uid VARCHAR(255) PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        full_name VARCHAR(255) DEFAULT '',
        nick_name VARCHAR(255) DEFAULT '',
        phone VARCHAR(255) DEFAULT '',
        address VARCHAR(255) DEFAULT '',
        job VARCHAR(255) DEFAULT '',
        avatar_url VARCHAR(255) DEFAULT '',
        created_at BIGINT NOT NULL,
        updated_at BIGINT NOT NULL,
        reset_code VARCHAR(10),
        reset_expires_at BIGINT,
        is_verified BOOLEAN DEFAULT TRUE,
        verification_code VARCHAR(10),
        verification_expires_at BIGINT
      );

      CREATE TABLE IF NOT EXISTS posts (
        id VARCHAR(255) PRIMARY KEY,
        owner_id VARCHAR(255) REFERENCES users(uid) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        category VARCHAR(100) NOT NULL,
        is_lost BOOLEAN NOT NULL,
        reward VARCHAR(100),
        location VARCHAR(255) NOT NULL,
        image_url VARCHAR(255) DEFAULT '',
        status VARCHAR(50) DEFAULT 'active',
        created_at_ms BIGINT NOT NULL,
        updated_at_ms BIGINT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS chats (
        id VARCHAR(255) PRIMARY KEY,
        post_id VARCHAR(255) REFERENCES posts(id) ON DELETE CASCADE,
        item_name VARCHAR(255) NOT NULL,
        last_message_text TEXT DEFAULT '',
        last_sender_id VARCHAR(255),
        created_at_ms BIGINT NOT NULL,
        updated_at_ms BIGINT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS chat_participants (
        chat_id VARCHAR(255) REFERENCES chats(id) ON DELETE CASCADE,
        user_id VARCHAR(255) REFERENCES users(uid) ON DELETE CASCADE,
        unread_count INTEGER DEFAULT 0,
        PRIMARY KEY (chat_id, user_id)
      );

      CREATE TABLE IF NOT EXISTS messages (
        id VARCHAR(255) PRIMARY KEY,
        chat_id VARCHAR(255) REFERENCES chats(id) ON DELETE CASCADE,
        sender_id VARCHAR(255) REFERENCES users(uid) ON DELETE CASCADE,
        text TEXT NOT NULL,
        is_read BOOLEAN DEFAULT FALSE,
        created_at_ms BIGINT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS notifications (
        id VARCHAR(255) PRIMARY KEY,
        user_id VARCHAR(255) REFERENCES users(uid) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        type VARCHAR(100) NOT NULL,
        is_unread BOOLEAN DEFAULT TRUE,
        created_at_ms BIGINT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS blocked_users (
        user_id VARCHAR(255) REFERENCES users(uid) ON DELETE CASCADE,
        blocked_user_id VARCHAR(255) REFERENCES users(uid) ON DELETE CASCADE,
        PRIMARY KEY (user_id, blocked_user_id)
      );

      CREATE TABLE IF NOT EXISTS saved_items (
        user_id VARCHAR(255) REFERENCES users(uid) ON DELETE CASCADE,
        post_id VARCHAR(255) REFERENCES posts(id) ON DELETE CASCADE,
        PRIMARY KEY (user_id, post_id)
      );

      CREATE TABLE IF NOT EXISTS reports (
        id VARCHAR(255) PRIMARY KEY,
        post_id VARCHAR(255) REFERENCES posts(id) ON DELETE CASCADE,
        reporter_id VARCHAR(255) REFERENCES users(uid) ON DELETE CASCADE,
        reason TEXT,
        status VARCHAR(50) DEFAULT 'pending',
        created_at_ms BIGINT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS user_settings (
        user_id VARCHAR(255) PRIMARY KEY REFERENCES users(uid) ON DELETE CASCADE,
        show_profile BOOLEAN DEFAULT TRUE,
        allow_messages BOOLEAN DEFAULT TRUE,
        show_location BOOLEAN DEFAULT FALSE,
        hide_phone BOOLEAN DEFAULT TRUE
      );
    `);

    try {
      await pgPool.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_code VARCHAR(10);');
      await pgPool.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_expires_at BIGINT;');
      await pgPool.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT TRUE;');
      await pgPool.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_code VARCHAR(10);');
      await pgPool.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_expires_at BIGINT;');
    } catch (err) {
      console.error('Error altering users table for verification columns (Postgres):', err.message);
    }
  } else {
    // SQLite syntax
    return new Promise((resolve, reject) => {
      sqliteDb.serialize(() => {
        sqliteDb.run(`
          CREATE TABLE IF NOT EXISTS users (
            uid TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            full_name TEXT DEFAULT '',
            nick_name TEXT DEFAULT '',
            phone TEXT DEFAULT '',
            address TEXT DEFAULT '',
            job TEXT DEFAULT '',
            avatar_url TEXT DEFAULT '',
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            reset_code TEXT,
            reset_expires_at INTEGER,
            is_verified INTEGER DEFAULT 1,
            verification_code TEXT,
            verification_expires_at INTEGER
          )
        `);

        // Alter SQLite table to add columns (ignore errors if they already exist)
        sqliteDb.run('ALTER TABLE users ADD COLUMN reset_code TEXT', () => {});
        sqliteDb.run('ALTER TABLE users ADD COLUMN reset_expires_at INTEGER', () => {});
        sqliteDb.run('ALTER TABLE users ADD COLUMN is_verified INTEGER DEFAULT 1', () => {});
        sqliteDb.run('ALTER TABLE users ADD COLUMN verification_code TEXT', () => {});
        sqliteDb.run('ALTER TABLE users ADD COLUMN verification_expires_at INTEGER', () => {});

        sqliteDb.run(`
          CREATE TABLE IF NOT EXISTS posts (
            id TEXT PRIMARY KEY,
            owner_id TEXT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            category TEXT NOT NULL,
            is_lost INTEGER NOT NULL,
            reward TEXT,
            location TEXT NOT NULL,
            image_url TEXT DEFAULT '',
            status TEXT DEFAULT 'active',
            created_at_ms INTEGER NOT NULL,
            updated_at_ms INTEGER NOT NULL,
            FOREIGN KEY (owner_id) REFERENCES users(uid) ON DELETE CASCADE
          )
        `);

        sqliteDb.run(`
          CREATE TABLE IF NOT EXISTS chats (
            id TEXT PRIMARY KEY,
            post_id TEXT,
            item_name TEXT NOT NULL,
            last_message_text TEXT DEFAULT '',
            last_sender_id TEXT,
            created_at_ms INTEGER NOT NULL,
            updated_at_ms INTEGER NOT NULL,
            FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
          )
        `);

        sqliteDb.run(`
          CREATE TABLE IF NOT EXISTS chat_participants (
            chat_id TEXT,
            user_id TEXT,
            unread_count INTEGER DEFAULT 0,
            PRIMARY KEY (chat_id, user_id),
            FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(uid) ON DELETE CASCADE
          )
        `);

        sqliteDb.run(`
          CREATE TABLE IF NOT EXISTS messages (
            id TEXT PRIMARY KEY,
            chat_id TEXT,
            sender_id TEXT,
            text TEXT NOT NULL,
            is_read INTEGER DEFAULT 0,
            created_at_ms INTEGER NOT NULL,
            FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
            FOREIGN KEY (sender_id) REFERENCES users(uid) ON DELETE CASCADE
          )
        `);

        sqliteDb.run(`
          CREATE TABLE IF NOT EXISTS notifications (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            title TEXT NOT NULL,
            message TEXT NOT NULL,
            type TEXT NOT NULL,
            is_unread INTEGER DEFAULT 1,
            created_at_ms INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(uid) ON DELETE CASCADE
          )
        `);

        sqliteDb.run(`
          CREATE TABLE IF NOT EXISTS blocked_users (
            user_id TEXT,
            blocked_user_id TEXT,
            PRIMARY KEY (user_id, blocked_user_id),
            FOREIGN KEY (user_id) REFERENCES users(uid) ON DELETE CASCADE,
            FOREIGN KEY (blocked_user_id) REFERENCES users(uid) ON DELETE CASCADE
          )
        `);

        sqliteDb.run(`
          CREATE TABLE IF NOT EXISTS saved_items (
            user_id TEXT,
            post_id TEXT,
            PRIMARY KEY (user_id, post_id),
            FOREIGN KEY (user_id) REFERENCES users(uid) ON DELETE CASCADE,
            FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
          )
        `);

        sqliteDb.run(`
          CREATE TABLE IF NOT EXISTS reports (
            id TEXT PRIMARY KEY,
            post_id TEXT,
            reporter_id TEXT,
            reason TEXT,
            status TEXT DEFAULT 'pending',
            created_at_ms INTEGER NOT NULL,
            FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
            FOREIGN KEY (reporter_id) REFERENCES users(uid) ON DELETE CASCADE
          )
        `);

        sqliteDb.run(`
          CREATE TABLE IF NOT EXISTS user_settings (
            user_id TEXT PRIMARY KEY,
            show_profile INTEGER DEFAULT 1,
            allow_messages INTEGER DEFAULT 1,
            show_location INTEGER DEFAULT 0,
            hide_phone INTEGER DEFAULT 1,
            FOREIGN KEY (user_id) REFERENCES users(uid) ON DELETE CASCADE
          )
        `, (err) => {
          if (err) reject(err);
          else resolve();
        });
      });
    });
  }
}

module.exports = {
  query,
  queryOne,
  exec,
  initDb,
  isPostgres
};
