# MediConnect AI+ Backend (no database server needed)

Express + a JSON-file database (`data/db.json`) + JWT + Socket.IO + optional Groq AI.

```bash
cd backend
npm install
cp .env.example .env      # Windows PowerShell: cp .env.example .env
npm run dev
```
That's it — on first start it creates sample doctors and logins automatically:

| Role | Email | Password |
|---|---|---|
| Patient | patient@mediconnect.app | Patient@123 |
| Doctor | dr.aisha.menon@mediconnect.app | Doctor@123 |
| Admin | admin@mediconnect.app | Admin@123 |

Optional: put `GROQ_API_KEY` (from console.groq.com) in `.env` for live AI answers.
Without it the AI routes return an error and the Flutter app uses its built-in answers.

## Routes
| Feature | Route |
|---|---|
| Register (always a patient) / Login / Profile | `POST /api/auth/register`, `POST /api/auth/login`, `GET/PATCH /api/auth/me` |
| Doctors + filters | `GET /api/doctors?specialty=&minExperience=&maxFee=` |
| Doctor online/offline | `PATCH /api/doctors/me/availability` |
| Appointments | `GET/POST /api/appointments`, `PATCH /api/appointments/:id/cancel`, `.../reschedule` |
| Medical records (disk upload, owner-only download) | `GET /api/records`, `POST /api/records/upload`, `GET /api/records/:id/file` |
| Admin stats | `GET /api/admin/stats` |
| AI | `POST /api/ai/chat`, `/symptom-check`, `/recommend-doctor`, `/analyze-report`, `/explain-prescription` |
| Video signaling | Socket.IO: `join-room`, `webrtc-signal`, `chat-message` |

## Notes
- All data is in `data/db.json`; uploaded files are in `uploads/`. Back both up. Delete `data/` to reset.
- A JSON file is perfect for demos and small use. For many simultaneous users, move to PostgreSQL/SQLite.
- Set a real `JWT_SECRET` in `.env` before deploying.
