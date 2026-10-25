import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

/// The backend, running INSIDE the app. Same routes and JSON shapes as the Node server, but data is
/// stored on the phone (SharedPreferences), so a single APK works with no server and no Wi-Fi to a PC.
/// AI calls go straight to Groq using a key you enter in the app (AI Settings).
class LocalBackend {
  LocalBackend._();
  static final LocalBackend instance = LocalBackend._();
  static const groqModel = 'llama-3.3-70b-versatile';

  late SharedPreferences _p;
  Map<String, dynamic> _db = {'users': [], 'doctors': [], 'appointments': []};
  String groqKey = '';

  List get _users => _db['users'] as List;
  List get _doctors => _db['doctors'] as List;
  List get _appts => _db['appointments'] as List;

  Future<void> init() async {
    _p = await SharedPreferences.getInstance();
    groqKey = _p.getString('groq_key') ?? '';
    final raw = _p.getString('db');
    if (raw != null) {
      try {
        _db = Map<String, dynamic>.from(jsonDecode(raw));
      } catch (_) {}
    }
    if (_users.isEmpty) _seed();
  }

  Future<void> setGroqKey(String k) async {
    groqKey = k.trim();
    await _p.setString('groq_key', groqKey);
  }

  Future<void> resetData() async {
    await _p.remove('db');
    _db = {'users': [], 'doctors': [], 'appointments': []};
    ApiClient.instance.token = null;
    _seed();
  }

  void _save() => _p.setString('db', jsonEncode(_db));

