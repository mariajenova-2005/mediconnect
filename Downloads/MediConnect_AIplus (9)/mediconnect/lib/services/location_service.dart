import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import 'data_service.dart';

/// Real GPS + real nearby hospitals (OpenStreetMap Overpass API — free, no key).
/// Everything here is live: positions stream as you move, and the hospital list refreshes
/// when you move ~500 m or every 90 s. Falls back to sample hospitals if location is unavailable.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  static const _settings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);

  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }

  Future<Position?> current() async {
    try {
      if (!await _ensurePermission()) return null;
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (_) {
      return null;
    }
  }

  /// Live position updates (first value is the current fix).
  Stream<Position> positionStream() async* {
    if (!await _ensurePermission()) return;
    final first = await current();
    if (first != null) yield first;
    yield* Geolocator.getPositionStream(locationSettings: _settings);
  }

  Stream<String> watchLabel() async* {
    if (!await _ensurePermission()) {
      yield 'Location off or denied — showing sample hospitals';
      return;
    }
    yield* positionStream().map((p) => '📍 Live: ${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)} (±${p.accuracy.round()} m)');
  }

  /// Hospital list that keeps itself up to date while you move.
  Stream<List<HospitalInfo>> watchHospitals({double radiusMeters = 8000}) async* {
    Position? anchor;
    DateTime? at;
    var gotAny = false;
    await for (final p in positionStream()) {
      gotAny = true;
      final moved = anchor == null || Geolocator.distanceBetween(anchor.latitude, anchor.longitude, p.latitude, p.longitude) > 500;
      final stale = at == null || DateTime.now().difference(at).inSeconds > 90;
      if (moved || stale) {
        anchor = p;
        at = DateTime.now();
        yield await _hospitalsAt(p, radiusMeters);
      }
    }
    if (!gotAny) yield DataService.instance.getNearbyHospitals();
  }

  Future<List<HospitalInfo>> nearbyHospitals({double radiusMeters = 8000}) async {
    final pos = await current();
    if (pos == null) return DataService.instance.getNearbyHospitals();
return _hospitalsAt(pos, radiusMeters);
  }

  Future<List<HospitalInfo>> _hospitalsAt(Position pos, double radiusMeters) async {
    try {
      final q = '[out:json][timeout:15];(node["amenity"="hospital"](around:$radiusMeters,${pos.latitude},${pos.longitude});'
          'way["amenity"="hospital"](around:$radiusMeters,${pos.latitude},${pos.longitude}););out center 20;';
      final res = await http.post(Uri.parse('https://overpass-api.de/api/interpreter'), body: {'data': q}).timeout(const Duration(seconds: 20));
      final elements = (jsonDecode(res.body)['elements'] as List);
      final list = <HospitalInfo>[];
      for (final e in elements) {
        final tags = (e['tags'] ?? {}) as Map;
        final lat = (e['lat'] ?? e['center']?['lat']) as num?;
        final lng = (e['lon'] ?? e['center']?['lon']) as num?;
        if (lat == null || lng == null) continue;
        final km = Geolocator.distanceBetween(pos.latitude, pos.longitude, lat.toDouble(), lng.toDouble()) / 1000;
        list.add(HospitalInfo(id: e['id'].toString(), name: (tags['name'] ?? 'Hospital').toString(), distanceKm: double.parse(km.toStringAsFixed(1)), lat: lat.toDouble(), lng: lng.toDouble(), hasER: tags['emergency'] == 'yes', etaMinutes: (km / 0.5).ceil().clamp(1, 999)));
      }
      list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return list.isEmpty ? DataService.instance.getNearbyHospitals() : list.take(8).toList();
    } catch (_) {
      return DataService.instance.getNearbyHospitals();
    }
  }

  Future<void> navigate(double lat, double lng) => launchUrl(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving'), mode: LaunchMode.externalApplication);
}
