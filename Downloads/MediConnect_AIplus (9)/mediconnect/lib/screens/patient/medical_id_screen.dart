import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../services/sos_service.dart';
import '../../widgets/glass_card.dart';

/// Lock-screen-style Medical ID: what a first responder needs in 5 seconds.
class MedicalIdScreen extends StatelessWidget {
  const MedicalIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = DataService.instance.getCurrentPatient();
    final contact = SosService.instance.contacts.isEmpty ? null : SosService.instance.contacts.first;
    Widget section(String t, List<String> items, IconData icon) => Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(icon, color: Colors.white70, size: 16), const SizedBox(width: 6), Text(t.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w700))]),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 6, children: [for (final i in items) Chip(label: Text(i, style: const TextStyle(fontSize: 12)), backgroundColor: Colors.white, side: BorderSide.none, visualDensity: VisualDensity.compact)]),
          ]),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Medical ID')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        TiltCard3D(
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(gradient: AppColors.emergencyGradient, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: AppColors.severe.withOpacity(0.45), blurRadius: 30, offset: const Offset(0, 14))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.medical_information_rounded, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                const Expanded(child: Text('MEDICAL ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.5))),
                Container(width: 64, height: 64, alignment: Alignment.center, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Text(p.bloodGroup, style: const TextStyle(color: AppColors.severe, fontSize: 22, fontWeight: FontWeight.w900))),
              ]),
              const SizedBox(height: 14),
              Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              Text('${p.age} yrs · ${p.gender}', style: const TextStyle(color: Colors.white70)),
              section('Allergies', p.allergies, Icons.warning_amber_rounded),
              section('Conditions', p.medicalHistory, Icons.history_rounded),
            ]),
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.94, 0.94)),
        const SizedBox(height: 16),
        if (contact != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              const Icon(Icons.contact_phone_rounded, color: AppColors.primaryBlue),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Emergency contact', style: TextStyle(color: AppColors.textMuted, fontSize: 12)), Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w700)), Text(contact.phone)])),
              ElevatedButton.icon(onPressed: () => launchUrl(Uri(scheme: 'tel', path: contact.phone)), icon: const Icon(Icons.call_rounded, size: 18), label: const Text('Call'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.mild)),
            ]),
          ).animate().fadeIn(delay: 200.ms),
      ]),
    );
  }
}
