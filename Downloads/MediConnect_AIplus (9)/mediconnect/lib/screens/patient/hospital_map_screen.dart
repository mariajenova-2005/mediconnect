import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/location_service.dart';

/// Live map: your marker moves in real time, the camera follows you, and hospitals refresh as you travel.
class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({super.key});
  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  final _map = MapController();
  LatLng? _me;
  List<HospitalInfo> _hospitals = [];
  bool _follow = true, _first = true;
  StreamSubscription? _posSub, _hosSub;

  @override
  void initState() {
    super.initState();
    _posSub = LocationService.instance.positionStream().listen((p) {
      final ll = LatLng(p.latitude, p.longitude);
      if (!mounted) return;
      setState(() => _me = ll);
      if (_follow) {
        try {
          _map.move(ll, _first ? 15 : _map.camera.zoom);
          _first = false;
        } catch (_) {}
      }
    });
    _hosSub = LocationService.instance.watchHospitals().listen((h) {
      if (mounted) setState(() => _hospitals = h);
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _hosSub?.cancel();
    super.dispose();
  }

  void _details(HospitalInfo h) => showModalBottomSheet(
        context: context,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(22),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(h.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            Text('${h.distanceKm} km · ETA ${h.etaMinutes} min${h.hasER ? ' · ER available' : ''}', style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => LocationService.instance.navigate(h.lat, h.lng), icon: const Icon(Icons.navigation_rounded), label: const Text('Navigate'))),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Hospital Map')),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: _follow ? AppColors.accentGreen : Colors.white,
        onPressed: () => setState(() {
          _follow = true;
          if (_me != null) _map.move(_me!, 15);
        }),
        child: Icon(Icons.my_location_rounded, color: _follow ? Colors.white : AppColors.primaryBlue),
      ),
      body: Stack(children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: _me ?? const LatLng(13.0827, 80.2707),
            initialZoom: 14,
            onPositionChanged: (cam, hasGesture) {
              if (hasGesture && _follow) setState(() => _follow = false);
            },
          ),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.mediconnect.app'),
            MarkerLayer(markers: [
              if (_me != null) Marker(point: _me!, width: 48, height: 48, child: const Icon(Icons.my_location_rounded, color: AppColors.primaryBlue, size: 36)),
              for (final h in _hospitals) Marker(point: LatLng(h.lat, h.lng), width: 44, height: 44, child: GestureDetector(onTap: () => _details(h), child: const Icon(Icons.local_hospital_rounded, color: AppColors.severe, size: 34))),
            ]),
            const SimpleAttributionWidget(source: Text('© OpenStreetMap contributors')),
          ],
        ),
        Positioned(
          top: 10,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.65), borderRadius: BorderRadius.circular(20)),
            child: Text(_me == null ? 'Locating you…' : '● LIVE · ${_hospitals.length} hospitals nearby', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}
