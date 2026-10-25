import 'api_client.dart';

/// Pluggable disease/health Q&A chatbot service.
///
/// Swap-in: point `endpoint` + `apiKey` at any LLM API (Anthropic, OpenAI, etc.)
/// and parse the real response in `_parseReply`. Never hardcode a real API
/// key in client code for production — proxy this call through your own
/// backend / Cloud Function so the key isn't shipped in the app.
class ChatbotService {
  ChatbotService._internal();
  static final ChatbotService instance = ChatbotService._internal();

  // TODO: replace with your backend proxy URL.
  static const String endpoint = 'https://your-backend.example.com/api/chat';

  Future<String> askHealthQuestion(String question) async {
    // --- DEMO fallback (works offline, no key needed) ---
    try {
      final d = await ApiClient.instance.post('/ai/chat', {'question': question});
      final reply = (d['reply'] ?? '').toString();
      if (reply.isNotEmpty) return reply;
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 700));
    return _canned(question);

    // --- PRODUCTION version (uncomment once your backend proxy is live) ---
    // final res = await http.post(
    //   Uri.parse(endpoint),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'question': question}),
    // );
    // return _parseReply(res.body);
  }

  String _canned(String q) {
    final lower = q.toLowerCase();
    if (lower.contains('fever')) {
      return "A fever is your body fighting an infection. Stay hydrated, rest, and monitor your temperature. "
          "See a doctor urgently if it crosses 103°F (39.4°C), lasts more than 3 days, or comes with severe headache, rash, or breathing trouble.";
    }
    if (lower.contains('chest pain')) {
      return "Chest pain can be serious. If it's sudden, crushing, radiates to your arm/jaw, or comes with sweating/shortness of breath, "
          "treat it as an emergency and use the SOS button now — don't wait.";
    }
    if (lower.contains('headache')) {
      return "Most headaches are tension or dehydration related — rest, water, and a dim quiet room help. "
          "A sudden 'worst headache of your life', or one with vision changes or confusion, needs immediate care.";
    }
    if (lower.contains('diabetes')) {
      return "Diabetes is a condition where your body can't regulate blood sugar properly. Key signs: excess thirst, frequent urination, fatigue. "
          "Management involves diet, exercise, and monitoring — a physician can guide a personalized plan.";
    }
    return "Thanks for your question — I'm MediBot, here to give general health guidance (not a diagnosis). "
        "For anything urgent or worsening, please connect with a doctor directly through MediConnect, or use SOS for emergencies.";
  }
}
