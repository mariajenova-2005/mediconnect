import 'package:flutter/material.dart';
import '../../widgets/art3d.dart';
import '../../widgets/fx.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import 'video_consultation_screen.dart';
import '../../services/api_client.dart';
import '../../services/appointment_service.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});
  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  List<Map<String, String>> _queue = const [];
  bool _online = true;

  @override
  void initState() {
    super.initState();
    AppointmentService.instance.doctorQueue().then((q) {
      if (mounted) setState(() => _queue = q);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon3D(icon: Icons.medical_services_rounded, color: AppColors.deepBlue, size: 52),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr. Ananya Rao', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        Text('Cardiologist · Online', style: TextStyle(color: AppColors.accentGreen, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Switch(value: _online, onChanged: (v) { setState(() => _online = v); ApiClient.instance.patch('/doctors/me/availability', {'isAvailableNow': v}).catchError((_) {}); }, activeColor: AppColors.accentGreen),
                ],
              ).animate().fadeIn(),
              const SizedBox(height: 20),
              Row(
                children: [
                  _StatCard(label: 'Today', value: '12', color: AppColors.primaryBlue),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Waiting', value: _queue.length.toString(), color: AppColors.moderate),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Rating', value: '4.8', color: AppColors.accentGreen),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(18)),
                child: Row(
                  children: const [
                    Icon(Icons.payments_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(child: Text('Earnings this week', style: TextStyle(color: Colors.white70, fontSize: 12.5))),
                    Text('₹ 28,400', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const SizedBox(height: 48, width: double.infinity, child: EcgStrip()),
              const SizedBox(height: 6),
              const Text('Live Patient Queue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: _queue.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final q = _queue[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.card3d),
                      child: Row(
                        children: [
                          CircleAvatar(backgroundColor: AppColors.softGreen, child: Text(q['name']![0], style: const TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(q['name']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                Text(q['issue']!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                              ],
                            ),
                          ),
                          Text(q['time']!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.video_call_rounded, color: AppColors.primaryBlue),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoConsultationScreen(patientName: q['name']!))),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (i * 80).ms).slideX(begin: 0.05, end: 0);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}
