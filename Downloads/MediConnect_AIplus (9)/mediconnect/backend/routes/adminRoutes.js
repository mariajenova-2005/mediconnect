const express = require('express');
const { data } = require('../db');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();

// GET /api/admin/stats — live platform numbers
router.get('/stats', requireAuth, requireRole('admin'), (req, res) => {
  const start = new Date();
  start.setHours(0, 0, 0, 0);
  const end = new Date(start);
  end.setDate(end.getDate() + 1);
  const live = data.appointments.filter((a) => a.status !== 'cancelled');
  res.json({
    doctors: data.doctors.length,
    patients: data.users.filter((u) => u.role === 'patient').length,
    appointments: data.appointments.length,
    appointmentsToday: data.appointments.filter((a) => new Date(a.dateTime) >= start && new Date(a.dateTime) < end).length,
    revenue: live.reduce((sum, a) => sum + (a.fee || 0), 0),
  });
});

module.exports = router;
