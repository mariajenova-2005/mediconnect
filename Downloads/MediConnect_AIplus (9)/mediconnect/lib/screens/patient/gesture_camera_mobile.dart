import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import 'emergency_screen.dart';
import 'gesture_sos_screen.dart';

/// Live camera + on-device ML Kit pose detection. Arm gestures (easy to see from a distance):
///   🙌 both hands above head  → SEVERE
///   🙋 one hand above head    → MODERATE
///   🙏 hands together at chest → MILD
/// Hold the gesture ~1.5 s to confirm. Needs good light and your upper body in view.
class GestureCameraScreen extends StatefulWidget {
  const GestureCameraScreen({super.key});
  @override
  State<GestureCameraScreen> createState() => _GestureCameraScreenState();
}

class _GestureCameraScreenState extends State<GestureCameraScreen> {
  CameraController? _cam;
  CameraDescription? _desc;
  final _detector = PoseDetector(options: PoseDetectorOptions(mode: PoseDetectionMode.stream));
  bool _busy = false, _done = false;
  int _hold = 0;
  Severity? _cand;
  String _status = 'Starting camera…';
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);
  static const _need = 5;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) return setState(() => _status = 'No camera found');
      _desc = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cams.first);
      final cam = CameraController(_desc!, ResolutionPreset.medium, enableAudio: false, imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888);
      await cam.initialize();
      _cam = cam;
      await cam.startImageStream(_onFrame);
      if (mounted) setState(() => _status = 'Show a gesture to the camera');
    } catch (e) {
      if (mounted) setState(() => _status = 'Camera unavailable — allow camera permission');
    }
  }

  InputImage? _toInput(CameraImage img) {
    final rotation = InputImageRotationValue.fromRawValue(_desc!.sensorOrientation);
    final format = InputImageFormatValue.fromRawValue(img.format.raw);
    if (rotation == null || format == null) return null;
    if (Platform.isAndroid && format != InputImageFormat.nv21) return null;
    if (Platform.isIOS && format != InputImageFormat.bgra8888) return null;
    final plane = img.planes.first;
    return InputImage.fromBytes(bytes: plane.bytes, metadata: InputImageMetadata(size: Size(img.width.toDouble(), img.height.toDouble()), rotation: rotation, format: format, bytesPerRow: plane.bytesPerRow));
  }

  Severity? _gesture(Pose p) {
    PoseLandmark? l(PoseLandmarkType t) {
      final m = p.landmarks[t];
      return (m != null && m.likelihood > 0.5) ? m : null;
    }

    final nose = l(PoseLandmarkType.nose), ls = l(PoseLandmarkType.leftShoulder), rs = l(PoseLandmarkType.rightShoulder);
    final lw = l(PoseLandmarkType.leftWrist), rw = l(PoseLandmarkType.rightWrist);
    final lh = l(PoseLandmarkType.leftHip), rh = l(PoseLandmarkType.rightHip);
    if (nose == null || ls == null || rs == null) return null;
    bool up(PoseLandmark? w) => w != null && w.y < nose.y; // image y grows downward
    if (up(lw) && up(rw)) return Severity.severe;
    if (up(lw) || up(rw)) return Severity.moderate;
    if (lw != null && rw != null) {
      final sw = (ls.x - rs.x).abs(), sy = (ls.y + rs.y) / 2;
      final hy = (lh != null && rh != null) ? (lh.y + rh.y) / 2 : sy + sw * 1.6;
      final close = (lw.x - rw.x).abs() < sw * 0.5;
      final chest = lw.y > sy && lw.y < hy && rw.y > sy && rw.y < hy;
      if (close && chest) return Severity.mild;
    }
    return null;
  }

  Future<void> _onFrame(CameraImage img) async {
    if (_busy || _done) return;
    final now = DateTime.now();
    if (now.difference(_last).inMilliseconds < 250) return;
    _last = now;
    _busy = true;
    try {
      final input = _toInput(img);
      if (input != null) {
        final poses = await _detector.processImage(input);
        final g = poses.isEmpty ? null : _gesture(poses.first);
        if (g != null && g == _cand) {
          _hold++;
        } else {
          _cand = g;
          _hold = g == null ? 0 : 1;
        }
        if (mounted) setState(() => _status = g == null ? 'Show a gesture to the camera' : 'Detected: ${g.label} — hold still');
        if (_hold >= _need && g != null) await _confirm(g);
      }
    } catch (_) {
    } finally {
      _busy = false;
    }
  }

  Future<void> _confirm(Severity sev) async {
    _done = true;
    try {
      await _cam?.stopImageStream();
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => EmergencyScreen(initialSeverity: sev)));
  }

  @override
  void dispose() {
    _cam?.dispose();
    _detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = _cam != null && _cam!.value.isInitialized;
    Widget tip(String e, String t, Color c) => Expanded(child: Container(margin: const EdgeInsets.all(4), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(14), border: Border.all(color: c)), child: Column(children: [Text(e, style: const TextStyle(fontSize: 26)), Text(t, textAlign: TextAlign.center, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700))])));
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white, title: const Text('Gesture SOS', style: TextStyle(color: Colors.white))),
      body: Column(children: [
        Expanded(
          child: Stack(alignment: Alignment.center, children: [
            if (ready) Center(child: AspectRatio(aspectRatio: 1 / _cam!.value.aspectRatio, child: CameraPreview(_cam!))) else const CircularProgressIndicator(),
            Positioned(top: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: Text(_status, style: const TextStyle(color: Colors.white)))),
            if (_hold > 0) SizedBox(width: 90, height: 90, child: CircularProgressIndicator(value: _hold / _need, strokeWidth: 8, color: AppColors.accentGreen)),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(8), child: Row(children: [tip('🙌', 'Both hands up\nSEVERE', AppColors.severe), tip('🙋', 'One hand up\nMODERATE', AppColors.moderate), tip('🙏', 'Hands together\nMILD', AppColors.mild)])),
        TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GestureSOSScreen())), child: const Text('Use tap mode instead', style: TextStyle(color: Colors.white70))),
        const SizedBox(height: 8),
      ]),
    );
  }
}
