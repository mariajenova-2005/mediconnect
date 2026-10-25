import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'gesture_sos_screen.dart';

class GestureCameraScreen extends StatelessWidget {
  const GestureCameraScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Gesture SOS')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.videocam_off_rounded, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 14),
            const Text('Camera gesture detection works in the Android / iOS app.', textAlign: TextAlign.center),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GestureSOSScreen())), child: const Text('Use tap mode')),
          ]),
        ),
      );
}
