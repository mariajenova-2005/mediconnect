// Sample accounts + doctors (names/hospitals are fictional). Runs automatically on first start,
// or manually with:  npm run seed
const bcrypt = require('bcryptjs');
const { data, save, id } = require('./db');

const doctors = [
  ['Dr. Aisha Menon', 'Cardiologist', 12, 700, 4.8, 'MediConnect Heart Centre', true],
  ['Dr. Vikram Shah', 'General Physician', 8, 400, 4.6, 'MediConnect Clinic', true],
  ['Dr. Nisha Pillai', 'Pediatrician', 15, 500, 4.9, 'MediConnect Children Care', false],
  ['Dr. Arjun Rao', 'Orthopedic', 10, 650, 4.5, 'MediConnect Ortho Wing', true],
  ['Dr. Priya Nair', 'Neurologist', 11, 800, 4.7, 'MediConnect Neuro Institute', false],
  ['Dr. Sameer Khan', 'Dermatologist', 6, 450, 4.4, 'MediConnect Skin Clinic', true],
  ['Dr. Lakshmi Iyer', 'Gynecologist', 14, 600, 4.8, 'MediConnect Women Care', true],
  ['Dr. Kabir Das', 'Gastroenterologist', 9, 700, 4.5, 'MediConnect Digestive Care', false],
];

function addUser(email, fields) {
  let u = data.users.find((x) => x.email === email);
  if (!u) {
    u = { _id: id(), email, allergies: [], medicalHistory: [], createdAt: new Date().toISOString(), ...fields };
    data.users.push(u);
  }
  return u;
}

function seed() {
  addUser('admin@mediconnect.app', { name: 'Admin', role: 'admin', passwordHash: bcrypt.hashSync('Admin@123', 10) });
  addUser('patient@mediconnect.app', { name: 'Demo Patient', role: 'patient', age: 29, gender: 'Female', bloodGroup: 'O+', allergies: ['Penicillin'], medicalHistory: ['Asthma (mild)'], phone: '+910000000000', passwordHash: bcrypt.hashSync('Patient@123', 10) });
  for (const [name, specialty, experienceYears, fee, rating, hospital, isAvailableNow] of doctors) {
    const email = 'dr.' + name.replace('Dr. ', '').toLowerCase().replace(/\s+/g, '.') + '@mediconnect.app';
    const u = addUser(email, { name, role: 'doctor', passwordHash: bcrypt.hashSync('Doctor@123', 10) });
    if (!data.doctors.find((d) => d.user === u._id)) {
      data.doctors.push({ _id: id(), user: u._id, specialty, experienceYears, fee, rating, hospital, isAvailableNow });
    }
  }
  save();
}

function seedIfEmpty() {
  if (data.users.length === 0) {
    seed();
    console.log('First run: sample data created.');
    console.log('  patient@mediconnect.app / Patient@123');
    console.log('  dr.aisha.menon@mediconnect.app / Doctor@123');
    console.log('  admin@mediconnect.app / Admin@123');
  }
}

module.exports = { seed, seedIfEmpty };
if (require.main === module) {
  seed();
  console.log('Seeded.');
}
