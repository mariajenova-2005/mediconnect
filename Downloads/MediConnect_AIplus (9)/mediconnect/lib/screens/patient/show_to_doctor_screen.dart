import 'package:flutter/material.dart';
import '../../widgets/art3d.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';

/// For patients who can't speak or hear well: pick symptoms, then show the phone to staff.
class ShowToDoctorScreen extends StatefulWidget {
  const ShowToDoctorScreen({super.key});
  @override
  State<ShowToDoctorScreen> createState() => _ShowToDoctorScreenState();
}

class _ShowToDoctorScreenState extends State<ShowToDoctorScreen> {
  static const _all = ['Chest pain', 'Trouble breathing', 'Severe bleeding', 'Head injury', 'Fever', 'Vomiting', 'Stomach pain', 'Dizzy / fainting', 'Allergic reaction', 'Broken bone'];
  final _picked = <String>{};
  double _pain = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Show to Doctor')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
          HeroBanner(title: 'Show to Doctor', subtitle: 'Communicate clearly without speaking', icon: Icons.fullscreen_rounded, colors: [Color(0xFF232526), Color(0xFF0B6E99)]),
          const SizedBox(height: 16),
        const Text('Tap what is wrong, then show your screen to the medical staff.', style: TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final s in _all) FilterChip(label: Text(s), selected: _picked.contains(s), selectedColor: AppColors.accentGreen.withOpacity(0.35), onSelected: (v) => setState(() => v ? _picked.add(s) : _picked.remove(s))),
        ]),
        const SizedBox(height: 18),
        Text('Pain level: ${_pain.round()} / 10', style: const TextStyle(fontWeight: FontWeight.w700)),
        Slider(value: _pain, min: 1, max: 10, divisions: 9, label: '${_pain.round()}', onChanged: (v) => setState(() => _pain = v)),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _picked.isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => _Display(symptoms: _picked.toList(), pain: _pain.round()))),
            icon: const Icon(Icons.fullscreen_rounded),
            label: const Text('Show to staff'),
          ),
        ),
      ]),
    );
  }
}

class _Display extends StatelessWidget {
  final List<String> symptoms;
  final int pain;
  const _Display({required this.symptoms, required this.pain});

  @override
  Widget build(BuildContext context) {
    final p = DataService.instance.getCurrentPatient();
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('PLEASE READ — I HAVE DIFFICULTY SPEAKING OR HEARING', style: TextStyle(color: AppColors.moderate, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (final s in symptoms) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('• $s', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800))),
                  const SizedBox(height: 14),
                  Text('Pain: $pain / 10', style: const TextStyle(color: AppColors.severe, fontSize: 30, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  Text('Blood group: ${p.bloodGroup}', style: const TextStyle(color: Colors.white70, fontSize: 22)),
                  Text('Allergies: ${p.allergies.isEmpty ? 'none known' : p.allergies.join(', ')}', style: const TextStyle(color: Colors.white70, fontSize: 22)),
                ]),
              ),
            ),
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(foregroundColor: Colors.white), child: const Text('Close'))),
          ]),
        ),
      ),
    );
  }
}
