import 'package:flutter/material.dart';
import '../../widgets/art3d.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import 'ai_settings_screen.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/fx.dart';
import '../../widgets/health_score.dart';
import 'hospital_map_screen.dart';
import 'medicine_reminder_screen.dart';
import 'medical_id_screen.dart';
import 'blood_donor_screen.dart';
import 'wellness_screen.dart';
import 'first_aid_screens.dart';
import 'show_to_doctor_screen.dart';
import 'body_pain_map_screen.dart';
import 'doctor_agent_screen.dart';
import 'alarm_screen.dart';
import 'sos_contacts_screen.dart';
import 'find_doctor_screen.dart';
import 'chatbot_screen.dart';
import 'emergency_screen.dart';
import 'patient_records_screen.dart';
import 'my_appointments_screen.dart';
import 'family_dashboard_screen.dart';
import 'ai_symptom_checker_screen.dart';
import 'ai_report_analyzer_screen.dart';
import 'ai_prescription_explainer_screen.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = DataService.instance.getCurrentPatient();
    final tiles = <(String, IconData, List<Color>, Widget)>[
      ('Find Doctor', Icons.medical_services_rounded, [const Color(0xFF0B6E99), const Color(0xFF17C3A2)], const FindDoctorScreen()),
      ('Symptom AI', Icons.psychology_alt_rounded, [const Color(0xFF7F5AF0), const Color(0xFF2CB1BC)], const AISymptomCheckerScreen()),
      ('Report AI', Icons.description_rounded, [const Color(0xFF17C3A2), const Color(0xFF9BE15D)], const AIReportAnalyzerScreen()),
      ('Rx Explainer', Icons.medication_rounded, [const Color(0xFFF5A623), const Color(0xFFF76B1C)], const AIPrescriptionExplainerScreen()),
      ('MediBot', Icons.smart_toy_rounded, [const Color(0xFF053A5F), const Color(0xFF3D9BE9)], const ChatbotScreen()),
      ('Appointments', Icons.event_available_rounded, [const Color(0xFF11998E), const Color(0xFF38EF7D)], const MyAppointmentsScreen()),
      ('Records', Icons.folder_shared_rounded, [const Color(0xFF396AFC), const Color(0xFF2948FF)], const PatientRecordsScreen()),
      ('Family', Icons.family_restroom_rounded, [const Color(0xFFEE0979), const Color(0xFFFF6A00)], const FamilyDashboardScreen()),
      ('Live Map', Icons.map_rounded, [const Color(0xFF00B4DB), const Color(0xFF0083B0)], const HospitalMapScreen()),
      ('Family SOS', Icons.crisis_alert_rounded, [const Color(0xFFE94B4B), const Color(0xFFF5725B)], const SosContactsScreen()),
      ('Medicines', Icons.alarm_rounded, [const Color(0xFF7F5AF0), const Color(0xFFB57BFF)], const MedicineReminderScreen()),
      ('Medical ID', Icons.badge_rounded, [const Color(0xFFD31027), const Color(0xFFEA384D)], const MedicalIdScreen()),
      ('Blood Donors', Icons.bloodtype_rounded, [const Color(0xFFFF416C), const Color(0xFFFF4B2B)], const BloodDonorScreen()),
      ('Wellness', Icons.water_drop_rounded, [const Color(0xFF2193B0), const Color(0xFF6DD5ED)], const WellnessScreen()),
      ('CPR Guide', Icons.favorite_rounded, [const Color(0xFFCB2D3E), const Color(0xFFEF473A)], const CprGuideScreen()),
      ('Stroke Check', Icons.psychology_rounded, [const Color(0xFF4568DC), const Color(0xFFB06AB3)], const StrokeFastScreen()),
      ('Show to Doctor', Icons.fullscreen_rounded, [const Color(0xFF232526), const Color(0xFF414345)], const ShowToDoctorScreen()),
      ('Pain Map', Icons.accessibility_new_rounded, [const Color(0xFF00C9A7), const Color(0xFF0B6E99)], const BodyPainMapScreen()),
      ('Dr. Medi AI', Icons.record_voice_over_rounded, [const Color(0xFF0B6E99), const Color(0xFF17C3A2)], const DoctorAgentScreen()),
      ('Sound Alarm', Icons.campaign_rounded, [const Color(0xFFB00020), const Color(0xFFFF5252)], const AlarmScreen()),
    ];

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(radius: 22, backgroundColor: Colors.white, child: Text(patient.name[0], style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w800))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Hi, ${patient.name.split(' ').first} 👋', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    Text(AuthService.instance.demoMode ? 'Demo mode · backend not connected' : (ApiClient.useLocal ? 'Data stored on this phone' : 'Connected to live data'), style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ]),
                ),
                IconButton(icon: const Icon(Icons.settings_rounded, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiSettingsScreen()))),
              ]).animate().fadeIn(),
              const SizedBox(height: 6),
              const SizedBox(height: 8),
              const VitalsHero(),
              const SizedBox(height: 14),
              const HealthScoreCard().animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 14),
              Row(children: const [
                Expanded(child: _Vital(icon: Icons.monitor_heart_rounded, value: '72', unit: 'bpm')),
                SizedBox(width: 10),
                Expanded(child: _Vital(icon: Icons.air_rounded, value: '98%', unit: 'SpO₂')),
                SizedBox(width: 10),
                Expanded(child: _Vital(icon: Icons.directions_walk_rounded, value: '6.4k', unit: 'steps')),
              ]).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0),
              const SizedBox(height: 20),
              TiltCard3D(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.emergencyGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: AppColors.severe.withOpacity(0.5), blurRadius: 28, offset: const Offset(0, 12))],
                  ),
                  child: Row(children: [
                    const Icon(Icons.sos_rounded, color: Colors.white, size: 34)
                        .animate(onPlay: (c) => c.repeat(reverse: true)).scale(end: const Offset(1.18, 1.18), duration: 800.ms),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Emergency SOS', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                        Text('Severity-based hospital routing · gesture mode', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ]),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                  ]),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15, end: 0),
              const SizedBox(height: 22),
              TiltCard3D(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorAgentScreen())),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0B6E99), Color(0xFF17C3A2)]), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.accentGreen.withOpacity(0.45), blurRadius: 24, offset: const Offset(0, 12))]),
                  child: Row(children: [
                    const DoctorAvatar(size: 84),
                    const SizedBox(width: 12),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Talk to Dr. Medi', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                      SizedBox(height: 3),
                      Text('Your AI doctor — speak your symptoms and hear advice', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ])),
                    Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(Icons.mic_rounded, color: Colors.white)),
                  ]),
                ),
              ).animate().fadeIn(delay: 330.ms).slideY(begin: 0.15, end: 0),
              const SizedBox(height: 22),
              const Text('Explore', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.3,
                children: [
                  for (var i = 0; i < tiles.length; i++)
                    TiltCard3D(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => tiles[i].$4)),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: tiles[i].$3, begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [BoxShadow(color: tiles[i].$3.first.withOpacity(0.45), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: Stack(children: [
                          Positioned(right: -10, bottom: -14, child: Icon(tiles[i].$2, size: 70, color: Colors.white.withOpacity(0.18))),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Icon3D(icon: tiles[i].$2, color: Colors.white, iconColor: tiles[i].$3.last, size: 40),
                            Text(tiles[i].$1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.5)),
                          ]),
                        ]),
                      ),
                    ).animate().fadeIn(delay: (350 + i * 70).ms).slideY(begin: 0.2, end: 0).scale(begin: const Offset(0.92, 0.92)),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Vital extends StatelessWidget {
  final IconData icon;
  final String value, unit;
  const _Vital({required this.icon, required this.value, required this.unit});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12),
      borderRadius: 18,
      child: Column(children: [
        Icon(icon, color: AppColors.softGreen, size: 22),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
        Text(unit, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ]),
    );
  }
}
