import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  static const String _defaultBaseUrl = 'http://10.0.2.2:5000';
  static String? _cachedBaseUrl;
  static String? _authToken;

  static Future<String> get baseUrl async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;
    final prefs = await SharedPreferences.getInstance();
    _cachedBaseUrl = prefs.getString('api_base_url') ?? _defaultBaseUrl;
    return _cachedBaseUrl!;
  }

  static Future<void> setBaseUrl(String url) async {
    final cleanedUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    _cachedBaseUrl = cleanedUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', cleanedUrl);
  }

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint) async {
    final url = await baseUrl;
    final uri = Uri.parse('$url/$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.get(uri, headers: headers);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network connection error: ${e.toString()}');
    }
  }

  static Future<dynamic> post(String endpoint, dynamic body) async {
    final url = await baseUrl;
    final uri = Uri.parse('$url/$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network connection error: ${e.toString()}');
    }
  }

  static Future<dynamic> put(String endpoint, [dynamic body]) async {
    final url = await baseUrl;
    final uri = Uri.parse('$url/$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network connection error: ${e.toString()}');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    final url = await baseUrl;
    final uri = Uri.parse('$url/$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.delete(uri, headers: headers);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network connection error: ${e.toString()}');
    }
  }

  static dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    String errorMessage = 'Request failed with status: ${response.statusCode}';
    try {
      if (response.body.isNotEmpty) {
        final errorData = jsonDecode(response.body);
        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData is Map && errorData.containsKey('title')) {
          errorMessage = errorData['title'];
        }
      }
    } catch (_) {}

    throw ApiException(errorMessage, response.statusCode);
  }
}
