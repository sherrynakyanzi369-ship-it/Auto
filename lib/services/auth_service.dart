import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _kUsersKey = 'autoassist_users';
  static const String _kSessionKey = 'autoassist_session';
  static const String _kProfileKey = 'autoassist_profile';

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  String get email => _currentUser?.email ?? '';

  Future<Map<String, String>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUsersKey);
    if (raw == null) return <String, String>{};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }

  Future<void> _saveUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsersKey, jsonEncode(users));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final users = await _loadUsers();
    final key = email.trim().toLowerCase();
    if (users.containsKey(key)) return false;
    users[key] = password;
    await _saveUsers(users);
    _currentUser = AppUser(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfileKey, jsonEncode(_currentUser!.toJson()));
    await prefs.setString(_kSessionKey, _currentUser!.email);
    return true;
  }

  Future<bool> login({required String email, required String password}) async {
    final users = await _loadUsers();
    final key = email.trim().toLowerCase();
    if (users[key] != password) return false;

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_kProfileKey);
    if (cached != null) {
      _currentUser = AppUser.fromJson(jsonDecode(cached) as Map<String, dynamic>);
    } else {
      _currentUser = AppUser(
        name: email.trim().split('@').first,
        email: email.trim(),
        phone: '',
      );
    }
    await prefs.setString(_kSessionKey, _currentUser!.email);
    return true;
  }

  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_kSessionKey);
    if (email == null || email.isEmpty) return false;

    final cached = prefs.getString(_kProfileKey);
    if (cached != null) {
      _currentUser = AppUser.fromJson(jsonDecode(cached) as Map<String, dynamic>);
    } else {
      _currentUser = AppUser(name: email.split('@').first, email: email, phone: '');
    }
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionKey);
    _currentUser = null;
  }
}