const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db');
const crypto = require('crypto');

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'finder_secret_key_12345';

// Middleware to verify JWT token
function verifyToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader) {
    return res.status(401).json({ message: 'No authorization header provided.' });
  }

  const token = authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ message: 'No bearer token provided.' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Invalid or expired token.' });
  }
}

// POST /auth/signup
router.post('/signup', async (req, res) => {
  const { email, password, fullName, phone } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required.' });
  }

  try {
    // Check if user already exists
    const existingUser = await db.queryOne('SELECT * FROM users WHERE email = $1', [email.toLowerCase().trim()]);
    if (existingUser) {
      return res.status(400).json({ message: 'Email is already registered.' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const uid = crypto.randomUUID();
    const now = Date.now();
    const emailPrefix = email.split('@')[0];
    const resolvedName = fullName || emailPrefix;
    const resolvedNick = resolvedName.replace(/\s+/g, '').toLowerCase();

    // Create user profile
    await db.exec(
      `INSERT INTO users (uid, email, password_hash, full_name, nick_name, phone, created_at, updated_at) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [uid, email.toLowerCase().trim(), passwordHash, resolvedName, resolvedNick, phone || '', now, now]
    );

    // Sign JWT
    const token = jwt.sign({ userId: uid }, JWT_SECRET, { expiresIn: '30d' });

    res.status(201).json({
      token,
      user: {
        id: uid,
        email: email.toLowerCase().trim(),
        displayName: resolvedName,
        photoUrl: ''
      }
    });
  } catch (err) {
    console.error('Signup error:', err);
    res.status(500).json({ message: 'Database error occurred during registration.' });
  }
});

// POST /auth/login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required.' });
  }

  try {
    const user = await db.queryOne('SELECT * FROM users WHERE email = $1', [email.toLowerCase().trim()]);
    if (!user) {
      return res.status(401).json({ message: 'Incorrect email or password.' });
    }

    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({ message: 'Incorrect email or password.' });
    }

    // Sign JWT
    const token = jwt.sign({ userId: user.uid }, JWT_SECRET, { expiresIn: '30d' });

    res.status(200).json({
      token,
      user: {
        id: user.uid,
        email: user.email,
        displayName: user.full_name || user.nick_name,
        photoUrl: user.avatar_url || ''
      }
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ message: 'Database error occurred during login.' });
  }
});

// GET /auth/me
router.get('/me', verifyToken, async (req, res) => {
  try {
    const user = await db.queryOne('SELECT * FROM users WHERE uid = $1', [req.userId]);
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    res.status(200).json({
      id: user.uid,
      email: user.email,
      displayName: user.full_name,
      photoUrl: user.avatar_url
    });
  } catch (err) {
    console.error('Fetch me error:', err);
    res.status(500).json({ message: 'Database error.' });
  }
});

module.exports = {
  router,
  verifyToken
};
