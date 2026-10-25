import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';

class PatientRecordsScreen extends StatelessWidget {
  const PatientRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = DataService.instance.getCurrentPatient();
    return Scaffold(
      appBar: AppBar(title: const Text('My Records')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(22)),
            child: Row(
              children: [
                CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Text(p.name[0], style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 22))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      Text('${p.age} yrs · ${p.gender} · ${p.bloodGroup}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 20),
          _Section(title: 'Allergies', icon: Icons.warning_amber_rounded, color: AppColors.severe, items: p.allergies),
          _Section(title: 'Medical History', icon: Icons.history_rounded, color: AppColors.primaryBlue, items: p.medicalHistory),
          _Section(title: 'Contact', icon: Icons.phone_rounded, color: AppColors.accentGreen, items: [p.contactNumber]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  const _Section({required this.title, required this.icon, required this.color, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.card3d),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w700))]),
          const SizedBox(height: 10),
          ...items.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text('• $e', style: const TextStyle(color: AppColors.textMuted)))),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}
