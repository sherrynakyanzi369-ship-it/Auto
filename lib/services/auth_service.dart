import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import 'api_client.dart';

/// Authentication backed by the AutoAssist API (PostgreSQL).
///
/// Guests can browse the app, but every service request requires a real
/// account: the JWT issued here is attached to all mutating API calls.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _kTokenKey = 'autoassist_token';
  static const String _kProfileKey = 'autoassist_profile';

  AppUser? _currentUser;
  String? _token;
  String? _lastError;

  AppUser? get currentUser => _currentUser;
  String? get token => _token;
  String get email => _currentUser?.email ?? '';
  String? get lastError => _lastError;

  bool get isAuthenticated => _currentUser != null && (_token?.isNotEmpty ?? false);
  bool get isGuest => !isAuthenticated;

  Future<void> _persist(Map<String, dynamic> payload) async {
    _token = payload['token'] as String?;
    final userJson = payload['user'] as Map<String, dynamic>?;
    _currentUser = userJson == null ? null : AppUser.fromJson(userJson);

    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString(_kTokenKey, _token!);
    if (_currentUser != null) {
      await prefs.setString(_kProfileKey, jsonEncode(_currentUser!.toJson()));
    }
  }

  Future<void> _clear() async {
    _currentUser = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kProfileKey);
  }

  /// Returns `true` on success. On failure [lastError] holds the reason.
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _lastError = null;
    try {
      final payload = await ApiClient.instance.post(
        '/auth/register',
        body: {
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'password': password,
        },
      );
      await _persist(payload as Map<String, dynamic>);
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } on NetworkException catch (e) {
      _lastError = e.message;
      return false;
    }
  }

  /// Returns `true` on success. On failure [lastError] holds the reason.
  Future<bool> login({required String email, required String password}) async {
    _lastError = null;
    try {
      final payload = await ApiClient.instance.post(
        '/auth/login',
        body: {'email': email.trim(), 'password': password},
      );
      await _persist(payload as Map<String, dynamic>);
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } on NetworkException catch (e) {
      _lastError = e.message;
      return false;
    }
  }

  /// Signs in to the shared demo account (created on first use).
  Future<bool> demoLogin() async {
    _lastError = null;
    try {
      final payload = await ApiClient.instance.post('/auth/demo');
      await _persist(payload as Map<String, dynamic>);
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } on NetworkException catch (e) {
      _lastError = e.message;
      return false;
    }
  }

  /// Validates the stored token against the API and refreshes the profile.
  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(_kTokenKey);
    if (storedToken == null || storedToken.isEmpty) return false;
    _token = storedToken;

    final cachedProfile = prefs.getString(_kProfileKey);
    if (cachedProfile != null) {
      try {
        _currentUser =
            AppUser.fromJson(jsonDecode(cachedProfile) as Map<String, dynamic>);
      } catch (_) {
        _currentUser = null;
      }
    }

    try {
      final payload =
          await ApiClient.instance.get('/auth/me', token: _token);
      await _persist(payload as Map<String, dynamic>);
      return true;
    } on ApiException catch (e) {
      if (e.isUnauthorized) await _clear();
      return false;
    } on NetworkException {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null && _token!.isNotEmpty) {
        await ApiClient.instance.post('/auth/logout', token: _token);
      }
    } catch (_) {
      // Logging out locally is enough even if the API is unreachable.
    }
    await _clear();
  }
}
