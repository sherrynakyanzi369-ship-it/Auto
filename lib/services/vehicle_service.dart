import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vehicle.dart';

class VehicleService {
  VehicleService._();

  static final VehicleService instance = VehicleService._();

  static String _keyFor(String ownerEmail) =>
      'autoassist_vehicles_${ownerEmail.trim().toLowerCase()}';

  Future<List<Vehicle>> getVehicles(String ownerEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(ownerEmail));
    if (raw == null) return <Vehicle>[];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addVehicle(String ownerEmail, Vehicle vehicle) async {
    final items = await getVehicles(ownerEmail);
    items.add(vehicle);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyFor(ownerEmail),
      jsonEncode(items.map((v) => v.toJson()).toList()),
    );
  }

  Future<void> removeVehicle(String ownerEmail, String vehicleId) async {
    final items = await getVehicles(ownerEmail);
    items.removeWhere((v) => v.id == vehicleId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyFor(ownerEmail),
      jsonEncode(items.map((v) => v.toJson()).toList()),
    );
  }
}