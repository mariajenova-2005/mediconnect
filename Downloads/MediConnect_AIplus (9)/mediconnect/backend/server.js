require('dotenv').config();
const crypto = require('crypto');
const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');

if (!process.env.JWT_SECRET) {
  process.env.JWT_SECRET = crypto.randomBytes(32).toString('hex');
  console.warn('JWT_SECRET not set — using a temporary one (logins reset when the server restarts).');
}

const { seedIfEmpty } = require('./seed');
seedIfEmpty();

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/doctors', require('./routes/doctorRoutes'));
app.use('/api/appointments', require('./routes/appointmentRoutes'));
app.use('/api/ai', require('./routes/aiRoutes'));
app.use('/api/records', require('./routes/recordRoutes'));
app.use('/api/admin', require('./routes/adminRoutes'));

app.get('/', (req, res) => res.json({ status: 'MediConnect AI+ backend running' }));

const server = http.createServer(app);

// Socket.IO: signaling channel for WebRTC video consultations + live chat
const io = new Server(server, { cors: { origin: '*' } });
io.on('connection', (socket) => {
  socket.on('join-room', (roomId) => socket.join(roomId));
  socket.on('webrtc-signal', ({ roomId, data }) => socket.to(roomId).emit('webrtc-signal', data));
  socket.on('chat-message', ({ roomId, message }) => socket.to(roomId).emit('chat-message', message));
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`MediConnect backend running on http://localhost:${PORT}`));
