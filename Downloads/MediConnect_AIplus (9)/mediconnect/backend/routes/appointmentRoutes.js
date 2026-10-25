const express = require('express');
const { data, save, id } = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();
router.use(requireAuth);

const populate = (a) => {
  const d = data.doctors.find((x) => x._id === a.doctor);
  const du = d && data.users.find((u) => u._id === d.user);
  const p = data.users.find((u) => u._id === a.patient);
  return { ...a, doctor: d ? { _id: d._id, specialty: d.specialty, user: { name: du ? du.name : 'Doctor' } } : null, patient: p ? { _id: p._id, name: p.name } : null };
};

// GET /api/appointments — patient: own; doctor: booked with them; admin: all
router.get('/', (req, res) => {
  let list;
  if (req.user.role === 'doctor') {
    const d = data.doctors.find((x) => x.user === req.user.id);
    list = data.appointments.filter((a) => d && a.doctor === d._id);
  } else if (req.user.role === 'admin') list = data.appointments;
  else list = data.appointments.filter((a) => a.patient === req.user.id);
  res.json(list.slice().sort((a, b) => new Date(a.dateTime) - new Date(b.dateTime)).map(populate));
});

// POST /api/appointments { doctor, dateTime } — fee comes from the doctor's record
router.post('/', (req, res) => {
  const doctor = data.doctors.find((d) => d._id === req.body.doctor);
  if (!doctor) return res.status(404).json({ message: 'Doctor not found' });
  if (isNaN(new Date(req.body.dateTime))) return res.status(400).json({ message: 'Invalid date/time' });
  const appt = { _id: id(), patient: req.user.id, doctor: doctor._id, dateTime: new Date(req.body.dateTime).toISOString(), status: 'upcoming', fee: doctor.fee, createdAt: new Date().toISOString() };
  data.appointments.push(appt);
  save();
  res.status(201).json(populate(appt));
});

const mine = (req) => data.appointments.find((a) => a._id === req.params.id && a.patient === req.user.id);

router.patch('/:id/cancel', (req, res) => {
  const a = mine(req);
  if (!a) return res.status(404).json({ message: 'Appointment not found' });
  a.status = 'cancelled';
  save();
  res.json(populate(a));
});

router.patch('/:id/reschedule', (req, res) => {
  const a = mine(req);
  if (!a) return res.status(404).json({ message: 'Appointment not found' });
  if (isNaN(new Date(req.body.dateTime))) return res.status(400).json({ message: 'Invalid date/time' });
  a.dateTime = new Date(req.body.dateTime).toISOString();
  a.status = 'upcoming';
  save();
  res.json(populate(a));
});

module.exports = router;
