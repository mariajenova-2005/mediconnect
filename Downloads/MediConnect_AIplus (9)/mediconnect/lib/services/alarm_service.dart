import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:volume_controller/volume_controller.dart';

/// Loud emergency siren: loops assets/sounds/siren.wav at full app volume, raises the phone's
/// media volume to maximum (mobile only), and vibrates repeatedly. Restores volume on stop.
/// A phone can never play louder than its maximum volume, and browsers can't change system volume.
class AlarmService {
  AlarmService._();
  static final AlarmService instance = AlarmService._();

  final AudioPlayer _player = AudioPlayer();
  Timer? _vibrate;
  double? _oldVolume;
  bool _on = false;
  bool get isOn => _on;

  Future<void> start() async {
    if (_on) return;
    _on = true;
    try {
      _oldVolume = await VolumeController().getVolume();
      VolumeController().setVolume(1.0, showSystemUI: false);
    } catch (_) {}
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);
      await _player.play(AssetSource('sounds/siren.wav'));
    } catch (_) {}
    _vibrate = Timer.periodic(const Duration(milliseconds: 700), (_) => HapticFeedback.vibrate());
  }

  Future<void> stop() async {
    _on = false;
    _vibrate?.cancel();
    try {
      await _player.stop();
    } catch (_) {}
    try {
      if (_oldVolume != null) VolumeController().setVolume(_oldVolume!, showSystemUI: false);
    } catch (_) {}
  }
}
