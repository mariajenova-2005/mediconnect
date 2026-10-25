import '../models/extra_models.dart';
import '../models/models.dart';
import 'api_client.dart';
import 'appointment_service.dart';
import 'data_service.dart';
import 'sos_service.dart';

/// Real JWT login against the backend. If the backend can't be reached at all, falls back to
/// DEMO MODE (sample data) and sets [demoMode] so the UI can say so.
class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  UserRole? _role;
  String? _name;
  bool _loggedIn = false;
  bool demoMode = false;
  String? lastError;

  bool get isLoggedIn => _loggedIn;
  UserRole? get role => _role;
  String? get name => _name;

  Future<bool> login({required String email, required String password, required UserRole role}) async {
    lastError = null;
    if (email.trim().isEmpty || password.isEmpty) {
      lastError = 'Enter your email and password';
      return false;
    }
    try {
      final d = await ApiClient.instance.post('/auth/login', {'email': email.trim(), 'password': password});
      if (d['role'] != role.name) {
        lastError = 'This is a ${d['role']} account — pick that role above';
        return false;
      }
      await _start(d, role);
      return true;
    } on ApiException catch (e) {
      lastError = e.message;
      return false;
    } catch (_) {
      _startDemo(email, role);
      return true;
    }
  }

  Future<bool> register({required String name, required String email, required String password, required UserRole role}) async {
    lastError = null;
    try {
      final d = await ApiClient.instance.post('/auth/register', {'name': name, 'email': email.trim(), 'password': password, 'role': 'patient'});
      await _start(d, UserRole.patient);
      return true;
    } on ApiException catch (e) {
      lastError = e.message;
      return false;
    } catch (_) {
      _startDemo(email, role);
      _name = name;
      return true;
    }
  }

  Future<void> _start(dynamic d, UserRole role) async {
    ApiClient.instance.token = d['token'];
    _role = role;
    _name = d['name'];
    _loggedIn = true;
    demoMode = false;
    try {
      await _loadProfile();
    } catch (_) {}
    if (role == UserRole.patient) AppointmentService.instance.refresh();
  }

  void _startDemo(String email, UserRole role) {
    ApiClient.instance.token = null;
    _role = role;
    _name = email.split('@').first;
    _loggedIn = true;
    demoMode = true;
  }

  Future<void> _loadProfile() async {
    final u = await ApiClient.instance.get('/auth/me');
    SosService.instance.load(u['emergencyContacts']);
    DataService.instance.setPatient(Patient(
      id: u['_id'],
      name: u['name'],
      age: (u['age'] as num?)?.toInt() ?? 0,
      gender: u['gender'] ?? '—',
      bloodGroup: u['bloodGroup'] ?? '—',
      allergies: List<String>.from(u['allergies'] ?? []),
      medicalHistory: List<String>.from(u['medicalHistory'] ?? []),
      contactNumber: u['phone'] ?? '',
    ));
  }

  void logout() {
    ApiClient.instance.token = null;
    _loggedIn = false;
    _role = null;
    _name = null;
  }
}
