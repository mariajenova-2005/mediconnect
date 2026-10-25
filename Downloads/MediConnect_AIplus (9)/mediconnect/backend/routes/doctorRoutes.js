const express = require('express');
const { data, save } = require('../db');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();
const view = (d) => {
  const u = data.users.find((x) => x._id === d.user);
  return { ...d, user: { _id: d.user, name: u ? u.name : 'Doctor' } };
};

// GET /api/doctors?specialty=&minExperience=&maxFee=
router.get('/', (req, res) => {
  const { specialty, minExperience, maxFee } = req.query;
  let list = data.doctors;
  if (specialty) list = list.filter((d) => d.specialty === specialty);
  if (minExperience) list = list.filter((d) => d.experienceYears >= Number(minExperience));
  if (maxFee) list = list.filter((d) => d.fee <= Number(maxFee));
  res.json(list.map(view).sort((a, b) => b.rating - a.rating));
});

// PATCH /api/doctors/me/availability — logged-in doctor flips their own online status
router.patch('/me/availability', requireAuth, requireRole('doctor'), (req, res) => {
  const d = data.doctors.find((x) => x.user === req.user.id);
  if (!d) return res.status(404).json({ message: 'Doctor profile not found' });
  d.isAvailableNow = !!req.body.isAvailableNow;
  save();
  res.json(view(d));
});

module.exports = router;
