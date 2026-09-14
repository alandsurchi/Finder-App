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

// Identity documents are NOT here: they go through POST /profile/verification/upload
// into config.privateDir and are only served to their owner and admins.
const FOLDERS = ['posts', 'avatars', 'chat'];
const MAX_BYTES = 8 * 1024 * 1024;

/**
 * Detects the image format from its first bytes. Phones and browsers are
 * unreliable about the Content-Type they send (often application/octet-stream),
 * so the bytes decide, not the header.
 */
function sniffImage(buf) {
  if (!buf || buf.length < 12) return null;
  const ascii = (from, to) => buf.toString('latin1', from, to);
  if (buf[0] === 0xff && buf[1] === 0xd8 && buf[2] === 0xff) return { mime: 'image/jpeg', ext: 'jpg' };
  if (buf[0] === 0x89 && ascii(1, 4) === 'PNG') return { mime: 'image/png', ext: 'png' };
  if (ascii(0, 6) === 'GIF87a' || ascii(0, 6) === 'GIF89a') return { mime: 'image/gif', ext: 'gif' };
  if (ascii(0, 4) === 'RIFF' && ascii(8, 12) === 'WEBP') return { mime: 'image/webp', ext: 'webp' };
  if (buf[0] === 0x42 && buf[1] === 0x4d) return { mime: 'image/bmp', ext: 'bmp' };
  if ((buf[0] === 0x49 && buf[1] === 0x49 && buf[2] === 0x2a && buf[3] === 0x00) ||
      (buf[0] === 0x4d && buf[1] === 0x4d && buf[2] === 0x00 && buf[3] === 0x2a)) {
    return { mime: 'image/tiff', ext: 'tif' };
  }
  if (ascii(4, 8) === 'ftyp') {
    const brand = ascii(8, 12);
    if (/^(heic|heix|hevc|hevx|mif1|msf1)/.test(brand)) return { mime: 'image/heic', ext: 'heic' };
    if (/^avi[fs]/.test(brand)) return { mime: 'image/avif', ext: 'avif' };
  }
  return null;
}

for (const f of FOLDERS) fs.mkdirSync(path.join(config.uploadsDir, f), { recursive: true });

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_BYTES, files: 1 },
  fileFilter: (req, file, cb) => {
    const type = (file.mimetype || '').toLowerCase();
    // Anything that claims to be an image, or has no useful type at all, is
    // accepted here; the bytes are checked once the upload has finished.
    if (type.startsWith('image/') || type === 'application/octet-stream' || type === '') {
      return cb(null, true);
    }
    cb(Object.assign(new Error('Please choose an image file.'), { status: 400 }));
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
    // The declared Content-Type is never trusted: only files whose bytes are a
    // real raster image are stored.
    const sniffed = sniffImage(req.file.buffer);
    const ext = sniffed ? sniffed.ext : null;
    if (!ext) {
      return res.status(400).json({ message: 'That file does not look like an image we can read.' });
    }
    const name = `${Date.now()}-${crypto.randomBytes(8).toString('hex')}.${ext}`;
    await fs.promises.writeFile(path.join(config.uploadsDir, folder, name), req.file.buffer);
    const url = `${publicBase(req)}/uploads/${folder}/${name}`;
    res.status(201).json({ url, bytes: req.file.size });
  } catch (err) {
    console.error('Upload error:', err);
    res.status(500).json({ message: 'Could not store the image.' });
  }
});

module.exports = { router, upload, sniffImage };
