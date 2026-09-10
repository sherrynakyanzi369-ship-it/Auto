import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/assistance_request.dart';

class AssistanceService {
  AssistanceService._();

  static final AssistanceService instance = AssistanceService._();

  static String _keyFor(String ownerEmail) =>
      'autoassist_requests_${ownerEmail.trim().toLowerCase()}';

  Future<List<AssistanceRequest>> getRequests(String ownerEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(ownerEmail));
    if (raw == null) return <AssistanceRequest>[];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => AssistanceRequest.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> createRequest(String ownerEmail, AssistanceRequest request) async {
    final items = await getRequests(ownerEmail);
    items.insert(0, request);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyFor(ownerEmail),
      jsonEncode(items.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> updateStatus(String ownerEmail, String requestId, String status) async {
    final items = await getRequests(ownerEmail);
    final index = items.indexWhere((r) => r.id == requestId);
    if (index < 0) return;
    final updated = AssistanceRequest(
      id: items[index].id,
      vehicleName: items[index].vehicleName,
      issueType: items[index].issueType,
      description: items[index].description,
      locationLabel: items[index].locationLabel,
      latitude: items[index].latitude,
      longitude: items[index].longitude,
      status: status,
      mechanicName: items[index].mechanicName,
      createdAt: items[index].createdAt,
    );
    items[index] = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyFor(ownerEmail),
      jsonEncode(items.map((r) => r.toJson()).toList()),
    );
  }
}