  String _id() {
    final r = Random.secure();
    return List.generate(12, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  String _hash(String pw, String salt) => sha256.convert(utf8.encode('$salt:$pw')).toString();

  Map _addUser(String email, String name, String role, String pw, [Map<String, dynamic>? extra]) {
    final salt = _id();
    final u = <String, dynamic>{'_id': _id(), 'name': name, 'email': email, 'role': role, 'salt': salt, 'passwordHash': _hash(pw, salt), 'allergies': [], 'medicalHistory': [], 'createdAt': DateTime.now().toIso8601String(), ...?extra};
    _users.add(u);
    return u;
  }

  // Sample accounts + doctors (fictional), created on first launch.
  void _seed() {
    _addUser('admin@mediconnect.app', 'Admin', 'admin', 'Admin@123');
    _addUser('patient@mediconnect.app', 'Demo Patient', 'patient', 'Patient@123', {'age': 29, 'gender': 'Female', 'bloodGroup': 'O+', 'allergies': ['Penicillin'], 'medicalHistory': ['Asthma (mild)'], 'phone': '+910000000000'});
    const docs = <List<Object>>[
      ['Dr. Aisha Menon', 'Cardiologist', 12, 700, 4.8, 'MediConnect Heart Centre', true],
      ['Dr. Vikram Shah', 'General Physician', 8, 400, 4.6, 'MediConnect Clinic', true],
      ['Dr. Nisha Pillai', 'Pediatrician', 15, 500, 4.9, 'MediConnect Children Care', false],
      ['Dr. Arjun Rao', 'Orthopedic', 10, 650, 4.5, 'MediConnect Ortho Wing', true],
      ['Dr. Priya Nair', 'Neurologist', 11, 800, 4.7, 'MediConnect Neuro Institute', false],
      ['Dr. Sameer Khan', 'Dermatologist', 6, 450, 4.4, 'MediConnect Skin Clinic', true],
      ['Dr. Lakshmi Iyer', 'Gynecologist', 14, 600, 4.8, 'MediConnect Women Care', true],
      ['Dr. Kabir Das', 'Gastroenterologist', 9, 700, 4.5, 'MediConnect Digestive Care', false],
    ];
    for (final d in docs) {
      final name = d[0] as String;
      final email = 'dr.${name.replaceFirst('Dr. ', '').toLowerCase().replaceAll(' ', '.')}@mediconnect.app';
      final u = _addUser(email, name, 'doctor', 'Doctor@123');
      _doctors.add({'_id': _id(), 'user': u['_id'], 'specialty': d[1], 'experienceYears': d[2], 'fee': d[3], 'rating': d[4], 'hospital': d[5], 'isAvailableNow': d[6]});
    }
    _save();
  }

  Map? _find(List l, dynamic id) {
    for (final e in l) {
      if (e['_id'] == id) return e as Map;
    }
    return null;
  }

  Map _auth([String? role]) {
    final u = _find(_users, ApiClient.instance.token);
    if (u == null) throw ApiException(401, 'Please sign in');
    if (role != null && u['role'] != role) throw ApiException(403, 'Insufficient permissions');
    return u;
  }

  Map _clean(Map u) => Map<String, dynamic>.from(u)..remove('passwordHash')..remove('salt');

  Map _doctorView(Map d) => {...d, 'user': {'_id': d['user'], 'name': _find(_users, d['user'])?['name'] ?? 'Doctor'}};

  Map _populate(Map a) {
    final d = _find(_doctors, a['doctor']);
    final p = _find(_users, a['patient']);
    return {
      ...a,
      'doctor': d == null ? null : {'_id': d['_id'], 'specialty': d['specialty'], 'user': {'name': _find(_users, d['user'])?['name'] ?? 'Doctor'}},
      'patient': p == null ? null : {'_id': p['_id'], 'name': p['name']},
    };
  }

  /// Handles the same routes the Node backend exposes.
  Future<dynamic> handle(String method, String path, [Map? body]) async {
    final b = body ?? {};
    final uri = Uri.parse(path);
    final s = uri.pathSegments;
    if (s.isEmpty) throw ApiException(404, 'Not found');

    if (s[0] == 'auth') {
      if (method == 'POST' && s[1] == 'login') {
        final email = (b['email'] ?? '').toString().trim().toLowerCase();
        final u = _users.cast<Map>().where((x) => x['email'] == email).firstOrNull;
        if (u == null || _hash((b['password'] ?? '').toString(), u['salt']) != u['passwordHash']) throw ApiException(401, 'Invalid credentials');
        return {'token': u['_id'], 'name': u['name'], 'role': u['role']};
      }
      if (method == 'POST' && s[1] == 'register') {
        final name = (b['name'] ?? '').toString().trim(), email = (b['email'] ?? '').toString().trim().toLowerCase(), pw = (b['password'] ?? '').toString();
        if (name.isEmpty || email.isEmpty || pw.isEmpty) throw ApiException(400, 'Name, email and password are required');
        if (_users.any((x) => x['email'] == email)) throw ApiException(400, 'Email already registered');
        final u = _addUser(email, name, 'patient', pw); // sign-up is always a patient
        _save();
        return {'token': u['_id'], 'name': u['name'], 'role': u['role']};
      }
      if (s[1] == 'me') {
        final u = _auth();
        if (method == 'PATCH') {
          for (final k in ['name', 'phone', 'age', 'gender', 'bloodGroup', 'allergies', 'medicalHistory', 'emergencyContacts']) {
            if (b[k] != null) u[k] = b[k];
          }
          _save();
        }
        return _clean(u);
      }
    }

    if (s[0] == 'doctors') {
      if (method == 'GET') {
        final q = uri.queryParameters;
        var list = _doctors.cast<Map>().toList();
        if (q['specialty'] != null) list = list.where((d) => d['specialty'] == q['specialty']).toList();
        if (q['minExperience'] != null) list = list.where((d) => d['experienceYears'] >= num.parse(q['minExperience']!)).toList();
        if (q['maxFee'] != null) list = list.where((d) => d['fee'] <= num.parse(q['maxFee']!)).toList();
        list.sort((a, c) => (c['rating'] as num).compareTo(a['rating'] as num));
        return list.map(_doctorView).toList();
      }
      if (method == 'PATCH' && s.length == 3 && s[1] == 'me') {
        final u = _auth('doctor');
        final d = _doctors.cast<Map>().where((x) => x['user'] == u['_id']).firstOrNull;
        if (d == null) throw ApiException(404, 'Doctor profile not found');
        d['isAvailableNow'] = b['isAvailableNow'] == true;
        _save();
        return _doctorView(d);
      }
    }

    if (s[0] == 'appointments') {
      final u = _auth();
      if (method == 'GET') {
        List<Map> list;
        if (u['role'] == 'doctor') {
          final d = _doctors.cast<Map>().where((x) => x['user'] == u['_id']).firstOrNull;
          list = _appts.cast<Map>().where((a) => d != null && a['doctor'] == d['_id']).toList();
        } else if (u['role'] == 'admin') {
          list = _appts.cast<Map>().toList();
        } else {
          list = _appts.cast<Map>().where((a) => a['patient'] == u['_id']).toList();
        }
        list.sort((a, c) => DateTime.parse(a['dateTime']).compareTo(DateTime.parse(c['dateTime'])));
        return list.map(_populate).toList();
      }
      if (method == 'POST') {
        final d = _find(_doctors, b['doctor']);
        if (d == null) throw ApiException(404, 'Doctor not found');
        final when = DateTime.tryParse((b['dateTime'] ?? '').toString());
        if (when == null) throw ApiException(400, 'Invalid date/time');
        final a = {'_id': _id(), 'patient': u['_id'], 'doctor': d['_id'], 'dateTime': when.toUtc().toIso8601String(), 'status': 'upcoming', 'fee': d['fee'], 'createdAt': DateTime.now().toIso8601String()};
        _appts.add(a);
        _save();
        return _populate(a);
      }
      if (method == 'PATCH' && s.length == 3) {
        final a = _appts.cast<Map>().where((x) => x['_id'] == s[1] && x['patient'] == u['_id']).firstOrNull;
        if (a == null) throw ApiException(404, 'Appointment not found');
        if (s[2] == 'cancel') a['status'] = 'cancelled';
        if (s[2] == 'reschedule') {
          final when = DateTime.tryParse((b['dateTime'] ?? '').toString());
          if (when == null) throw ApiException(400, 'Invalid date/time');
          a['dateTime'] = when.toUtc().toIso8601String();
          a['status'] = 'upcoming';
        }
        _save();
        return _populate(a);
      }
    }

    if (s[0] == 'admin' && s.length > 1 && s[1] == 'stats') {
      _auth('admin');
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day), end = start.add(const Duration(days: 1));
      final live = _appts.cast<Map>().where((a) => a['status'] != 'cancelled');
      return {
        'doctors': _doctors.length,
        'patients': _users.where((u) => u['role'] == 'patient').length,
        'appointments': _appts.length,
        'appointmentsToday': _appts.cast<Map>().where((a) {
          final t = DateTime.parse(a['dateTime']).toLocal();
          return !t.isBefore(start) && t.isBefore(end);
        }).length,
        'revenue': live.fold<num>(0, (sum, a) => sum + (a['fee'] as num)),
      };
    }

    if (s[0] == 'ai' && s.length > 1) {
      _auth();
      return _ai(s[1], b);
    }
    throw ApiException(404, 'Not found');
  }

  // ---------------- AI (direct to Groq with the user's own key) ----------------
  Future<String> _groq(String system, List msgs, {bool json = true}) async {
    if (groqKey.isEmpty) throw ApiException(503, 'Add your Groq key in AI Settings');
    final res = await http
        .post(Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {'Authorization': 'Bearer $groqKey', 'Content-Type': 'application/json'},
            body: jsonEncode({'model': groqModel, 'messages': [{'role': 'system', 'content': system}, ...msgs], if (json) 'response_format': {'type': 'json_object'}}))
        .timeout(const Duration(seconds: 25));
    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) throw ApiException(res.statusCode, (data['error']?['message'] ?? 'Groq error').toString());
    return data['choices'][0]['message']['content'].toString();
  }

