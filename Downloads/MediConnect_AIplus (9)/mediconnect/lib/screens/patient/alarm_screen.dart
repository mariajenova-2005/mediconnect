import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/alarm_service.dart';
import '../../services/location_service.dart';
import '../../services/sos_service.dart';

/// Full-screen flashing emergency alarm: siren + vibration + live location + quick actions.
class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});
  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))..repeat(reverse: true);
  late final Stream<String> _loc = LocationService.instance.watchLabel().asBroadcastStream();

  @override
  void initState() {
    super.initState();
    AlarmService.instance.start();
  }

  @override
  void dispose() {
    AlarmService.instance.stop();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Container(color: Color.lerp(const Color(0xFFB00020), const Color(0xFFFF5252), _c.value), child: child),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Spacer(),
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 100).animate(onPlay: (c) => c.repeat(reverse: true)).scale(end: const Offset(1.2, 1.2), duration: 450.ms),
              const SizedBox(height: 10),
              const Text('EMERGENCY ALARM', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 6),
              const Text('Siren + vibration at maximum volume', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 14),
              StreamBuilder<String>(stream: _loc, builder: (_, s) => Text(s.data ?? 'Locating…', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 13))),
              const Spacer(),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: SosService.instance.sendSms, icon: const Icon(Icons.sms_rounded), label: const Text('Alert my family with my location'), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFB00020)))),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => launchUrl(Uri(scheme: 'tel', path: '112')), icon: const Icon(Icons.call_rounded), label: const Text('Call 112'), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFB00020)))),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.stop_circle_rounded), label: const Text('STOP ALARM'), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20)))),
            ]),
          ),
        ),
      ),
    );
  }
}
