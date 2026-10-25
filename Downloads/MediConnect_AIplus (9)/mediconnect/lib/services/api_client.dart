import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_backend.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  ApiException(this.status, this.message);
  @override
  String toString() => message;
}

/// By default the app uses its built-in backend ([LocalBackend]) — one APK, no server needed.
/// To use the separate Node server instead, run/build with:
///   --dart-define=USE_SERVER=true --dart-define=API_URL=http://<host>:5000/api
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();
  static const useServer = bool.fromEnvironment('USE_SERVER');
  static bool get useLocal => !useServer;
  static const baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:5000/api');

  String? token;
  Map<String, String> get _h => {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};

  Future<dynamic> get(String path) => useLocal ? LocalBackend.instance.handle('GET', path) : _go(http.get(Uri.parse('$baseUrl$path'), headers: _h));
  Future<dynamic> post(String path, Map body) => useLocal ? LocalBackend.instance.handle('POST', path, body) : _go(http.post(Uri.parse('$baseUrl$path'), headers: _h, body: jsonEncode(body)));
  Future<dynamic> patch(String path, Map body) => useLocal ? LocalBackend.instance.handle('PATCH', path, body) : _go(http.patch(Uri.parse('$baseUrl$path'), headers: _h, body: jsonEncode(body)));

  Future<dynamic> _go(Future<http.Response> f) async {
    final r = await f.timeout(const Duration(seconds: 8));
    final data = r.body.isEmpty ? null : jsonDecode(r.body);
    if (r.statusCode >= 400) throw ApiException(r.statusCode, data is Map ? (data['message'] ?? 'Request failed').toString() : 'Request failed');
    return data;
  }
}
