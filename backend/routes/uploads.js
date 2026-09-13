// Image uploads stored on the server's own disk (a Railway volume in
// production). No third-party service: the app POSTs the file here and gets
// back a public URL served from /uploads.
const express = require('express');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');
const multer = require('multer');
const config = require('../config');
const { verifyToken } = require('./auth');

const router = express.Router();

const FOLDERS = ['posts', 'avatars', 'chat', 'verification'];
const MAX_BYTES = 8 * 1024 * 1024;
const EXT_BY_MIME = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
  'image/gif': 'gif',
  'image/heic': 'heic',
};

for (const f of FOLDERS) fs.mkdirSync(path.join(config.uploadsDir, f), { recursive: true });

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_BYTES, files: 1 },
  fileFilter: (req, file, cb) => {
    if (!EXT_BY_MIME[file.mimetype]) {
      return cb(Object.assign(new Error('Only JPEG, PNG, WebP, GIF or HEIC images are accepted.'), { status: 400 }));
    }
    cb(null, true);
  },
});

/** Public base URL: PUBLIC_URL when set, otherwise derived from the request. */
function publicBase(req) {
  if (config.publicUrl) return config.publicUrl;
  return `${req.protocol}://${req.get('host')}`;
}

// POST /uploads  (multipart: file=<image>, folder=posts|avatars|chat|verification)
router.post('/', verifyToken, (req, res, next) => {
  upload.single('file')(req, res, err => {
    if (err) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(413).json({ message: 'Please choose an image under 8 MB.' });
      }
      return res.status(err.status || 400).json({ message: err.message || 'Upload failed.' });
    }
    next();
  });
}, async (req, res) => {
  const folder = FOLDERS.includes(req.body.folder) ? req.body.folder : null;
  if (!folder) return res.status(400).json({ message: 'folder must be one of ' + FOLDERS.join(', ') });
  if (!req.file) return res.status(400).json({ message: 'No image received.' });

  try {
    const ext = EXT_BY_MIME[req.file.mimetype];
    const name = `${Date.now()}-${crypto.randomBytes(8).toString('hex')}.${ext}`;
    await fs.promises.writeFile(path.join(config.uploadsDir, folder, name), req.file.buffer);
    const url = `${publicBase(req)}/uploads/${folder}/${name}`;
    res.status(201).json({ url, bytes: req.file.size });
  } catch (err) {
    console.error('Upload error:', err);
    res.status(500).json({ message: 'Could not store the image.' });
  }
});

module.exports = router;
