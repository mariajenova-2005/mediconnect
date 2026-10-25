import 'package:flutter/material.dart';
import '../../widgets/art3d.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/extra_models.dart';
import '../../services/ai_service.dart';

class AISymptomCheckerScreen extends StatefulWidget {
  const AISymptomCheckerScreen({super.key});
  @override
  State<AISymptomCheckerScreen> createState() => _AISymptomCheckerScreenState();
}

class _AISymptomCheckerScreenState extends State<AISymptomCheckerScreen> {
  final _symptoms = TextEditingController();
  final _age = TextEditingController();
  String _gender = 'Female';
  bool _loading = false;
  SymptomCheckResult? _result;

  Future<void> _check() async {
    if (_symptoms.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final r = await AIService.instance.checkSymptoms(symptoms: _symptoms.text, age: int.tryParse(_age.text) ?? 0, gender: _gender);
    setState(() {
      _loading = false;
      _result = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Symptom Checker')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          HeroBanner(title: 'Symptom Checker', subtitle: 'Describe how you feel — get instant AI guidance', icon: Icons.psychology_alt_rounded, colors: [AppColors.primaryBlue, AppColors.accentGreen]),
          const SizedBox(height: 16),
          TextField(controller: _symptoms, maxLines: 3, decoration: const InputDecoration(hintText: 'Describe your symptoms...', prefixIcon: Icon(Icons.healing_rounded))),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: TextField(controller: _age, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Age'))),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: const InputDecoration(),
                  items: ['Female', 'Male', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setState(() => _gender = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _check,
              icon: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.auto_awesome_rounded),
              label: Text(_loading ? 'Analyzing...' : 'Check Symptoms'),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.card3d),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.psychology_alt_rounded, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    const Text('AI Assessment', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ]),
                  const SizedBox(height: 14),
                  const Text('Possible conditions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  ..._result!.possibleConditions.map((c) => Text('• $c')),
                  const SizedBox(height: 14),
                  Row(children: [
                    const Text('Severity: ', style: TextStyle(fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: _severityColor(_result!.severity).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text(_result!.severity, style: TextStyle(color: _severityColor(_result!.severity), fontWeight: FontWeight.w700, fontSize: 12.5)),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Text('Suggested specialist: ${_result!.suggestedSpecialist}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.05, end: 0),
          ],
        ],
      ),
    );
  }

  Color _severityColor(String s) => switch (s) {
        'Severe' => AppColors.severe,
        'Moderate' => AppColors.moderate,
        _ => AppColors.mild,
      };
}
