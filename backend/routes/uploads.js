// Signed Cloudinary uploads. The app asks for a signature, then uploads the
// file straight to Cloudinary with it, so the API secret never leaves the server.
const express = require('express');
const crypto = require('crypto');
const config = require('../config');
const { verifyToken } = require('./auth');
const { validate, schemas } = require('../lib/validate');

const router = express.Router();

// POST /uploads/sign { folder }
router.post('/sign', verifyToken, validate(schemas.uploadSign), (req, res) => {
  const { cloudName, apiKey, apiSecret, configured } = config.cloudinary;
  if (!configured) {
    return res.status(503).json({
      message: 'Uploads are not configured on this server (CLOUDINARY_* variables).',
    });
  }

  const folder = `finder/${req.body.folder}`;
  const timestamp = Math.floor(Date.now() / 1000);
  // Cloudinary signs the alphabetically sorted params joined by '&', then appends the secret.
  const toSign = `folder=${folder}&timestamp=${timestamp}`;
  const signature = crypto.createHash('sha1').update(toSign + apiSecret).digest('hex');

  res.status(200).json({
    cloudName,
    apiKey,
    timestamp,
    folder,
    signature,
    uploadUrl: `https://api.cloudinary.com/v1_1/${cloudName}/image/upload`,
  });
});

module.exports = router;
