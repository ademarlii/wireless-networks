import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';
import '../utils/constants.dart';

class ApiClient {
  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    
    if (requireAuth) {
      final token = await SecureStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body, bool requireAuth = true}) async {
    final headers = await _getHeaders(requireAuth: requireAuth);
    return _client.post(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> get(String endpoint, {bool requireAuth = true}) async {
    final headers = await _getHeaders(requireAuth: requireAuth);
    return _client.get(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: headers,
    );
  }
}
