// Real camera gestures run on Android/iOS only. Web gets a simple fallback screen.
export 'gesture_camera_stub.dart' if (dart.library.io) 'gesture_camera_mobile.dart';
