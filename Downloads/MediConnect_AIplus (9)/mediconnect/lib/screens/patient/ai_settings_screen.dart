import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/local_backend.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});
  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  final _key = TextEditingController(text: LocalBackend.instance.groqKey);
  bool _hide = true;

  @override
  Widget build(BuildContext context) {
    final on = LocalBackend.instance.groqKey.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('AI Settings')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: (on ? AppColors.mild : AppColors.moderate).withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
          child: Text(on ? 'Live AI is ON — Dr. Medi, the chatbot and the checkers use Groq.' : 'Live AI is OFF — the app uses its built-in basic answers. Add a Groq key below for full AI.', style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 16),
        TextField(controller: _key, obscureText: _hide, decoration: InputDecoration(hintText: 'Groq API key (gsk_...)', prefixIcon: const Icon(Icons.key_rounded), suffixIcon: IconButton(icon: Icon(_hide ? Icons.visibility_rounded : Icons.visibility_off_rounded), onPressed: () => setState(() => _hide = !_hide)))),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            await LocalBackend.instance.setGroqKey(_key.text);
            if (!mounted) return;
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved on this phone')));
          },
          child: const Text('Save key'),
        ),
        TextButton(onPressed: () => launchUrl(Uri.parse('https://console.groq.com/keys'), mode: LaunchMode.externalApplication), child: const Text('Get a free key at console.groq.com')),
        const SizedBox(height: 6),
        const Text('The key is stored only on this phone, not encrypted. Anyone with access to your phone could read it, so don\'t publish an APK that has your key inside.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const Divider(height: 40),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.severe),
          icon: const Icon(Icons.delete_forever_rounded),
          label: const Text('Reset all data on this phone'),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Reset everything?'),
              content: const Text('Deletes all accounts, appointments and contacts stored on this phone, then restores the sample data. Please restart the app afterwards.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(
                  onPressed: () async {
                    await LocalBackend.instance.resetData();
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data reset — restart the app')));
                  },
                  child: const Text('Reset', style: TextStyle(color: AppColors.severe)),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
