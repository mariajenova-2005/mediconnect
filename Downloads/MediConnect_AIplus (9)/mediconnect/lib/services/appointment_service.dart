import '../models/extra_models.dart';
import 'api_client.dart';

/// Appointments are stored in the backend. The local list is a cache the screens read;
/// book/cancel/reschedule update it instantly and sync to the server.
class AppointmentService {
  AppointmentService._internal();
  static final AppointmentService instance = AppointmentService._internal();

  final List<Appointment> _appointments = [
    Appointment(id: 'a1', doctorName: 'Dr. Aisha Menon', specialty: 'Cardiologist', dateTime: DateTime.now().add(const Duration(days: 1, hours: 2)), status: AppointmentStatus.upcoming, fee: 700),
  ];

  bool _isId(String id) => RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id);

  Appointment _from(Map j) {
    final doc = (j['doctor'] ?? {}) as Map;
    final user = (doc['user'] ?? {}) as Map;
    return Appointment(
      id: j['_id'].toString(),
      doctorName: (user['name'] ?? 'Doctor').toString(),
      specialty: (doc['specialty'] ?? '').toString(),
      dateTime: DateTime.parse(j['dateTime'].toString()).toLocal(),
      status: AppointmentStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => AppointmentStatus.upcoming),
      fee: ((j['fee'] ?? 0) as num).toDouble(),
    );
  }

  Future<void> refresh() async {
    try {
      final d = await ApiClient.instance.get('/appointments') as List;
      _appointments
        ..clear()
        ..addAll(d.map((j) => _from(j as Map)));
    } catch (_) {}
  }

  /// Doctor's live queue (patients booked with the logged-in doctor).
  Future<List<Map<String, String>>> doctorQueue() async {
    try {
      final d = await ApiClient.instance.get('/appointments') as List;
      return d.where((j) => j['status'] == 'upcoming').map<Map<String, String>>((j) {
        final t = DateTime.parse(j['dateTime'].toString()).toLocal();
        final hh = t.hour % 12 == 0 ? 12 : t.hour % 12;
        return {'name': (((j['patient'] ?? {}) as Map)['name'] ?? 'Patient').toString(), 'issue': 'Appointment · ₹${j['fee'] ?? ''}', 'time': '${t.day}/${t.month} $hh:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'AM' : 'PM'}'};
      }).toList();
    } catch (_) {
      return [
        {'name': 'Sample Patient', 'issue': 'Demo appointment', 'time': 'Now'},
      ];
    }
  }

  List<Appointment> getAppointments() => List.unmodifiable(_appointments);

  List<String> getAvailableSlots(DateTime day) => ['09:00 AM', '10:30 AM', '11:15 AM', '02:00 PM', '03:30 PM', '05:00 PM'];

  Appointment book({String? doctorId, required String doctorName, required String specialty, required DateTime dateTime, required double fee}) {
    final appt = Appointment(id: 'local${_appointments.length + 1}', doctorName: doctorName, specialty: specialty, dateTime: dateTime, status: AppointmentStatus.upcoming, fee: fee);
    _appointments.add(appt);
    if (doctorId != null && _isId(doctorId)) {
      ApiClient.instance.post('/appointments', {'doctor': doctorId, 'dateTime': dateTime.toUtc().toIso8601String()}).then((_) => refresh()).catchError((_) {});
    }
    return appt;
  }

  void _replace(String id, Appointment Function(Appointment) f) {
    final i = _appointments.indexWhere((a) => a.id == id);
    if (i != -1) _appointments[i] = f(_appointments[i]);
  }

  void cancel(String id) {
    _replace(id, (a) => Appointment(id: a.id, doctorName: a.doctorName, specialty: a.specialty, dateTime: a.dateTime, status: AppointmentStatus.cancelled, fee: a.fee));
    if (_isId(id)) ApiClient.instance.patch('/appointments/$id/cancel', {}).catchError((_) {});
  }

  void reschedule(String id, DateTime newTime) {
    _replace(id, (a) => Appointment(id: a.id, doctorName: a.doctorName, specialty: a.specialty, dateTime: newTime, status: AppointmentStatus.upcoming, fee: a.fee));
    if (_isId(id)) ApiClient.instance.patch('/appointments/$id/reschedule', {'dateTime': newTime.toUtc().toIso8601String()}).catchError((_) {});
  }
}
