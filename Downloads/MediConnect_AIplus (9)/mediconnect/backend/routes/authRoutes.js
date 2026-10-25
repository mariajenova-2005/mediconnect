const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { data, save, id } = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();
const sign = (u) => jwt.sign({ id: u._id, role: u.role }, process.env.JWT_SECRET, { expiresIn: '7d' });
const clean = ({ passwordHash, ...rest }) => rest;

// POST /api/auth/register — public sign-up always creates a PATIENT account
router.post('/register', (req, res) => {
  const { name, email, password } = req.body || {};
  if (!name || !email || !password) return res.status(400).json({ message: 'Name, email and password are required' });
  const mail = String(email).trim().toLowerCase();
  if (data.users.find((u) => u.email === mail)) return res.status(400).json({ message: 'Email already registered' });
  const user = { _id: id(), name, email: mail, passwordHash: bcrypt.hashSync(password, 10), role: 'patient', allergies: [], medicalHistory: [], createdAt: new Date().toISOString() };
  data.users.push(user);
  save();
  res.status(201).json({ token: sign(user), name: user.name, role: user.role });
});

// POST /api/auth/login
router.post('/login', (req, res) => {
  const { email, password } = req.body || {};
  const user = data.users.find((u) => u.email === String(email || '').trim().toLowerCase());
  if (!user || !bcrypt.compareSync(String(password || ''), user.passwordHash)) return res.status(401).json({ message: 'Invalid credentials' });
  res.json({ token: sign(user), name: user.name, role: user.role });
});

// GET /api/auth/me
router.get('/me', requireAuth, (req, res) => {
  const user = data.users.find((u) => u._id === req.user.id);
  if (!user) return res.status(404).json({ message: 'User not found' });
  res.json(clean(user));
});

// PATCH /api/auth/me
router.patch('/me', requireAuth, (req, res) => {
  const user = data.users.find((u) => u._id === req.user.id);
  if (!user) return res.status(404).json({ message: 'User not found' });
  for (const k of ['name', 'phone', 'age', 'gender', 'bloodGroup', 'allergies', 'medicalHistory', 'emergencyContacts']) if (req.body[k] !== undefined) user[k] = req.body[k];
  save();
  res.json(clean(user));
});

module.exports = router;
