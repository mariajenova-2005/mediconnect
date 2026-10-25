import 'package:flutter/material.dart';
import '../../widgets/art3d.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';
import 'book_appointment_screen.dart';

class FindDoctorScreen extends StatefulWidget {
  const FindDoctorScreen({super.key});
  @override
  State<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends State<FindDoctorScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a Doctor')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
          HeroBanner(title: 'Find a Doctor', subtitle: 'Live availability — connect or book a slot', icon: Icons.medical_services_rounded, colors: [AppColors.primaryBlue, AppColors.accentGreen]),
          const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(hintText: 'Search specialty or name...', prefixIcon: Icon(Icons.search_rounded)),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: StreamBuilder<List<Doctor>>(
                stream: DataService.instance.watchDoctors(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final doctors = snap.data!.where((d) => d.name.toLowerCase().contains(_query) || d.specialty.toLowerCase().contains(_query)).toList();
                  return ListView.separated(
                    itemCount: doctors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _DoctorCard(doctor: doctors[i]).animate().fadeIn(delay: (i * 60).ms).slideX(begin: 0.05, end: 0),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.card3d),
      child: Row(
        children: [
          Avatar3D(radius: 28, label: doctor.name.split(' ').last[0]),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text('${doctor.specialty} · ${doctor.experienceYears} yrs', style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF5A623), size: 16),
                    Text(' ${doctor.rating}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (doctor.isAvailableNow ? AppColors.mild : AppColors.textMuted).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        doctor.isAvailableNow ? '● Online now' : 'Offline',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: doctor.isAvailableNow ? AppColors.mild : AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: doctor.isAvailableNow ? () => _showConnectSheet(context, doctor) : null,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), backgroundColor: AppColors.accentGreen),
                child: const Text('Connect', style: TextStyle(fontSize: 12.5)),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookAppointmentScreen(doctor: doctor))),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Book slot', style: TextStyle(fontSize: 11.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConnectSheet(BuildContext context, Doctor doctor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(26),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.video_call_rounded, color: AppColors.primaryBlue, size: 48).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            Text('Connecting you to ${doctor.name}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            const Text('No waiting room — you\'ll be connected directly, skipping the queue.', style: TextStyle(color: AppColors.textMuted), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Live call with ${doctor.name} starting…'), backgroundColor: AppColors.accentGreen));
                },
                child: const Text('Start Instant Call'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
