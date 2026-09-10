import '../models/spare_part.dart';
import 'mock_data.dart';

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

  List<SparePart> search({String query = '', String category = 'All'}) {
    var items = MockData.spareParts;
    if (category != 'All') {
      items = items.where((p) => p.category == category).toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      items = items.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.supplier.toLowerCase().contains(q) ||
            p.vehicleCompat.toLowerCase().contains(q);
      }).toList();
    }
    return items;
  }
}