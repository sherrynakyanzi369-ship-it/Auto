import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Thrown when the API responds with a non-2xx status code.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Thrown when the API cannot be reached at all.
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => message;
}

/// Thin JSON client around the AutoAssist FastAPI backend.
///
/// Base URL resolution:
/// - `--dart-define=API_BASE_URL=...` always wins.
/// - Web builds call the API on the same origin under `/api`.
/// - Mobile/desktop builds default to the deployed Vercel backend.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const String _configuredBase = String.fromEnvironment('API_BASE_URL');
  static const String _prodHost =
      'https://web-sherrynakyanzi369-ship-its-projects.vercel.app';

  static String get baseUrl {
    if (_configuredBase.isNotEmpty) return _configuredBase;
    if (kIsWeb) return '/api';
    return '$_prodHost/api';
  }

  final http.Client _client = http.Client();

  static const Duration _timeout = Duration(seconds: 25);

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final String full = '$baseUrl$path';
    Uri uri = full.startsWith('http') ? Uri.parse(full) : Uri.base.resolve(full);
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(
        queryParameters: <String, String>{
          ...uri.queryParameters,
          for (final entry in query.entries)
            if (entry.value != null) entry.key: entry.value.toString(),
        },
      );
    }
    return uri;
  }

  Map<String, String> _headers(String? token) => <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    String? token,
  }) =>
      _send('GET', path, query: query, token: token);

  Future<dynamic> post(
    String path, {
    Object? body,
    String? token,
  }) =>
      _send('POST', path, body: body, token: token);

  Future<dynamic> patch(
    String path, {
    Object? body,
    String? token,
  }) =>
      _send('PATCH', path, body: body, token: token);

  Future<dynamic> delete(
    String path, {
    String? token,
  }) =>
      _send('DELETE', path, token: token);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    String? token,
  }) async {
    final Uri uri = _uri(path, query);
    final String? encodedBody = body == null ? null : jsonEncode(body);

    late final http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: _headers(token))
              .timeout(_timeout);
        case 'POST':
          response = await _client
              .post(uri, headers: _headers(token), body: encodedBody)
              .timeout(_timeout);
        case 'PATCH':
          response = await _client
              .patch(uri, headers: _headers(token), body: encodedBody)
              .timeout(_timeout);
        case 'DELETE':
          response = await _client
              .delete(uri, headers: _headers(token))
              .timeout(_timeout);
        default:
          throw NetworkException('Unsupported method $method');
      }
    } on NetworkException {
      rethrow;
    } catch (_) {
      throw NetworkException(
        'Cannot reach the AutoAssist service. Check your connection and try again.',
      );
    }

    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final String message;
    if (decoded is Map && decoded['detail'] != null) {
      message = decoded['detail'].toString();
    } else {
      message = 'Request failed (${response.statusCode}). Please try again.';
    }
    throw ApiException(response.statusCode, message);
  }
}
