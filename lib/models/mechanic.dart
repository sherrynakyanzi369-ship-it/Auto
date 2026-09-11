class Mechanic {
  final String id;
  final String name;
  final String businessName;
  final String specialty;
  final List<String> services;
  final double rating;
  final int reviewCount;
  final bool available;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final String experience;
  final double distanceKm;

  const Mechanic({
    required this.id,
    required this.name,
    required this.businessName,
    required this.specialty,
    required this.services,
    required this.rating,
    required this.reviewCount,
    required this.available,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.experience,
    this.distanceKm = 0,
  });

  Mechanic copyWith({double? distanceKm}) => Mechanic(
        id: id,
        name: name,
        businessName: businessName,
        specialty: specialty,
        services: services,
        rating: rating,
        reviewCount: reviewCount,
        available: available,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        experience: experience,
        distanceKm: distanceKm ?? this.distanceKm,
      );
}