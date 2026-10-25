const express = require('express');
const Groq = require('groq-sdk');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();
router.use(requireAuth);

// Created lazily so the server starts fine without a Groq key (AI calls then return an error
// and the Flutter app falls back to its built-in answers).
let _groq;
const MODEL = process.env.GROQ_MODEL || 'llama-3.3-70b-versatile';
const groq = {
  chat: {
    completions: {
      create: (...args) => {
        if (!process.env.GROQ_API_KEY) throw new Error('GROQ_API_KEY not set in .env');
        if (!_groq) _groq = new Groq({ apiKey: process.env.GROQ_API_KEY });
        return _groq.chat.completions.create(...args);
      },
    },
  },
};

async function askGroq(systemPrompt, userPrompt) {
  const completion = await groq.chat.completions.create({
    model: MODEL,
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt },
    ],
    response_format: { type: 'json_object' },
  });
  return JSON.parse(completion.choices[0].message.content);
}

// POST /api/ai/symptom-check  { symptoms, age, gender }
router.post('/symptom-check', async (req, res) => {
  try {
    const { symptoms, age, gender } = req.body;
    const result = await askGroq(
      'You are a careful medical triage assistant. Given symptoms, age and gender, respond ONLY with JSON: ' +
        '{"possibleConditions": string[], "severity": "Mild"|"Moderate"|"Severe", "suggestedSpecialist": string}. ' +
        'Never give a definitive diagnosis — these are possibilities for a human doctor to confirm.',
      `Symptoms: ${symptoms}. Age: ${age}. Gender: ${gender}.`
    );
    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/ai/recommend-doctor  { symptoms, medicalHistory }
router.post('/recommend-doctor', async (req, res) => {
  try {
    const { symptoms, medicalHistory } = req.body;
    const result = await askGroq(
      'You are a doctor-matching assistant for a hospital app. Respond ONLY with JSON: {"specialty": string, "reasoning": string}.',
      `Symptoms: ${symptoms}. Medical history: ${(medicalHistory || []).join(', ')}.`
    );
    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/ai/analyze-report  { extractedText }  (extract PDF text server-side first, e.g. with pdf-parse)
router.post('/analyze-report', async (req, res) => {
  try {
    const { extractedText } = req.body;
    const result = await askGroq(
      'You are a medical report summarizer. Respond ONLY with JSON: ' +
        '{"summary": string, "abnormalFindings": string[], "recommendations": string[]}. Be cautious and conservative.',
      extractedText
    );
    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/ai/explain-prescription  { medicineName, dosageText }
router.post('/explain-prescription', async (req, res) => {
  try {
    const { medicineName, dosageText } = req.body;
    const result = await askGroq(
      'You explain prescriptions in plain language. Respond ONLY with JSON: ' +
        '{"medicineName": string, "purpose": string, "dosage": string, "sideEffects": string[], "precautions": string[]}.',
      `Medicine: ${medicineName}. Prescribed as: ${dosageText || 'not specified'}.`
    );
    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/ai/chat  { question }  — the 24/7 MediBot assistant
router.post('/chat', async (req, res) => {
  try {
    const { question } = req.body;
    const completion = await groq.chat.completions.create({
      model: MODEL,
      messages: [
        { role: 'system', content: 'You are MediBot, a friendly, careful healthcare assistant. Give general guidance, not diagnoses, and tell users to seek urgent care for red-flag symptoms.' },
        { role: 'user', content: question },
      ],
    });
    res.json({ reply: completion.choices[0].message.content });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/ai/doctor { messages:[{role,content}], patient:{age,gender,allergies,conditions} } — "Dr. Medi" voice agent
router.post('/doctor', async (req, res) => {
  try {
    const { messages = [], patient = {} } = req.body;
    const system =
      'You are Dr. Medi, a warm AI health assistant speaking to a patient by voice. You are NOT a licensed doctor and cannot diagnose or prescribe. ' +
      'Keep replies under 90 words, in simple spoken language, no lists or markdown. Ask one clarifying question at a time (duration, severity 1-10, other symptoms, pregnancy, age, current medicines) when needed. ' +
      'For minor, self-limiting symptoms you MAY mention commonly used over-the-counter options in general terms (for example paracetamol for fever or pain, oral rehydration solution for diarrhea, saline or honey for cough in adults) ' +
      'but ALWAYS: check the patient allergies and conditions below and avoid anything that conflicts; tell them to follow the product label or ask a pharmacist for the dose; NEVER give numeric doses for children or infants; ' +
      'NEVER suggest antibiotics, steroids, opioids, sedatives, or any prescription-only medicine; say to see a doctor if symptoms last more than 2-3 days or get worse. ' +
      'If there are red flags (chest pain, trouble breathing, stroke signs, severe bleeding, fainting, seizure, severe allergic reaction, thoughts of self-harm, overdose) set urgent to true and tell them to call emergency services or use the alarm button now. ' +
      'Also include "medicines": up to 3 general over-the-counter options relevant to what the patient has told you so far, each {"name": string, "purpose": few words, "caution": few words}, with NO doses; update this list every turn as you learn more; use an empty array if there are red flags, if you are unsure, or if a doctor should see them first. ' +
      'Respond ONLY with JSON: {"reply": string, "urgent": boolean, "medicines": array}. ' +
      'Patient: age ' + (patient.age || 'unknown') + ', gender ' + (patient.gender || 'unknown') + ', allergies: ' + ((patient.allergies || []).join(', ') || 'none listed') + ', conditions: ' + ((patient.conditions || []).join(', ') || 'none listed') + '.';
    const history = messages.slice(-10).map((m) => ({ role: m.role === 'assistant' ? 'assistant' : 'user', content: String(m.content).slice(0, 1000) }));
    const completion = await groq.chat.completions.create({
      model: MODEL,
      messages: [{ role: 'system', content: system }, ...history],
      response_format: { type: 'json_object' },
    });
    const out = JSON.parse(completion.choices[0].message.content);
    const medicines = (Array.isArray(out.medicines) ? out.medicines : []).slice(0, 3).map((m) => ({ name: String(m.name || ''), purpose: String(m.purpose || ''), caution: String(m.caution || '') }));
    res.json({ reply: String(out.reply || ''), urgent: !!out.urgent, medicines });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