  Future<dynamic> _ai(String route, Map b) async {
    switch (route) {
      case 'chat':
        return {'reply': await _groq('You are MediBot, a friendly, careful healthcare assistant. Give general guidance, not diagnoses, and tell users to seek urgent care for red-flag symptoms.', [{'role': 'user', 'content': '${b['question']}'}], json: false)};
      case 'symptom-check':
        return jsonDecode(await _groq('You are a careful medical triage assistant. Given symptoms, age and gender, respond ONLY with JSON: {"possibleConditions": string[], "severity": "Mild"|"Moderate"|"Severe", "suggestedSpecialist": string}. Never give a definitive diagnosis — these are possibilities for a human doctor to confirm.', [{'role': 'user', 'content': 'Symptoms: ${b['symptoms']}. Age: ${b['age']}. Gender: ${b['gender']}.'}]));
      case 'explain-prescription':
        return jsonDecode(await _groq('You explain prescriptions in plain language. Respond ONLY with JSON: {"medicineName": string, "purpose": string, "dosage": string, "sideEffects": string[], "precautions": string[]}.', [{'role': 'user', 'content': 'Medicine: ${b['medicineName']}. Prescribed as: ${b['dosageText'] ?? 'not specified'}.'}]));
      case 'recommend-doctor':
        return jsonDecode(await _groq('You are a doctor-matching assistant for a hospital app. Respond ONLY with JSON: {"specialty": string, "reasoning": string}.', [{'role': 'user', 'content': 'Symptoms: ${b['symptoms']}. Medical history: ${((b['medicalHistory'] ?? []) as List).join(', ')}.'}]));
      case 'analyze-report':
        return jsonDecode(await _groq('You are a medical report summarizer. Respond ONLY with JSON: {"summary": string, "abnormalFindings": string[], "recommendations": string[]}. Be cautious and conservative.', [{'role': 'user', 'content': '${b['extractedText']}'}]));
      case 'doctor':
        final pt = (b['patient'] ?? {}) as Map;
        final system = 'You are Dr. Medi, a warm AI health assistant speaking to a patient by voice. You are NOT a licensed doctor and cannot diagnose or prescribe. '
            'Keep replies under 90 words, in simple spoken language, no lists or markdown. Ask one clarifying question at a time (duration, severity 1-10, other symptoms, pregnancy, age, current medicines) when needed. '
            'For minor, self-limiting symptoms you MAY mention commonly used over-the-counter options in general terms (for example paracetamol for fever or pain, oral rehydration solution for diarrhea, saline or honey for cough in adults) '
            'but ALWAYS: check the patient allergies and conditions below and avoid anything that conflicts; tell them to follow the product label or ask a pharmacist for the dose; NEVER give numeric doses for children or infants; '
            'NEVER suggest antibiotics, steroids, opioids, sedatives, or any prescription-only medicine; say to see a doctor if symptoms last more than 2-3 days or get worse. '
            'If there are red flags (chest pain, trouble breathing, stroke signs, severe bleeding, fainting, seizure, severe allergic reaction, thoughts of self-harm, overdose) set urgent to true and tell them to call emergency services or use the alarm button now. '
            'Also include "medicines": up to 3 general over-the-counter options relevant to what the patient has told you so far, each {"name": string, "purpose": few words, "caution": few words}, with NO doses; update this list every turn as you learn more; use an empty array if there are red flags, if you are unsure, or if a doctor should see them first. '
            'Respond ONLY with JSON: {"reply": string, "urgent": boolean, "medicines": array}. '
            'Patient: age ${pt['age'] ?? 'unknown'}, gender ${pt['gender'] ?? 'unknown'}, allergies: ${((pt['allergies'] ?? []) as List).join(', ')}, conditions: ${((pt['conditions'] ?? []) as List).join(', ')}.';
        final all = (b['messages'] ?? []) as List;
        final hist = all.skip(all.length > 10 ? all.length - 10 : 0).map((m) => {'role': m['role'] == 'assistant' ? 'assistant' : 'user', 'content': '${m['content']}'.substring(0, min(1000, '${m['content']}'.length))}).toList();
        final out = jsonDecode(await _groq(system, hist)) as Map;
        final meds = ((out['medicines'] is List ? out['medicines'] : []) as List).take(3).map((m) => {'name': '${m['name'] ?? ''}', 'purpose': '${m['purpose'] ?? ''}', 'caution': '${m['caution'] ?? ''}'}).toList();
        return {'reply': '${out['reply'] ?? ''}', 'urgent': out['urgent'] == true, 'medicines': meds};
    }
    throw ApiException(404, 'Not found');
  }
}
