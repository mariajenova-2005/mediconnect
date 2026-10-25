import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import 'emergency_screen.dart';

/// Gesture-based emergency selection for patients who cannot speak or type
/// (speech/hearing-impaired, or physically unable to use a keyboard).
///
/// 3 deliberately simple, high-contrast, large hit-target gestures map to the
/// 3 severity levels — chosen because they're easy to perform under stress
/// and easy to tell apart on camera:
///   ✊  Closed fist held up        -> SEVERE   (universal "stop/help" sign)
///   ✋  Open palm held up           -> MODERATE
///   👍 Thumbs up                   -> MILD
///
/// HOW THIS IS WIRED HERE (honest scope note):
/// This screen demonstrates the full UX/flow with on-screen tap targets
/// standing in for recognized gestures, so you can see and test the complete
/// journey right away. To make it *real* camera-based hand-gesture
/// recognition on-device, add the `camera` + `google_mlkit_pose_detection`
/// (or a TFLite hand-landmark model) packages, open a CameraController
/// preview, run the detector each frame, and call `_onGestureDetected(...)`
/// with the classified gesture instead of the button's onTap. The detection
/// loop plugs in at the single marked TODO below — everything else
/// (severity routing, navigation, UI) is already live and working.
class GestureSOSScreen extends StatefulWidget {
  const GestureSOSScreen({super.key});
  @override
  State<GestureSOSScreen> createState() => _GestureSOSScreenState();
}

class _GestureSOSScreenState extends State<GestureSOSScreen> {
  Severity? _detected;

  void _onGestureDetected(Severity severity) {
    setState(() => _detected = severity);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => EmergencyScreen(initialSeverity: severity)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlue,
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white, title: const Text('Gesture SOS', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            // Camera preview placeholder — becomes a live CameraController feed
            // once the `camera` package is wired in (see class doc above).
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white24)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded, color: Colors.white.withOpacity(0.5), size: 40),
                    const SizedBox(height: 10),
                    Text(
                      _detected == null ? 'Hold a gesture up to the camera' : 'Gesture recognized: ${_detected!.label}',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    // TODO: replace this Column with a live CameraPreview(controller)
                    // and overlay the detector's output here each frame.
                  ],
                ),
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 26),
            const Text('Tap the matching gesture (demo mode)', style: TextStyle(color: Colors.white60, fontSize: 12.5)),
            const SizedBox(height: 14),
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  _GestureCard(emoji: '✊', label: 'Severe', color: AppColors.severe, onTap: () => _onGestureDetected(Severity.severe)),
                  const SizedBox(width: 12),
                  _GestureCard(emoji: '✋', label: 'Moderate', color: AppColors.moderate, onTap: () => _onGestureDetected(Severity.moderate)),
                  const SizedBox(width: 12),
                  _GestureCard(emoji: '👍', label: 'Mild', color: AppColors.mild, onTap: () => _onGestureDetected(Severity.mild)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GestureCard extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  const _GestureCard({required this.emoji, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(22), border: Border.all(color: color, width: 1.6)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 42)),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 1400.ms, begin: const Offset(1, 1), end: const Offset(1.03, 1.03)),
    );
  }
}
