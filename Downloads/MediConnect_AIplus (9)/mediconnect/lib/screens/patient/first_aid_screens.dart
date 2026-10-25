import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

Widget _callButton() => SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => launchUrl(Uri(scheme: 'tel', path: '112')),
        icon: const Icon(Icons.call_rounded),
        label: const Text('Call 112 (ambulance: 108)'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.severe),
      ),
    );

/// Hands-only CPR pacer: pulsing circle + haptic/click at 110 beats per minute.
class CprGuideScreen extends StatefulWidget {
  const CprGuideScreen({super.key});
  @override
  State<CprGuideScreen> createState() => _CprGuideScreenState();
}

class _CprGuideScreenState extends State<CprGuideScreen> with SingleTickerProviderStateMixin {
  static const _beatMs = 545; // 60000 / 110 BPM
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: _beatMs));
  Timer? _t;
  int _count = 0;

  void _beat() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);
    _c.forward(from: 0);
    setState(() => _count++);
  }

  void _toggle() {
    if (_t != null) {
      _t!.cancel();
      setState(() => _t = null);
    } else {
      _count = 0;
      _beat();
      setState(() => _t = Timer.periodic(const Duration(milliseconds: _beatMs), (_) => _beat()));
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final running = _t != null;
    const steps = ['Check: is the person unresponsive and not breathing normally?', 'Call 112 (or send someone) and ask for an AED.', 'Push hard and fast in the centre of the chest — about 5–6 cm deep.', 'Let the chest rise fully between pushes. Keep going until help arrives.'];
    return Scaffold(
      appBar: AppBar(title: const Text('CPR Guide')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Transform.scale(
              scale: running ? 1 + 0.28 * (1 - _c.value) : 1,
              child: Container(
                width: 190,
                height: 190,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.emergencyGradient, boxShadow: [BoxShadow(color: AppColors.severe.withOpacity(0.5), blurRadius: 40, spreadRadius: running ? 6 : 0)]),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(running ? 'PUSH' : 'READY', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  Text('$_count', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  const Text('110 BPM', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _toggle, child: Text(running ? 'Stop' : 'Start compressions'))),
        const SizedBox(height: 10),
        _callButton(),
        const SizedBox(height: 18),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(radius: 13, backgroundColor: AppColors.primaryBlue, child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12))),
              const SizedBox(width: 10),
              Expanded(child: Text(steps[i])),
            ]),
          ),
        const SizedBox(height: 10),
        const Text('A pacing aid only — not a substitute for certified first-aid training.', style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
      ]),
    );
  }
}

/// FAST stroke screening aid.
class StrokeFastScreen extends StatefulWidget {
  const StrokeFastScreen({super.key});
  @override
  State<StrokeFastScreen> createState() => _StrokeFastScreenState();
}

class _StrokeFastScreenState extends State<StrokeFastScreen> {
  final _flags = [false, false, false];
  static const _items = [
    ('Face', 'Ask them to smile. Does one side droop?', Icons.face_rounded),
    ('Arms', 'Raise both arms. Does one drift down or feel weak?', Icons.accessibility_new_rounded),
    ('Speech', 'Is speech slurred, strange, or hard to understand?', Icons.record_voice_over_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final alert = _flags.any((f) => f);
    return Scaffold(
      appBar: AppBar(title: const Text('Stroke FAST Check')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        for (var i = 0; i < 3; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: _flags[i] ? Border.all(color: AppColors.severe, width: 1.6) : null),
            child: SwitchListTile(
              value: _flags[i],
              activeColor: AppColors.severe,
              onChanged: (v) => setState(() => _flags[i] = v),
              secondary: Icon(_items[i].$3, color: AppColors.primaryBlue),
              title: Text(_items[i].$1, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(_items[i].$2),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: (alert ? AppColors.severe : AppColors.mild).withOpacity(0.12), borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(alert ? 'T — Time to call emergency services NOW' : 'No FAST signs selected', style: TextStyle(color: alert ? AppColors.severe : AppColors.mild, fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 6),
            Text(alert ? 'Note the time symptoms started and tell the dispatcher. Do not give food or drink.' : 'If you are still worried, or symptoms are sudden, seek urgent care anyway.'),
            if (alert) ...[const SizedBox(height: 12), _callButton()],
          ]),
        ),
        const SizedBox(height: 10),
        const Text('A screening aid, not a diagnosis.', style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
      ]),
    );
  }
}
