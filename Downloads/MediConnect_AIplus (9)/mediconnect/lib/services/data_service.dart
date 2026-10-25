import 'dart:async';
import '../models/models.dart';
import 'api_client.dart';

/// Doctors are fetched from the backend (refreshed every 8 s so availability stays current).
/// Falls back to sample doctors only if the backend is unreachable.
class DataService {
  DataService._internal();
  static final DataService instance = DataService._internal();

  final List<Doctor> _demoDoctors = [
    Doctor(id: 'd1', name: 'Dr. Aisha Menon', specialty: 'Cardiologist', rating: 4.8, isAvailableNow: true, experienceYears: 12, hospital: 'Sample Heart Centre', avatarSeed: 'a', fee: 700),
    Doctor(id: 'd2', name: 'Dr. Vikram Shah', specialty: 'General Physician', rating: 4.6, isAvailableNow: true, experienceYears: 8, hospital: 'Sample Clinic', avatarSeed: 'b', fee: 400),
    Doctor(id: 'd3', name: 'Dr. Nisha Pillai', specialty: 'Pediatrician', rating: 4.9, isAvailableNow: false, experienceYears: 15, hospital: 'Sample Children Care', avatarSeed: 'c', fee: 500),
  ];
  List<Doctor> _last = const [];
  Patient? _patient;

  void setPatient(Patient p) => _patient = p;

  Doctor _doc(Map j) => Doctor(
        id: j['_id'].toString(),
        name: ((j['user'] ?? {}) as Map)['name']?.toString() ?? 'Doctor',
        specialty: (j['specialty'] ?? 'General').toString(),
        rating: ((j['rating'] ?? 4.5) as num).toDouble(),
        isAvailableNow: j['isAvailableNow'] == true,
        experienceYears: (j['experienceYears'] as num?)?.toInt() ?? 0,
        hospital: (j['hospital'] ?? '').toString(),
        avatarSeed: j['_id'].toString(),
        fee: (j['fee'] as num?)?.toDouble() ?? 600,
      );

  Stream<List<Doctor>> watchDoctors() async* {
    if (_last.isNotEmpty) yield _last;
    while (true) {
      try {
        final data = await ApiClient.instance.get('/doctors') as List;
        _last = data.map((j) => _doc(j as Map)).toList();
      } catch (_) {
        if (_last.isEmpty) _last = _demoDoctors;
      }
      yield _last;
      await Future.delayed(const Duration(seconds: 8));
    }
  }

  Patient getCurrentPatient() =>
      _patient ??
      Patient(id: 'demo', name: 'Demo Patient', age: 29, gender: 'Female', bloodGroup: 'O+', allergies: ['Penicillin'], medicalHistory: ['Asthma (mild)'], contactNumber: '+91 00000 00000');

  /// Offline fallback only — live hospitals come from LocationService.
  List<HospitalInfo> getNearbyHospitals() => [
        HospitalInfo(id: 'h1', name: 'Sample Hospital A', distanceKm: 1.8, lat: 13.0569, lng: 80.2425, hasER: true, etaMinutes: 6),
        HospitalInfo(id: 'h2', name: 'Sample Hospital B', distanceKm: 3.2, lat: 13.0244, lng: 80.2585, hasER: true, etaMinutes: 10),
        HospitalInfo(id: 'h3', name: 'Sample Hospital C', distanceKm: 4.1, lat: 13.0423, lng: 80.2337, hasER: false, etaMinutes: 12),
      ];

  void dispose() {}
}
