import '../models/mechanic.dart';
import 'location_service.dart';
import 'mock_data.dart';

class MechanicService {
  MechanicService._();

  static final MechanicService instance = MechanicService._();

  List<Mechanic> nearDriver(AppLatLng origin, {String? query, String? specialty}) {
    final List<_MechanicDistance> result = MockData.mechanics
        .map((m) {
      final distance = LocationService.distanceKm(origin, AppLatLng(m.latitude, m.longitude));
      return _MechanicDistance(m, distance);
    })
        .toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));

    var items = result.where((e) => e.distance <= 60).toList();

    if (specialty != null && specialty.isNotEmpty) {
      items = items
          .where((e) => e.mechanic.specialty.toLowerCase().contains(specialty.toLowerCase()))
          .toList();
    }

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      items = items.where((e) {
        final m = e.mechanic;
        return m.name.toLowerCase().contains(q) ||
            m.businessName.toLowerCase().contains(q) ||
            m.specialty.toLowerCase().contains(q) ||
            m.services.any((s) => s.toLowerCase().contains(q));
      }).toList();
    }

    return items.map((e) => e.mechanic.copyWith(distanceKm: e.distance)).toList();
  }

  Mechanic byId(String id) =>
      MockData.mechanics.firstWhere((m) => m.id == id, orElse: () => MockData.mechanics.first);

  List<Mechanic> specialties(bool availableOnly) {
    final seen = <String>{};
    final result = <Mechanic>[];
    for (final m in MockData.mechanics) {
      if (availableOnly && !m.available) continue;
      if (seen.add(m.specialty)) result.add(m);
    }
    return result;
  }
}

class _MechanicDistance {
  final Mechanic mechanic;
  final double distance;

  _MechanicDistance(this.mechanic, this.distance);
}