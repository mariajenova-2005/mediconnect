const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { data, save, id } = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();
router.use(requireAuth);

// Files are stored on the server's disk in backend/uploads (private — only the owner can download).
const dir = path.join(__dirname, '..', 'uploads');
fs.mkdirSync(dir, { recursive: true });
const upload = multer({ dest: dir, limits: { fileSize: 10 * 1024 * 1024 } });

router.get('/', (req, res) => {
  res.json(data.records.filter((r) => r.patient === req.user.id).map(({ storedAs, ...r }) => r).reverse());
});

// POST /api/records/upload  (multipart/form-data: field "file", optional "type")
router.post('/upload', upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).json({ message: 'No file uploaded' });
  const rec = { _id: id(), patient: req.user.id, fileName: req.file.originalname, type: req.body.type || 'Other', storedAs: req.file.filename, createdAt: new Date().toISOString() };
  data.records.push(rec);
  save();
  const { storedAs, ...out } = rec;
  res.status(201).json(out);
});

// GET /api/records/:id/file — download (owner only)
router.get('/:id/file', (req, res) => {
  const rec = data.records.find((r) => r._id === req.params.id && r.patient === req.user.id);
  if (!rec) return res.status(404).json({ message: 'Record not found' });
  res.download(path.join(dir, rec.storedAs), rec.fileName);
});

module.exports = router;
