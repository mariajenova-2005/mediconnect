import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/extra_models.dart';
import '../../services/appointment_service.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});
  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    AppointmentService.instance.refresh().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final appts = AppointmentService.instance.getAppointments().reversed.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: appts.isEmpty
          ? const Center(child: Text('No appointments yet', style: TextStyle(color: AppColors.textMuted)))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: appts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final a = appts[i];
                final color = switch (a.status) {
                  AppointmentStatus.upcoming => AppColors.primaryBlue,
                  AppointmentStatus.completed => AppColors.accentGreen,
                  AppointmentStatus.cancelled => AppColors.textMuted,
                };
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.card3d),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(a.doctorName, style: const TextStyle(fontWeight: FontWeight.w700))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                          child: Text(a.status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      Text(a.specialty, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                      const SizedBox(height: 6),
                      Text('${a.dateTime.day}/${a.dateTime.month}/${a.dateTime.year} · ₹${a.fee.toInt()}', style: const TextStyle(fontSize: 12.5)),
                      if (a.status == AppointmentStatus.upcoming) ...[
                        const SizedBox(height: 10),
                        Row(children: [
                          TextButton(
                            onPressed: () => setState(() => AppointmentService.instance.cancel(a.id)),
                            child: const Text('Cancel', style: TextStyle(color: AppColors.severe)),
                          ),
                          TextButton(
                            onPressed: () => setState(() => AppointmentService.instance.reschedule(a.id, a.dateTime.add(const Duration(days: 1)))),
                            child: const Text('Reschedule +1 day'),
                          ),
                        ]),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: (i * 60).ms);
              },
            ),
    );
  }
}
