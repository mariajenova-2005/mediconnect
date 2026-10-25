import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

/// Video call UI shell. To make calls actually connect:
/// `flutter pub add flutter_webrtc socket_io_client`, open a Socket.IO
/// signaling connection to your backend (backend/server.js already has a
/// Socket.IO instance wired for this), exchange SDP offers/answers +
/// ICE candidates between the two peers, then render the remote
/// MediaStream in place of the placeholder below.
class VideoConsultationScreen extends StatefulWidget {
  final String patientName;
  const VideoConsultationScreen({super.key, this.patientName = 'Rahul Verma'});
  @override
  State<VideoConsultationScreen> createState() => _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
  bool _mic = true, _cam = true;
  final List<String> _chat = ['Patient: I\'ve had chest tightness since morning.'];
  final _msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video placeholder
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0B2A3D), Color(0xFF0B6E99)])),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 48, backgroundColor: Colors.white24, child: Text(widget.patientName[0], style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 12),
                    Text(widget.patientName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    const Text('Connecting (WebRTC signaling)...', style: TextStyle(color: Colors.white54, fontSize: 12.5)),
                  ],
                ),
              ),
            ).animate().fadeIn(),
            // Self preview
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
                child: Icon(_cam ? Icons.person_rounded : Icons.videocam_off_rounded, color: Colors.white54),
              ),
            ),
            // Chat overlay
            Positioned(
              left: 16,
              right: 16,
              bottom: 110,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 140),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(14)),
                child: ListView(
                  shrinkWrap: true,
                  children: _chat.map((m) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text(m, style: const TextStyle(color: Colors.white, fontSize: 12.5)))).toList(),
                ),
              ),
            ),
            // Controls
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CallBtn(icon: _mic ? Icons.mic_rounded : Icons.mic_off_rounded, onTap: () => setState(() => _mic = !_mic)),
                  const SizedBox(width: 18),
                  _CallBtn(icon: Icons.call_end_rounded, color: AppColors.severe, onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 18),
                  _CallBtn(icon: _cam ? Icons.videocam_rounded : Icons.videocam_off_rounded, onTap: () => setState(() => _cam = !_cam)),
                  const SizedBox(width: 18),
                  _CallBtn(icon: Icons.chat_bubble_rounded, onTap: () => setState(() => _chat.add('Doctor: Noted, let\'s review your vitals.'))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallBtn extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;
  const _CallBtn({required this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: CircleAvatar(radius: 26, backgroundColor: color ?? Colors.white24, child: Icon(icon, color: Colors.white)),
    );
  }
}
