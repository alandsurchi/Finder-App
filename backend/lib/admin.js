// Admin role. Admins are the e-mail addresses listed in ADMIN_EMAILS; the
// flag is copied onto the user row the first time that account is seen, so
// routes can check a single column.
const db = require('../db');
const { verifyToken } = require('../routes/auth');
const { syncAdminFlag, isAdminEmail } = require('./helpers');

/** Express middleware chain: valid token AND admin user. */
const requireAdmin = [
  verifyToken,
  async (req, res, next) => {
    try {
      const user = await db.queryOne('SELECT uid, email, is_admin FROM users WHERE uid = $1', [req.userId]);
      if (!user) return res.status(401).json({ message: 'User not found.' });
      if (!(await syncAdminFlag(user))) {
        return res.status(403).json({ message: 'Admin access only.' });
      }
      req.adminUser = user;
      next();
    } catch (err) {
      console.error('Admin check error:', err);
      res.status(500).json({ message: 'Could not verify admin access.' });
    }
  },
];

module.exports = { requireAdmin, syncAdminFlag, isAdminEmail };
