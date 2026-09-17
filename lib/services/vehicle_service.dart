import '../models/vehicle.dart';
import 'api_client.dart';
import 'auth_service.dart';

/// Vehicle garage persisted in PostgreSQL via the AutoAssist API.
class VehicleService {
  VehicleService._();

  static final VehicleService instance = VehicleService._();

  Future<List<Vehicle>> getVehicles(String ownerEmail) async {
    final data = await ApiClient.instance.get(
      '/vehicles',
      token: AuthService.instance.token,
    );
    return (data as List<dynamic>)
        .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Vehicle> addVehicle(String ownerEmail, Vehicle vehicle) async {
    final data = await ApiClient.instance.post(
      '/vehicles',
      body: vehicle.toJson(),
      token: AuthService.instance.token,
    );
    return Vehicle.fromJson(data as Map<String, dynamic>);
  }

  Future<void> removeVehicle(String ownerEmail, String vehicleId) async {
    await ApiClient.instance.delete(
      '/vehicles/$vehicleId',
      token: AuthService.instance.token,
    );
  }
}
