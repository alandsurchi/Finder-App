const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db');
const crypto = require('crypto');

const router = express.Router();
const config = require('../config');
const JWT_SECRET = config.jwtSecret;
const { smtpConfigured, truthy } = require('../lib/helpers');
const { validate, schemas } = require('../lib/validate');
const mailer = require('../lib/mailer');

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
router.post('/signup', validate(schemas.signup), async (req, res) => {
  const { email, password, fullName, phone } = req.body;

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

    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const verificationExpiresAt = Date.now() + 24 * 60 * 60 * 1000; // 24 hours

    // Demo mode: without SMTP there is no way to deliver a code, so accounts
    // are verified immediately. Real verification returns once SMTP is set.
    const autoVerify = !smtpConfigured();
    const verifiedFlag = db.isPostgres ? autoVerify : (autoVerify ? 1 : 0);

    // Create user profile
    await db.exec(
      `INSERT INTO users (uid, email, password_hash, full_name, nick_name, phone, created_at, updated_at, is_verified, verification_code, verification_expires_at) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
      [uid, email.toLowerCase().trim(), passwordHash, resolvedName, resolvedNick, phone || '', now, now, verifiedFlag, autoVerify ? null : verificationCode, autoVerify ? null : verificationExpiresAt]
    );

    if (autoVerify) {
      console.log(`[SIGNUP] ${email} auto-verified (SMTP not configured).`);
    } else {
      console.log(`[SIGNUP VERIFICATION CODE] Email: ${email}, Code: ${verificationCode}`);
    }

    // Send email asynchronously
    if (mailer.mailConfigured()) {
      const body = mailer.codeEmail({
        title: 'Welcome to Finder!',
        intro: 'Use this 6-digit code to verify your e-mail address:',
        code: verificationCode,
        footer: 'The code expires in 24 hours. If you did not create a Finder account, ignore this e-mail.',
        color: '#0B6E6A',
      });
      mailer.sendMailInBackground('signup verification', {
        to: email.toLowerCase().trim(),
        subject: 'Verify your Finder e-mail',
        ...body,
      });
    }

    const token = jwt.sign({ userId: uid, isVerified: autoVerify }, JWT_SECRET, { expiresIn: config.jwtExpiresIn });

    res.status(201).json({
      token,
      user: {
        id: uid,
        email: email.toLowerCase().trim(),
        displayName: resolvedName,
        photoUrl: '',
        isVerified: autoVerify
      }
    });
  } catch (err) {
    console.error('Signup error:', err);
    res.status(500).json({ message: 'Database error occurred during registration.' });
  }
});

// POST /auth/login
router.post('/login', validate(schemas.login), async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await db.queryOne('SELECT * FROM users WHERE email = $1', [email.toLowerCase().trim()]);
    if (!user) {
      return res.status(401).json({ message: 'Incorrect email or password.' });
    }

    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({ message: 'Incorrect email or password.' });
    }

    const isVerified = user.is_verified === 1 || user.is_verified === true || user.is_verified === 'true';

    // Sign JWT
    const token = jwt.sign({ userId: user.uid, isVerified: isVerified }, JWT_SECRET, { expiresIn: config.jwtExpiresIn });

    res.status(200).json({
      token,
      user: {
        id: user.uid,
        email: user.email,
        displayName: user.full_name || user.nick_name,
        photoUrl: user.avatar_url || '',
        isVerified: isVerified
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

    const isAdmin = await require('../lib/helpers').syncAdminFlag(user);
    res.status(200).json({
      id: user.uid,
      email: user.email,
      displayName: user.full_name,
      photoUrl: user.avatar_url,
      isVerified: truthy(user.is_verified),
      identityVerified: truthy(user.identity_verified),
      isAdmin,
      authProvider: user.auth_provider || 'email'
    });
  } catch (err) {
    console.error('Fetch me error:', err);
    res.status(500).json({ message: 'Database error.' });
  }
});

// POST /auth/forgot-password
router.post('/forgot-password', validate(schemas.forgotPassword), async (req, res) => {
  const { email } = req.body;

  try {
    const user = await db.queryOne('SELECT * FROM users WHERE email = $1', [email.toLowerCase().trim()]);
    if (!user) {
      // Same answer as for a known address, so the endpoint cannot be used to enumerate accounts.
      return res.status(200).json({ message: 'If that address is registered, a code is on its way.' });
    }

    // Generate 6-digit verification code
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = Date.now() + 15 * 60 * 1000; // 15 mins expiry

    // Save to database
    await db.exec(
      'UPDATE users SET reset_code = $1, reset_expires_at = $2 WHERE email = $3',
      [code, expiresAt, email.toLowerCase().trim()]
    );

    console.log(`[PASSWORD RESET CODE] Email: ${email}, Code: ${code}`);

    // Attempt to send email via SMTP if SMTP configuration is set in env
    if (mailer.mailConfigured()) {
      const body = mailer.codeEmail({
        title: 'Reset your Finder password',
        intro: 'Use this 6-digit code to reset your password:',
        code,
        footer: 'The code expires in 15 minutes. If you did not request a reset, ignore this e-mail.',
        color: '#0B6E6A',
      });
      mailer.sendMailInBackground('password reset', {
        to: email.toLowerCase().trim(),
        subject: 'Finder password reset code',
        ...body,
      });
    }

    res.status(200).json({ message: 'Verification code sent successfully.' });
  } catch (err) {
    console.error('Forgot password error:', err);
    res.status(500).json({ message: 'Database error occurred.' });
  }
});

// POST /auth/verify-reset-code
router.post('/verify-reset-code', validate(schemas.verifyResetCode), async (req, res) => {
  const { email, code } = req.body;
  if (!email || !code) {
    return res.status(400).json({ message: 'Email and code are required.' });
  }

  try {
    const user = await db.queryOne('SELECT * FROM users WHERE email = $1', [email.toLowerCase().trim()]);
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    // Check code and expiry
    if (!user.reset_code || user.reset_code !== code.trim()) {
      return res.status(400).json({ message: 'Invalid verification code.' });
    }

    const now = Date.now();
    if (parseInt(user.reset_expires_at) < now) {
      return res.status(400).json({ message: 'Verification code has expired. Please request a new one.' });
    }

    res.status(200).json({ message: 'Verification code is valid.' });
  } catch (err) {
    console.error('Verify reset code error:', err);
    res.status(500).json({ message: 'Database error occurred.' });
  }
});


// POST /auth/reset-password
router.post('/reset-password', validate(schemas.resetPassword), async (req, res) => {
  const { email, code, newPassword } = req.body;

  try {
    const user = await db.queryOne('SELECT * FROM users WHERE email = $1', [email.toLowerCase().trim()]);
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    // Check code and expiry
    if (!user.reset_code || user.reset_code !== code.trim()) {
      return res.status(400).json({ message: 'Invalid verification code.' });
    }

    const now = Date.now();
    if (parseInt(user.reset_expires_at) < now) {
      return res.status(400).json({ message: 'Verification code has expired. Please request a new one.' });
    }

    // Hash new password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(newPassword, salt);

    // Update password and invalidate code
    await db.exec(
      'UPDATE users SET password_hash = $1, reset_code = NULL, reset_expires_at = NULL WHERE email = $2',
      [passwordHash, email.toLowerCase().trim()]
    );

    res.status(200).json({ message: 'Password has been reset successfully.' });
  } catch (err) {
    console.error('Reset password error:', err);
    res.status(500).json({ message: 'Database error occurred.' });
  }
});

// POST /auth/verify-email
router.post('/verify-email', verifyToken, validate(schemas.verifyEmail), async (req, res) => {
  const { code } = req.body;

  try {
    const user = await db.queryOne('SELECT * FROM users WHERE uid = $1', [req.userId]);
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    if (user.is_verified === 1 || user.is_verified === true || user.is_verified === 'true') {
      return res.status(400).json({ message: 'Account is already verified.' });
    }

    // Demo mode (no SMTP): codes cannot be delivered, so any code is accepted.
    if (smtpConfigured()) {
      if (!user.verification_code || user.verification_code !== code.trim()) {
        return res.status(400).json({ message: 'Invalid verification code.' });
      }

      const now = Date.now();
      if (parseInt(user.verification_expires_at) < now) {
        return res.status(400).json({ message: 'Verification code has expired. Please request a new one.' });
      }
    }

    // Update user status
    await db.exec(
      'UPDATE users SET is_verified = $1, verification_code = NULL, verification_expires_at = NULL WHERE uid = $2',
      [db.isPostgres ? true : 1, req.userId]
    );

    // Sign a new verified JWT
    const token = jwt.sign({ userId: req.userId, isVerified: true }, JWT_SECRET, { expiresIn: config.jwtExpiresIn });

    res.status(200).json({
      message: 'Email verified successfully.',
      token,
      user: {
        id: user.uid,
        email: user.email,
        displayName: user.full_name || user.nick_name,
        photoUrl: user.avatar_url || '',
        isVerified: true
      }
    });
  } catch (err) {
    console.error('Verify email error:', err);
    res.status(500).json({ message: 'Database error occurred.' });
  }
});

// POST /auth/resend-verification
router.post('/resend-verification', verifyToken, async (req, res) => {
  try {
    const user = await db.queryOne('SELECT * FROM users WHERE uid = $1', [req.userId]);
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    if (user.is_verified === 1 || user.is_verified === true || user.is_verified === 'true') {
      return res.status(400).json({ message: 'Account is already verified.' });
    }

    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const verificationExpiresAt = Date.now() + 24 * 60 * 60 * 1000;

    await db.exec(
      'UPDATE users SET verification_code = $1, verification_expires_at = $2 WHERE uid = $3',
      [verificationCode, verificationExpiresAt, req.userId]
    );

    console.log(`[RESEND VERIFICATION CODE] Email: ${user.email}, Code: ${verificationCode}`);

    // Send email asynchronously
    if (mailer.mailConfigured()) {
      const body = mailer.codeEmail({
        title: 'Verify your Finder e-mail',
        intro: 'Use this 6-digit code to verify your e-mail address:',
        code: verificationCode,
        footer: 'The code expires in 24 hours.',
        color: '#0B6E6A',
      });
      mailer.sendMailInBackground('verification resend', {
        to: user.email,
        subject: 'Verify your Finder e-mail',
        ...body,
      });
    }

    res.status(200).json({ message: 'Verification code resent successfully.' });
  } catch (err) {
    console.error('Resend verification error:', err);
    res.status(500).json({ message: 'Database error occurred.' });
  }
});

// POST /auth/google-login
router.post('/google-login', validate(schemas.googleLogin), async (req, res) => {
  const { idToken } = req.body;

  try {
    const { OAuth2Client } = require('google-auth-library');
    const oauth2Client = new OAuth2Client();
    
    // Verify Google ID token (validates signatures and client matches)
    const ticket = await oauth2Client.verifyIdToken({
      idToken: idToken,
      audience: config.googleClientIds
    });
    
    const payload = ticket.getPayload();
    const email = payload['email'];
    const name = payload['name'] || email.split('@')[0];
    const picture = payload['picture'] || '';

    // Check if user already exists
    let user = await db.queryOne('SELECT * FROM users WHERE email = $1', [email.toLowerCase().trim()]);
    let uid;
    
    if (!user) {
      // Register new user via Google
      uid = crypto.randomUUID();
      const now = Date.now();
      const nickName = name.replace(/\s+/g, '').toLowerCase();
      
      // Random dummy password since they authenticate with Google
      const salt = await bcrypt.genSalt(10);
      const passwordHash = await bcrypt.hash(crypto.randomUUID(), salt);

      await db.exec(
        `INSERT INTO users (uid, email, password_hash, full_name, nick_name, avatar_url, created_at, updated_at, is_verified, auth_provider)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
        [uid, email.toLowerCase().trim(), passwordHash, name, nickName, picture, now, now, db.isPostgres ? true : 1, 'google']
      );
      
      user = {
        uid,
        email,
        full_name: name,
        avatar_url: picture,
        is_verified: true
      };
    } else {
      uid = user.uid;
      // If user exists but is not verified, set to verified (since Google email is verified)
      if (user.is_verified === 0 || user.is_verified === false) {
        await db.exec('UPDATE users SET is_verified = $1 WHERE uid = $2', [db.isPostgres ? true : 1, uid]);
        user.is_verified = true;
      }
    }

    // Sign JWT
    const token = jwt.sign({ userId: uid, isVerified: true }, JWT_SECRET, { expiresIn: config.jwtExpiresIn });

    res.status(200).json({
      token,
      user: {
        id: uid,
        email: user.email,
        displayName: user.full_name,
        photoUrl: user.avatar_url || '',
        isVerified: true
      }
    });
  } catch (err) {
    console.error('Google login error:', err);
    res.status(500).json({ message: 'Google authentication failed.' });
  }
});

module.exports = {
  router,
  verifyToken
};


