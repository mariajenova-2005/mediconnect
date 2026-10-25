import 'package:flutter/material.dart';
import '../../widgets/art3d.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/extra_models.dart';
import '../../services/ai_service.dart';

class AIPrescriptionExplainerScreen extends StatefulWidget {
  const AIPrescriptionExplainerScreen({super.key});
  @override
  State<AIPrescriptionExplainerScreen> createState() => _AIPrescriptionExplainerScreenState();
}

class _AIPrescriptionExplainerScreenState extends State<AIPrescriptionExplainerScreen> {
  final _medicine = TextEditingController();
  bool _loading = false;
  PrescriptionExplanation? _result;

  Future<void> _explain() async {
    setState(() => _loading = true);
    final r = await AIService.instance.explainPrescription(medicineName: _medicine.text);
    setState(() {
      _loading = false;
      _result = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Prescription Explainer')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          HeroBanner(title: 'Prescription Explainer', subtitle: 'Know what each medicine does and how to take it', icon: Icons.medication_rounded, colors: [Color(0xFF7F5AF0), Color(0xFF2CB1BC)]),
          const SizedBox(height: 16),
          const Text('Upload a prescription, or just type the medicine name below:', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 12),
          TextField(controller: _medicine, decoration: const InputDecoration(hintText: 'e.g. Amoxicillin 500mg', prefixIcon: Icon(Icons.medication_rounded))),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _explain,
              icon: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.auto_awesome_rounded),
              label: Text(_loading ? 'Explaining...' : 'Explain Prescription'),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_result!.medicineName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 6),
                  Text(_result!.purpose, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 14),
            _InfoCard(icon: Icons.schedule_rounded, title: 'Dosage', color: AppColors.primaryBlue, lines: [_result!.dosage]),
            _InfoCard(icon: Icons.sick_rounded, title: 'Possible Side Effects', color: AppColors.moderate, lines: _result!.sideEffects),
            _InfoCard(icon: Icons.shield_rounded, title: 'Precautions', color: AppColors.accentGreen, lines: _result!.precautions),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<String> lines;
  const _InfoCard({required this.icon, required this.title, required this.color, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.card3d),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w700))]),
          const SizedBox(height: 8),
          ...lines.map((l) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text('• $l', style: const TextStyle(color: AppColors.textMuted)))),
        ],
      ),
    ).animate().fadeIn();
  }
}
