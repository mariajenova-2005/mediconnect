// Tiny file-based database: everything lives in data/db.json. No install, no accounts.
// Fine for demos and small clinics; move to a real database (Postgres, etc.) when you scale.
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const FILE = path.join(__dirname, 'data', 'db.json');
const data = { users: [], doctors: [], appointments: [], records: [] };

try {
  Object.assign(data, JSON.parse(fs.readFileSync(FILE, 'utf8')));
} catch (_) {
  /* first run: start empty */
}

function save() {
  fs.mkdirSync(path.dirname(FILE), { recursive: true });
  fs.writeFileSync(FILE, JSON.stringify(data, null, 2));
}

// 24 hex characters (same shape the Flutter app expects for ids)
const id = () => crypto.randomBytes(12).toString('hex');

module.exports = { data, save, id };
