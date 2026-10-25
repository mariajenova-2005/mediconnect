import 'package:flutter/material.dart';
import '../../widgets/art3d.dart';
import '../../services/api_client.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(height: 260, decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.deepBlue, AppColors.primaryBlue], begin: Alignment.topLeft, end: Alignment.bottomRight))),
          const Positioned(top: 0, left: 0, right: 0, height: 260, child: TwinBackdrop()),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Admin Control Center', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const Text('MediConnect AI+ · Platform Overview', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 18),
                GlassCard(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _adminStats(),
                    builder: (_, s) {
                      final d = s.data ?? {};
                      return Row(children: [
                        _StatBlock(label: 'Doctors', value: '${d['doctors'] ?? '–'}'),
                        _StatBlock(label: 'Patients', value: '${d['patients'] ?? '–'}'),
                        _StatBlock(label: "Today's Appts", value: '${d['appointmentsToday'] ?? '–'}'),
                      ]);
                    },
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.card3d),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Booked Revenue', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      FutureBuilder<Map<String, dynamic>>(future: _adminStats(), builder: (_, s) => Text('₹ ${s.data?['revenue'] ?? '–'}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.accentGreen))),
                      const SizedBox(height: 14),
                      SizedBox(height: 90, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(7, (i) {
                        final h = 22.0 + (i * 9) % 60;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedContainer(duration: Duration(milliseconds: 400 + i * 80), height: h, decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(8))),
                          ),
                        );
                      }))),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 20),
                const Text('Manage', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.3,
                  children: [
                    _ManageTile(icon: Icons.medical_services_rounded, label: 'Doctors', color: AppColors.primaryBlue),
                    _ManageTile(icon: Icons.groups_rounded, label: 'Patients', color: AppColors.accentGreen),
                    _ManageTile(icon: Icons.event_note_rounded, label: 'Appointments', color: AppColors.moderate),
                    _ManageTile(icon: Icons.bar_chart_rounded, label: 'Analytics', color: AppColors.deepBlue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label, value;
  const _StatBlock({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _ManageTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ManageTile({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.card3d),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon3D(icon: icon, color: color, size: 42),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> _adminStats() async {
  try {
    return Map<String, dynamic>.from(await ApiClient.instance.get('/admin/stats'));
  } catch (_) {
    return {};
  }
}
