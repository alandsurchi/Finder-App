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

    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const verificationExpiresAt = Date.now() + 24 * 60 * 60 * 1000; // 24 hours

    // Create user profile
    await db.exec(
      `INSERT INTO users (uid, email, password_hash, full_name, nick_name, phone, created_at, updated_at, is_verified, verification_code, verification_expires_at) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
      [uid, email.toLowerCase().trim(), passwordHash, resolvedName, resolvedNick, phone || '', now, now, db.isPostgres ? false : 0, verificationCode, verificationExpiresAt]
    );

    console.log(`[SIGNUP VERIFICATION CODE] Email: ${email}, Code: ${verificationCode}`);

    // Send email asynchronously
    if (process.env.SMTP_HOST && process.env.SMTP_USER && process.env.SMTP_PASS) {
      try {
        const nodemailer = require('nodemailer');
        const transporter = nodemailer.createTransport({
          host: process.env.SMTP_HOST,
          port: parseInt(process.env.SMTP_PORT) || 587,
          secure: process.env.SMTP_PORT == '465',
          auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS
          }
        });

        const fromEmail = process.env.SMTP_FROM || (process.env.SMTP_USER.includes('@') ? process.env.SMTP_USER : 'onboarding@resend.dev');

        transporter.sendMail({
          from: `"Finder Support" <${fromEmail}>`,
          to: email.toLowerCase().trim(),
          subject: 'Welcome to Finder! Verify your email',
          text: `Welcome to Finder! Your verification code is: ${verificationCode}.`,
          html: `
            <div style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
              <h2>Welcome to Finder!</h2>
              <p>Please use the following 6-digit code to verify your account email address:</p>
              <h1 style="background: #f4f4f4; padding: 10px 20px; display: inline-block; font-size: 28px; letter-spacing: 4px; color: #28a745; border-radius: 4px;">${verificationCode}</h1>
              <p>If you did not create a Finder account, please ignore this email.</p>
            </div>
          `
        }).then(() => {
          console.log(`Signup verification email sent to ${email}`);
        }).catch((mailErr) => {
          console.error('Failed to send verification email via SMTP:', mailErr.message);
        });
      } catch (mailErr) {
        console.error('Failed to setup verification transport:', mailErr.message);
      }
    }

    // Sign JWT (unverified)
    const token = jwt.sign({ userId: uid, isVerified: false }, JWT_SECRET, { expiresIn: '30d' });

    res.status(201).json({
      token,
      user: {
        id: uid,
        email: email.toLowerCase().trim(),
        displayName: resolvedName,
        photoUrl: '',
        isVerified: false
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

    const isVerified = user.is_verified === 1 || user.is_verified === true || user.is_verified === 'true';

    // Sign JWT
    const token = jwt.sign({ userId: user.uid, isVerified: isVerified }, JWT_SECRET, { expiresIn: '30d' });

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

    res.status(200).json({
      id: user.uid,
      email: user.email,
      displayName: user.full_name,
      photoUrl: user.avatar_url,
      isVerified: user.is_verified === 1 || user.is_verified === true || user.is_verified === 'true'
    });
  } catch (err) {
    console.error('Fetch me error:', err);
    res.status(500).json({ message: 'Database error.' });
  }
});

// POST /auth/forgot-password
router.post('/forgot-password', async (req, res) => {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ message: 'Email is required.' });
  }

  try {
    const user = await db.queryOne('SELECT * FROM users WHERE email = $1', [email.toLowerCase().trim()]);
    if (!user) {
      return res.status(404).json({ message: 'No user registered with this email address.' });
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
    if (process.env.SMTP_HOST && process.env.SMTP_USER && process.env.SMTP_PASS) {
      try {
        const nodemailer = require('nodemailer');
        const transporter = nodemailer.createTransport({
          host: process.env.SMTP_HOST,
          port: parseInt(process.env.SMTP_PORT) || 587,
          secure: process.env.SMTP_PORT == '465',
          auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS
          }
        });

        const fromEmail = process.env.SMTP_FROM || (process.env.SMTP_USER.includes('@') ? process.env.SMTP_USER : 'onboarding@resend.dev');

        // Send asynchronously to avoid blocking the HTTP response
        transporter.sendMail({
          from: `"Finder Support" <${fromEmail}>`,
          to: email.toLowerCase().trim(),
          subject: 'Finder Password Reset Verification',
          text: `Your password reset verification code is: ${code}. It expires in 15 minutes.`,
          html: `
            <div style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
              <h2>Finder Password Reset</h2>
              <p>You requested a password reset. Please use the following 6-digit verification code to complete your reset:</p>
              <h1 style="background: #f4f4f4; padding: 10px 20px; display: inline-block; font-size: 28px; letter-spacing: 4px; color: #007bff; border-radius: 4px;">${code}</h1>
              <p>This code will expire in 15 minutes. If you did not request this, you can ignore this email.</p>
            </div>
          `
        }).then(() => {
          console.log(`Reset email sent to ${email}`);
        }).catch((mailErr) => {
          console.error('Failed to send reset email via SMTP:', mailErr.message);
        });
      } catch (mailErr) {
        console.error('Failed to setup nodemailer transport:', mailErr.message);
      }
    }

    res.status(200).json({ message: 'Verification code sent successfully.' });
  } catch (err) {
    console.error('Forgot password error:', err);
    res.status(500).json({ message: 'Database error occurred.' });
  }
});

// POST /auth/verify-reset-code
router.post('/verify-reset-code', async (req, res) => {
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
router.post('/reset-password', async (req, res) => {
  const { email, code, newPassword } = req.body;
  if (!email || !code || !newPassword) {
    return res.status(400).json({ message: 'Email, code, and new password are required.' });
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
router.post('/verify-email', verifyToken, async (req, res) => {
  const { code } = req.body;
  if (!code) {
    return res.status(400).json({ message: 'Verification code is required.' });
  }

  try {
    const user = await db.queryOne('SELECT * FROM users WHERE uid = $1', [req.userId]);
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    if (user.is_verified === 1 || user.is_verified === true || user.is_verified === 'true') {
      return res.status(400).json({ message: 'Account is already verified.' });
    }

    if (!user.verification_code || user.verification_code !== code.trim()) {
      return res.status(400).json({ message: 'Invalid verification code.' });
    }

    const now = Date.now();
    if (parseInt(user.verification_expires_at) < now) {
      return res.status(400).json({ message: 'Verification code has expired. Please request a new one.' });
    }

    // Update user status
    await db.exec(
      'UPDATE users SET is_verified = $1, verification_code = NULL, verification_expires_at = NULL WHERE uid = $2',
      [db.isPostgres ? true : 1, req.userId]
    );

    // Sign a new verified JWT
    const token = jwt.sign({ userId: req.userId, isVerified: true }, JWT_SECRET, { expiresIn: '30d' });

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
    if (process.env.SMTP_HOST && process.env.SMTP_USER && process.env.SMTP_PASS) {
      try {
        const nodemailer = require('nodemailer');
        const transporter = nodemailer.createTransport({
          host: process.env.SMTP_HOST,
          port: parseInt(process.env.SMTP_PORT) || 587,
          secure: process.env.SMTP_PORT == '465',
          auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS
          }
        });

        const fromEmail = process.env.SMTP_FROM || (process.env.SMTP_USER.includes('@') ? process.env.SMTP_USER : 'onboarding@resend.dev');

        transporter.sendMail({
          from: `"Finder Support" <${fromEmail}>`,
          to: user.email,
          subject: 'Finder - Verify your email',
          text: `Your verification code is: ${verificationCode}.`,
          html: `
            <div style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
              <h2>Verify your account email address</h2>
              <p>Please use the following 6-digit code to verify your account email:</p>
              <h1 style="background: #f4f4f4; padding: 10px 20px; display: inline-block; font-size: 28px; letter-spacing: 4px; color: #28a745; border-radius: 4px;">${verificationCode}</h1>
            </div>
          `
        }).then(() => {
          console.log(`Resent verification email to ${user.email}`);
        }).catch((mailErr) => {
          console.error('Failed to resend verification email via SMTP:', mailErr.message);
        });
      } catch (mailErr) {
        console.error('Failed to setup verification transport:', mailErr.message);
      }
    }

    res.status(200).json({ message: 'Verification code resent successfully.' });
  } catch (err) {
    console.error('Resend verification error:', err);
    res.status(500).json({ message: 'Database error occurred.' });
  }
});

// POST /auth/google-login
router.post('/google-login', async (req, res) => {
  const { idToken } = req.body;
  if (!idToken) {
    return res.status(400).json({ message: 'Google idToken is required.' });
  }

  try {
    const { OAuth2Client } = require('google-auth-library');
    const oauth2Client = new OAuth2Client();
    
    // Verify Google ID token (validates signatures and client matches)
    const ticket = await oauth2Client.verifyIdToken({
      idToken: idToken,
      audience: [
        '685670849218-6vp6v6gpjujcb6krkqjcicd3gn5bcjeo.apps.googleusercontent.com',
        '685670849218-pah2cvt7m1ksjumqhbt5uvtb7815mb9u.apps.googleusercontent.com',
        '685670849218-9vt84sr1ibi9dpqphtqqugcavkk4kn63.apps.googleusercontent.com'
      ]
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
        `INSERT INTO users (uid, email, password_hash, full_name, nick_name, avatar_url, created_at, updated_at, is_verified) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [uid, email.toLowerCase().trim(), passwordHash, name, nickName, picture, now, now, db.isPostgres ? true : 1]
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
    const token = jwt.sign({ userId: uid, isVerified: true }, JWT_SECRET, { expiresIn: '30d' });

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


