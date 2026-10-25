import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_client.dart';
import 'location_service.dart';

class SosContact {
  final String name, phone;
  SosContact(this.name, this.phone);
  Map<String, String> toJson() => {'name': name, 'phone': phone};
}

/// Emergency contacts (saved to your account) + live read access to the phone's contact book.
class SosService {
  SosService._();
  static final SosService instance = SosService._();

  final List<SosContact> contacts = [];

  void load(dynamic json) {
    if (json is List) {
      contacts
        ..clear()
        ..addAll(json.map((e) => SosContact(e['name'].toString(), e['phone'].toString())));
    }
  }

  Future<void> save() async {
    try {
      await ApiClient.instance.patch('/auth/me', {'emergencyContacts': contacts.map((c) => c.toJson()).toList()});
    } catch (_) {}
  }

  /// Reads the phone's contacts (asks permission). Returns [] on web/denied.
  Future<List<SosContact>> deviceContacts() async {
    if (kIsWeb) return [];
    try {
      if (!await FlutterContacts.requestPermission(readonly: true)) return [];
      final all = await FlutterContacts.getContacts(withProperties: true);
      return [for (final c in all) if (c.phones.isNotEmpty) SosContact(c.displayName, c.phones.first.number)]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } catch (_) {
      return [];
    }
  }

  /// Fires whenever the phone's contact book changes, so the picker updates in real time.
  void watchDeviceChanges(VoidCallback cb) {
    if (kIsWeb) return;
    try {
      FlutterContacts.addListener(cb);
    } catch (_) {}
  }

  void unwatchDeviceChanges(VoidCallback cb) {
    if (kIsWeb) return;
    try {
      FlutterContacts.removeListener(cb);
    } catch (_) {}
  }

  Future<String> _message() async {
    final p = await LocationService.instance.current();
    final where = p == null ? 'location unavailable' : 'https://www.google.com/maps?q=${p.latitude},${p.longitude}';
    return '🚨 EMERGENCY! I need help urgently. My live location: $where (sent via MediConnect)';
  }

  Future<void> sendSms() async {
    if (contacts.isEmpty) return;
    await launchUrl(Uri(scheme: 'sms', path: contacts.map((c) => c.phone).join(','), queryParameters: {'body': await _message()}));
  }

  Future<void> sendWhatsApp(SosContact c) async {
    final digits = c.phone.replaceAll(RegExp(r'[^0-9]'), '');
    await launchUrl(Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent(await _message())}'), mode: LaunchMode.externalApplication);
  }

  Future<void> call(SosContact c) => launchUrl(Uri(scheme: 'tel', path: c.phone));
}
