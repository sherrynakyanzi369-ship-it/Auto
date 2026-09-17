import '../models/spare_part.dart';
import 'api_client.dart';

/// Spare-parts catalog served from PostgreSQL (Redis cached) via the API.
class SparePartsService {
  SparePartsService._();

  static final SparePartsService instance = SparePartsService._();

  static const List<String> categories = [
    'All',
    'Batteries',
    'Brakes',
    'Lubricants',
    'Ignition',
    'Filters',
    'Transmission',
    'Tyres',
    'Electrical',
    'Cooling',
    'Fuel System',
    'Suspension',
    'Lighting',
  ];

  Future<List<SparePart>> search({
    String query = '',
    String category = 'All',
  }) async {
    final data = await ApiClient.instance.get(
      '/parts',
      query: {'query': query, 'category': category},
    );
    return (data as List<dynamic>)
        .map((e) => SparePart.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
