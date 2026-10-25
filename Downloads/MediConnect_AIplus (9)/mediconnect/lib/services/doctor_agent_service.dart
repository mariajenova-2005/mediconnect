import '../models/models.dart';
import 'api_client.dart';

class MedSuggestion {
  final String name, purpose, caution;
  const MedSuggestion(this.name, this.purpose, this.caution);
}

typedef AgentReply = ({String reply, bool urgent, List<MedSuggestion> meds});

/// "Dr. Medi" — conversational AI health assistant (NOT a licensed doctor; never diagnoses or prescribes).
/// Medicine suggestions are general over-the-counter options only, re-evaluated every turn, filtered against
/// the patient's allergies and a block-list of prescription-only drug classes, and never include doses.
class DoctorAgentService {
  DoctorAgentService._();
  static final DoctorAgentService instance = DoctorAgentService._();

  static final _red = RegExp(
      r"chest pain|can'?t breathe|cannot breathe|trouble breathing|shortness of breath|unconscious|passed out|stroke|face droop|slurred|severe bleeding|bleeding heavily|suicid|kill myself|overdose|seizure|choking|allergic reaction|swelling of (the )?(face|throat)",
      caseSensitive: false);
  static final _blocked = RegExp(
      r"antibiotic|amoxicillin|azithromycin|ciprofloxacin|cefixime|cephalexin|doxycycline|metronidazole|penicillin|prednisolone|prednisone|dexamethasone|steroid|tramadol|codeine|morphine|opioid|alprazolam|diazepam|clonazepam|lorazepam|zolpidem|insulin",
      caseSensitive: false);

  String _norm(String s) => s.toLowerCase().replaceAll('acetaminophen', 'paracetamol').trim();

  bool _allergic(String name, Patient p) => p.allergies.any((a) {
        final al = _norm(a), n = _norm(name);
        return al.isNotEmpty && (n.contains(al) || al.contains(n));
      });

  List<MedSuggestion> _safe(List<MedSuggestion> m, Patient p) => m.where((x) => !_blocked.hasMatch(x.name) && !_allergic(x.name, p)).take(3).toList();

  Future<AgentReply> reply(List<Map<String, String>> history, Patient p) async {
    final last = history.isEmpty ? '' : (history.last['content'] ?? '');
    final redFlag = _red.hasMatch(last);
    try {
      final d = await ApiClient.instance.post('/ai/doctor', {
        'messages': history,
        'patient': {'age': p.age, 'gender': p.gender, 'allergies': p.allergies, 'conditions': p.medicalHistory},
      });
      final text = (d['reply'] ?? '').toString();
      if (text.isNotEmpty) {
        final urgent = redFlag || d['urgent'] == true;
        final raw = (d['medicines'] as List? ?? []).map((m) => MedSuggestion((m['name'] ?? '').toString(), (m['purpose'] ?? '').toString(), (m['caution'] ?? 'Follow the label; ask a pharmacist.').toString())).where((m) => m.name.isNotEmpty).toList();
        return (reply: text, urgent: urgent, meds: urgent ? <MedSuggestion>[] : _safe(raw, p));
      }
    } catch (_) {}
    return _offline(last, p, redFlag);
  }

  AgentReply _offline(String q, Patient p, bool red) {
    const tail = " I'm an AI, not a doctor — please confirm with a doctor or pharmacist.";
    if (red) return (reply: "This could be serious. Please call 112 right now, or press the alarm button on this screen. Don't wait.", urgent: true, meds: <MedSuggestion>[]);
    final s = q.toLowerCase();
    const label = 'Follow the label dose; ask a pharmacist if unsure.';
    String r;
    List<MedSuggestion> m = [];
    if (s.contains('fever') || s.contains('temperature') || s.contains('headache') || s.contains('body pain')) {
      r = "Rest and drink plenty of fluids. See a doctor if the fever is above 39 degrees, lasts over 3 days, or you feel very unwell.";
      m = [const MedSuggestion('Paracetamol (acetaminophen)', 'Eases fever and mild pain', 'Avoid with liver problems. $label')];
    } else if (s.contains('cough') || s.contains('cold') || s.contains('sore throat')) {
      r = "Warm fluids, rest and steam can help. Honey in warm water soothes a cough, but not for children under one year. See a doctor if it lasts more than a week or you have trouble breathing.";
      m = [const MedSuggestion('Throat lozenges', 'Soothe a sore throat', 'Not for young children. $label'), const MedSuggestion('Saline nasal spray', 'Relieves a blocked nose', label)];
    } else if (s.contains('diarr') || s.contains('loose motion') || s.contains('vomit')) {
      r = "Sip oral rehydration solution often and eat light foods. See a doctor if you see blood, have a high fever, can't keep fluids down, or it lasts over 2 days.";
      m = [const MedSuggestion('Oral rehydration solution (ORS)', 'Replaces lost fluids and salts', 'Mix exactly as the sachet says.')];
    } else if (s.contains('acidity') || s.contains('heartburn') || s.contains('gas')) {
      r = "Try smaller meals, avoid spicy or oily food, and don't lie down right after eating. See a doctor if it keeps coming back.";
      m = [const MedSuggestion('Antacid', 'Short-term relief of acidity', label)];
    } else if (s.contains('allerg') || s.contains('itch') || s.contains('rash') || s.contains('sneez')) {
      r = "Avoid the likely trigger and keep the skin cool and clean. If you have swelling of the face or trouble breathing, call 112 immediately.";
      m = [const MedSuggestion('Antihistamine (e.g. cetirizine)', 'Eases sneezing and itching', 'Can cause drowsiness. $label')];
    } else {
      r = "I'm listening. How long have you had this, and how bad is it from 1 to 10? Do you have any other symptoms?";
    }
    return (reply: r + tail, urgent: false, meds: _safe(m, p));
  }
}
