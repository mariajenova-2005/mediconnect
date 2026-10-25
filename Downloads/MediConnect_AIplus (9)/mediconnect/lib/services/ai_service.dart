import '../models/extra_models.dart';
import 'api_client.dart';

/// All AI features (symptom checker, doctor recommender, report analyzer,
/// prescription explainer) route through here. Every method has a working
/// offline canned response so the UI is fully demoable right now, plus a
/// commented PRODUCTION block showing exactly how to call Groq.
///
/// IMPORTANT: never call Groq (or any LLM API) directly from the Flutter app
/// with an embedded key — proxy through your Express backend
/// (see backend/routes/aiRoutes.js) so the key stays server-side.
class AIService {
  AIService._internal();
  static final AIService instance = AIService._internal();

  // TODO: point at your backend proxy, e.g. https://api.mediconnect.app/api/ai
  static const String endpoint = 'https://your-backend.example.com/api/ai';

  Future<SymptomCheckResult> checkSymptoms({required String symptoms, required int age, required String gender}) async {
    try {
      final d = await ApiClient.instance.post('/ai/symptom-check', {'symptoms': symptoms, 'age': age, 'gender': gender});
      return SymptomCheckResult(possibleConditions: List<String>.from(d['possibleConditions'] ?? []), severity: (d['severity'] ?? 'Mild').toString(), suggestedSpecialist: (d['suggestedSpecialist'] ?? 'General Physician').toString());
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 900));
    final lower = symptoms.toLowerCase();
    if (lower.contains('chest') || lower.contains('breath')) {
      return SymptomCheckResult(possibleConditions: ['Angina', 'Acid reflux', 'Anxiety-related chest tightness'], severity: 'Severe', suggestedSpecialist: 'Cardiologist');
    }
    if (lower.contains('fever') || lower.contains('cough')) {
      return SymptomCheckResult(possibleConditions: ['Viral infection', 'Flu', 'Common cold'], severity: 'Moderate', suggestedSpecialist: 'General Physician');
    }
    return SymptomCheckResult(possibleConditions: ['Non-specific — needs clinical evaluation'], severity: 'Mild', suggestedSpecialist: 'General Physician');

    // PRODUCTION (via your backend, which calls Groq's chat completion API):
    // final res = await http.post(Uri.parse('$endpoint/symptom-check'),
    //   body: jsonEncode({'symptoms': symptoms, 'age': age, 'gender': gender}));
    // return SymptomCheckResult.fromJson(jsonDecode(res.body));
  }

  Future<String> recommendDoctor({required String symptoms, required List<String> medicalHistory}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final lower = symptoms.toLowerCase();
    if (lower.contains('heart') || lower.contains('chest')) return 'Dr. Ananya Rao — Cardiologist (12 yrs experience, 4.8★)';
    if (lower.contains('skin') || lower.contains('rash')) return 'Dr. Rohan Das — Dermatologist (6 yrs experience, 4.4★)';
    if (lower.contains('child') || lower.contains('kid')) return 'Dr. Sneha Pillai — Pediatrician (15 yrs experience, 4.9★)';
    return 'Dr. Karthik Iyer — General Physician (8 yrs experience, 4.6★)';
  }

  Future<ReportAnalysis> analyzeReport({required String fileName}) async {
    await Future.delayed(const Duration(seconds: 1));
    return ReportAnalysis(
      summary: 'Overall lab values are within near-normal range, with two parameters slightly outside the reference interval.',
      abnormalFindings: ['Hemoglobin slightly low (11.2 g/dL)', 'Vitamin D below optimal range'],
      recommendations: ['Iron-rich diet and a follow-up CBC in 4 weeks', 'Consider Vitamin D supplementation after consulting your physician'],
    );
    // PRODUCTION: upload the PDF to your backend, extract text (pdf-parsing),
    // send the extracted text to Groq with a structured-output prompt, return parsed JSON.
  }

  Future<PrescriptionExplanation> explainPrescription({required String medicineName}) async {
    try {
      final d = await ApiClient.instance.post('/ai/explain-prescription', {'medicineName': medicineName});
      return PrescriptionExplanation(medicineName: (d['medicineName'] ?? medicineName).toString(), purpose: (d['purpose'] ?? '').toString(), dosage: (d['dosage'] ?? '').toString(), sideEffects: List<String>.from(d['sideEffects'] ?? []), precautions: List<String>.from(d['precautions'] ?? []));
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 800));
    return PrescriptionExplanation(
      medicineName: medicineName.isEmpty ? 'Amoxicillin 500mg' : medicineName,
      purpose: 'Antibiotic used to treat bacterial infections.',
      dosage: '1 capsule every 8 hours, after food, for 5–7 days.',
      sideEffects: ['Mild nausea', 'Diarrhea', 'Rash (uncommon)'],
      precautions: ['Complete the full course even if you feel better', 'Avoid alcohol', 'Inform your doctor of any penicillin allergy'],
    );
  }
}
