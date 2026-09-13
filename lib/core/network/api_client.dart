import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../errors/exceptions.dart';

/// Thin JSON client over the Finder backend.
///
/// Errors are typed: a non-2xx response throws [ApiException] carrying the
/// server message; transport failures (offline, refused, timeout) throw
/// [NetworkException]. A 401 on an authenticated call clears the stored
/// token and invokes [onUnauthorized] so the app can sign the user out.
class ApiClient {
  final String baseUrl;
  final Duration timeout;
  final http.Client _http;
  String? _token;

  /// Called after the token was rejected by the server (401) and cleared.
  VoidCallback? onUnauthorized;

  ApiClient({
    String? baseUrl,
    this.timeout = const Duration(seconds: 10),
    http.Client? httpClient,
  })  : baseUrl = baseUrl ?? AppConfig.apiUrl,
        _http = httpClient ?? http.Client();

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  /// Must be called on application startup to load the persisted JWT.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> get(String path) =>
      _send(path, () => _http.get(_uri(path), headers: _headers()));

  Future<dynamic> post(String path, Map<String, dynamic> body) => _send(
        path,
        () => _http.post(_uri(path), headers: _headers(), body: json.encode(body)),
      );

  Future<dynamic> put(String path, Map<String, dynamic> body) => _send(
        path,
        () => _http.put(_uri(path), headers: _headers(), body: json.encode(body)),
      );

  Future<dynamic> delete(String path) =>
      _send(path, () => _http.delete(_uri(path), headers: _headers()));

  Future<dynamic> deleteWithBody(String path, Map<String, dynamic> body) => _send(
        path,
        () => _http.delete(_uri(path), headers: _headers(), body: json.encode(body)),
      );

  /// Multipart upload of a single file (field `file`) plus text [fields].
  Future<dynamic> uploadFile(
    String path, {
    required Uint8List bytes,
    required String filename,
    Map<String, String> fields = const {},
    Duration uploadTimeout = const Duration(seconds: 90),
  }) {
    return _send(
      path,
      () async {
        final request = http.MultipartRequest('POST', _uri(path))
          ..headers.addAll(_headers()..remove('Content-Type'))
          ..fields.addAll(fields)
          ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
        final streamed = await _http.send(request);
        return http.Response.fromStream(streamed);
      },
      timeout: uploadTimeout,
    );
  }

  Future<dynamic> _send(
    String path,
    Future<http.Response> Function() request, {
    Duration? timeout,
  }) async {
    http.Response response;
    try {
      response = await request().timeout(timeout ?? this.timeout);
    } on TimeoutException {
      throw const NetworkException(
        'The server took too long to respond. Check your connection and try again.',
      );
    } on http.ClientException {
      throw NetworkException(_offlineMessage());
    } catch (e) {
      // SocketException and platform-specific transport errors end up here.
      throw NetworkException(_offlineMessage());
    }
    return _handleResponse(path, response);
  }

  String _offlineMessage() =>
      kDebugMode
          ? 'Could not reach the server at $baseUrl. Is the backend running?'
          : 'Could not reach the server. Check your connection and try again.';

  dynamic _handleResponse(String path, http.Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    }

    final message = _errorMessage(response);
    if (status == 401 && _token != null && !_isLoginPath(path)) {
      // The stored session is no longer valid: forget it and tell the app.
      _token = null;
      SharedPreferences.getInstance().then((p) => p.remove('auth_token'));
      onUnauthorized?.call();
    }
    throw ApiException(status, message);
  }

  static bool _isLoginPath(String path) =>
      path.startsWith('/auth/login') ||
      path.startsWith('/auth/signup') ||
      path.startsWith('/auth/google-login');

  String _errorMessage(http.Response response) {
    try {
      final map = json.decode(response.body);
      if (map is Map && map['message'] != null) {
        return map['message'].toString();
      }
    } catch (_) {}
    switch (response.statusCode) {
      case 400:
        return 'The request was not valid.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'You are not allowed to do that.';
      case 404:
        return 'Not found.';
      case 500:
        return 'The server ran into a problem. Please try again.';
      default:
        return 'Request failed (${response.statusCode}).';
    }
  }
}
