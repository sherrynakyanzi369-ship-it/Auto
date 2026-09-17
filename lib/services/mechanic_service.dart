import '../models/mechanic.dart';
import 'api_client.dart';
import 'location_service.dart';
import 'mock_data.dart';

/// Mechanics catalog served from PostgreSQL (Redis cached) via the API.
class MechanicService {
  MechanicService._();

  static final MechanicService instance = MechanicService._();

  Future<List<Mechanic>> nearDriver(
    AppLatLng origin, {
    String? query,
    String? specialty,
  }) async {
    final data = await ApiClient.instance.get(
      '/mechanics',
      query: {
        'lat': origin.latitude,
        'lng': origin.longitude,
        'query': query ?? '',
        'specialty': specialty ?? '',
      },
    );
    return (data as List<dynamic>)
        .map((e) => Mechanic.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> fetchSpecialties() async {
    try {
      final data = await ApiClient.instance.get('/specialties');
      final list = (data as List<dynamic>).map((e) => e.toString()).toList();
      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fall through to the bundled list.
    }
    return MockData.mechanics.map((m) => m.specialty).toSet().toList();
  }

  Mechanic byId(String id) => MockData.mechanics.firstWhere(
        (m) => m.id == id,
        orElse: () => MockData.mechanics.first,
      );
}
