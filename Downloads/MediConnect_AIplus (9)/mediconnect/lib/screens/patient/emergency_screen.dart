import 'package:flutter/material.dart';
import '../../widgets/art3d.dart';
import '../../widgets/fx.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';
import 'gesture_sos_screen.dart';
import 'gesture_camera_screen.dart';
import 'alarm_screen.dart';
import '../../services/location_service.dart';

/// Emergency flow: pick severity -> see best-matched nearby hospitals,
/// ranked by (severity-appropriate) distance/ETA/ER-availability.
///
/// NOTE: `DataService.getNearbyHospitals()` is mock data. To go live, swap it
/// for geolocator's `Geolocator.getCurrentPosition()` + a Google Places
/// "hospitals nearby" request using your Maps API key (see README).
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key, this.initialSeverity});
  final Severity? initialSeverity;
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  late Severity? _severity = widget.initialSeverity;
  late final Stream<List<HospitalInfo>> _hospStream = LocationService.instance.watchHospitals().asBroadcastStream();

  @override
  void initState() {
    super.initState();
    if (widget.initialSeverity == Severity.severe) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlarmScreen())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency SOS')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 96, width: double.infinity, child: Center(child: PulseRadar())),
            Center(child: StreamBuilder<String>(stream: LocationService.instance.watchLabel(), builder: (c, snap) => Text(snap.data ?? 'Locating…', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)))),
            const SizedBox(height: 10),
            const Text('How severe is the situation?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('We\'ll route you to the best-matched hospital instantly.', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 18),
            Row(
              children: [
                _SeverityChip(severity: Severity.mild, color: AppColors.mild, label: 'Mild', selected: _severity == Severity.mild, onTap: () => setState(() => _severity = Severity.mild)),
                const SizedBox(width: 10),
                _SeverityChip(severity: Severity.moderate, color: AppColors.moderate, label: 'Moderate', selected: _severity == Severity.moderate, onTap: () => setState(() => _severity = Severity.moderate)),
                const SizedBox(width: 10),
                _SeverityChip(severity: Severity.severe, color: AppColors.severe, label: 'Severe', selected: _severity == Severity.severe, onTap: () {
                  setState(() => _severity = Severity.severe);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AlarmScreen()));
                }),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlarmScreen())), icon: const Icon(Icons.campaign_rounded), label: const Text('SOUND EMERGENCY ALARM'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.severe, minimumSize: const Size(double.infinity, 52))),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestureCameraScreen())),
              icon: const Icon(Icons.front_hand_rounded),
              label: const Text("Can't speak or type? Use Gesture SOS"),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: AppColors.primaryBlue)),
            ),
            const SizedBox(height: 20),
            if (_severity != null) Expanded(child: _HospitalResults(severity: _severity!, stream: _hospStream)),
          ],
        ),
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  final Severity severity;
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SeverityChip({required this.severity, required this.color, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: selected ? 0 : 1.4),
          ),
          child: Column(
            children: [
              Icon(Icons.warning_rounded, color: selected ? Colors.white : color, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: selected ? Colors.white : color, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HospitalResults extends StatelessWidget {
  final Severity severity;
  final Stream<List<HospitalInfo>> stream;
  const _HospitalResults({required this.severity, required this.stream});

  @override
  Widget build(BuildContext context) => StreamBuilder<List<HospitalInfo>>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return _list(context, snap.data!);
        },
      );

  Widget _list(BuildContext context, List<HospitalInfo> hospitals) {
    // Severe: prioritize ER availability + fastest ETA. Mild/Moderate: prioritize distance.
    final sorted = List<HospitalInfo>.from(hospitals)
      ..sort((a, b) {
        if (severity == Severity.severe) {
          if (a.hasER != b.hasER) return a.hasER ? -1 : 1;
          return a.etaMinutes.compareTo(b.etaMinutes);
        }
        return a.distanceKm.compareTo(b.distanceKm);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recommended hospitals — ${severity.label} case', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final h = sorted[i];
              final best = i == 0;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: best ? Border.all(color: AppColors.accentGreen, width: 1.6) : null,
                  boxShadow: AppShadows.card3d,
                ),
                child: Row(
                  children: [
                    Icon3D(icon: Icons.local_hospital_rounded, color: AppColors.primaryBlue, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Flexible(child: Text(h.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5), overflow: TextOverflow.ellipsis)),
                            if (best) Container(margin: const EdgeInsets.only(left: 6), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.accentGreen, borderRadius: BorderRadius.circular(8)), child: const Text('BEST', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
                          ]),
                          const SizedBox(height: 3),
                          Text('${h.distanceKm} km · ETA ${h.etaMinutes} min${h.hasER ? ' · ER available' : ''}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.navigation_rounded, color: AppColors.accentGreen),
                      onPressed: () => LocationService.instance.navigate(h.lat, h.lng),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (i * 80).ms).slideX(begin: 0.05, end: 0);
            },
          ),
        ),
      ],
    );
  }
}
